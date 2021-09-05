library(readxl)
library(glue)
library(dplyr)
source('D:/Project/Speedaf/01. Report/Dev/helper function.R')
# Using Waybill Sum as the main source file
# Augmented Document would be Arrival Sum and Delivery Sum (Present Day)

#### Parameters ####
## Parameter
input_path = '../_Data/'
output_path <- './output/'
mtoday = "09062021"#format(Sys.Date(),"%d%m%Y")
date_range = as.POSIXct("2021-04-01")


##### Data Structure - Column Name Definition #####
# Waybill Sum source file and rename column
{
  waybill_sum_newcols <- c("Waybill",
                           "CreationSite", "ShippedTime", "Destination", "PickupTime",
                           "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                           "DepartureTime4DC", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                           "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                           "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                           "IssueType", "Sender", "TransitDuration", "Reason")

  wsc_newcols <- c("Waybill", "DepartureDate", "DepartureSite", "PickupScanOperator", "Destination", "DestinationSiteCode",
                      "DestinationSite", "SenderName", "SendCompany", "CompanyAddress", "SendersContact", "SendersMessageFlag",
                      "ReceiverName", "ReceiptCompany", "DestinationAreaCode", "DestinationDistrict", "DestinationRegion",
                      "ConsigneeAddress", "Receiver'SContact", "PickupSite", "DestinationSub-Site", "CreationDate", "
                  WaybillCreator", "FinanceCenter", "FinanceCenterdup", "DepartureRegionOrState", "DeliveryRegionOrState",
                      "Quantity", "GrossWeight", "GoodsType", "ItemDescription", "DeliveryType", "TransportType", "Freight",
                      "ClientPaymentMethod", "Cod", "Remark", "TransitWaybill", "SubWaybill", "CollectionFlag", "CollectionDate",
                      "ExpressType", "RegisteredLetter", "WaybillEntrySource", "IssueParcelFlagBoolean", "ReturnFlagBoolean",
                      "ShippingFeeCollectionSite", "ShippingFeeConfirmerSite", "ShippingFeeCollectTimeSite", "ShippingFeeCollectCenter",
                      "ShippingFeeCollectConfirmerCenter", "ShippingFeeCollectTimeCenter", "CustomerId", "SiteOfTheLastScan",
                      "StatusOfTheLastScan", "TimeOfTheLastScan", "GoodsValue", "InsuranceFee", "SalesAgent", "PaymentType",
                      "PickupSiteId", "PickupDate", "TransitTime", "WhOrderNo", "MajorCustomerNumber", "CustomerNo", "OrderTypeSource",
                      "Exception", "ExceptionType", "ExceptionReason", "MainWaybill", "LastOrNextSite", "Unknown")

  wsc_select_cols <- c("Waybill","CreationTime","DestinationDistrict","DestinationRegion",
                       "ConsigneeAddress","DepartureRegion/State","DeliveryRegion/State")

##### Final Data column names #####
  final_select_cols_mil <- c("Waybill",
                             "CreationSite","CreationTime", "ShippedTime", "Destination", "PickupTime",
                             "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                             "DepartureTime4DC", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                             "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                             "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                             "IssueType", "Sender", "TransitDuration", "Reason")

  final_select_cols_sla <- c("Waybill",
                             "CreationSite","CreationTime", "ShippedTime","PickupTime",
                             "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                             "DepartureTime4DC", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                             "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                             "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                             "IssueType", "Sender","IssueParcelTime_min"
                             #'DeliveryTime_first'
                             # "DestinationDistrict","DestinationRegion",
                             # "ConsigneeAddress","DepartureRegion/State","DeliveryRegion/State"
                             )
}

#### Load Data ####
##### Waybill Sum #####
# ETA 3mins
system.time(WaybillSum <-
              readxl::read_excel(glue(input_path,'Waybill Sum/',"Waybill Sum {mtoday}.xlsx"),
                                 col_types = c("text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "numeric", "text")) %>%
              'colnames<-' (waybill_sum_newcols) %>%
              mutate_at(vars(contains('time')), as.POSIXct))

##### WSC  #####
# ETA 3mins
system.time(wsc <-
              readxl::read_excel(glue(input_path,"WSC/","WSC {mtoday}.xlsx"),col_types = rep("text",73)) %>%
              'colnames<-' (wsc_newcols) %>%
              select(all_of(wsc_select_cols)))
##### Issue Parcels #####
issueParcels_df <-read_excel('../_Data/IssueParcel/IssueParcel 09062021.xlsx', col_types = c('text','date')) %>%
  # mutate(`REGISTER_DATE` = as.Date(`REGISTER_DATE`) )
  'colnames<-' (c('Waybill','IssueParcelTime')) %>%
  group_by(Waybill) %>%
  summarise(IssueParcelTime_min = min(IssueParcelTime))

##### Write/Save ####
##### Write/Save Milestone #####
Sys.setenv(TZ="")
##### Write/Save - Milestone #####
system.time(
  WaybillSum %>%
    left_join(wsc %>% select(Waybill,CreationTime)) %>%
    select(all_of(final_select_cols_mil)) %>%
    filter(ShippedTime >= date_range) %>%
    writexl::write_xlsx(glue(output_path,"MileStone_ext_{mtoday}.xlsx"))
)

##### Write/Save - SLA #####
date_range <- as.POSIXct("2021-04-01")
system.time(
  # View(
    SLA <-  WaybillSum %>%
      select(-Destination,-TransitDuration,-Reason) %>%
      left_join(wsc  %>%  select(Waybill, CreationTime)) %>%
      left_join(issueParcels_df) %>%
      # mutate(1st)
      # left_join(DeliveryTime_df) %>%
      # mutate() %>%
      select(all_of(final_select_cols_sla)) %>%
      filter(ShippedTime >= date_range) %>%
      writexl::write_xlsx(glue(output_path,"SLA_v3_{date_range}_{mtoday}.xlsx"))
  # )
)
