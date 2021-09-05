library(readxl)
library(glue)
library(dplyr)
library(stringr)
source('../../_Base Script/helper function.R')
# library(future)
# plan(multisession)
# Using Waybill Sum as the main source file
# Augmented Document would be Arrival Sum and Delivery Sum (Present Day)

#### Parameters ####
## Parameter

input_path = "../../_Data/"
output_path <- './02. SLA/output/'
mtoday = "01092021"#format(Sys.Date(),"%d%m%Y")
date_range = as.POSIXct("2021-06-01")


##### Data Structure - Column Name Definition #####
# Waybill Sum source file and rename column
{
  waybill_sum_newcols <- c("Waybill",
                           "CreationSite", "ShippedTime", "Destination", "PickupTime",
                           "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                           "DCDepartureTime", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                           "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                           "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                           "IssueType", "Sender", "TransitDuration", "Reason")

  wsc_newcols <- c("Waybill", "DepartureDate", "DepartureSite", "PickupScanOperator", "Destination", "DestinationSiteCode",
                   "DestinationSite", "SenderName", "SendCompany", "CompanyAddress", "SendersContact", "SendersMessageFlag",
                   "ReceiverName", "ReceiptCompany", "DestinationAreaCode", "DestinationDistrict", "DestinationRegion",
                   "ConsigneeAddress", "Receiver'SContact", "PickupSite", "DestinationSub-Site", "CreationTime", "WaybillCreator",
                   "FinanceCenter", "FinanceCenterdup", "DepartureRegionOrState", "DeliveryRegionOrState",
                   "Quantity", "GrossWeight", "GoodsType", "ItemDescription", "DeliveryType", "TransportType", "Freight",
                   "ClientPaymentMethod", "Cod", "Remark", "TransitWaybill", "SubWaybill", "CollectionFlag", "CollectionDate",
                   "ExpressType", "RegisteredLetter", "WaybillEntrySource", "IssueParcelFlagBoolean", "ReturnFlagBoolean",
                   "ShippingFeeCollectionSite", "ShippingFeeConfirmerSite", "ShippingFeeCollectTimeSite", "ShippingFeeCollectCenter",
                   "ShippingFeeCollectConfirmerCenter", "ShippingFeeCollectTimeCenter", "CustomerId", "SiteOfTheLastScan",
                   "StatusOfTheLastScan", "TimeOfTheLastScan", "GoodsValue", "InsuranceFee", "SalesAgent", "PaymentType",
                   "PickupSiteId", "PickupDate", "TransitTime", "WhOrderNo", "MajorCustomerNumber", "CustomerNo", "OrderTypeSource",
                   "Exception", "ExceptionType", "ExceptionReason", "MainWaybill", "LastOrNextSite", "Unknown")

  wsc_select_cols <- c("Waybill","CreationTime","DestinationDistrict","DestinationRegion",
                       "ConsigneeAddress","DepartureRegionOrState","DeliveryRegionOrState")

  ##### Final Data column names #####
  final_select_cols_mil <- c("Waybill",
                             "CreationSite","CreationTime", "ShippedTime", "Destination", "PickupTime",
                             "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                             "DCDepartureTime", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                             "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                             "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                             "IssueType", "Sender", "TransitDuration", "Reason")

  final_select_cols_sla <- c("Waybill",
                             "CreationSite","CreationTime", "ShippedTime","PickupTime",
                             "DepartureTime2DC", "ArrivalDC", "ArrivalTimeDC", "DepartureSite4DC",
                             "DCDepartureTime", "ArrivalSite", "SiteArrivalTime", "DeliverySite",
                             "Deliverer", "DeliveryTime", "PODSite", "PODTime",
                             "ReturnSite", "ReturnTime", "IssueParcleSite", "IssueParcleTime",
                             "IssueType", "Sender","FirstAttemptTime"
                             )

  PODSearch_col <- c("Select", "Waybill", "POD", "PodBy", "PODTime", "PodSiteDefault", "Deliverer",
                     # "FreightCollect",
                     "Cod", "FinalWeight", "Customer",
                     "Sender", "Receiver", "ReceiversContact", "Address", "Return", "Monthly", "Remark", "Start", "Operator", "PODSite", "Editor",
                     "EditedBySite", "TimeOfModification", "Freight", "SettlementType", "PaymentType", "SendCompany")

  PODSearch_select_cols <- c("Waybill","PODTime",  "PODSite")
}

#### Load Data ####
##### Waybill Sum #####
# ETA 3mins
WaybillSum <- readxl::read_excel(glue(input_path,'Waybill Sum/',"Waybill Sum {mtoday}.xlsx"),
                                 col_types = c("text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "text", "text", "text", "text", "text",
                                               "numeric", "text")) %>%
              'colnames<-' (waybill_sum_newcols) %>%
              mutate_at(vars(contains('time')), as.POSIXct)

##### WSC  #####
# ETA 3mins
wsc <- readxl::read_excel(glue(input_path,"WSC/","WSC {mtoday}.xlsx"),col_types = rep("text",78)) %>%
              'colnames<-' (wsc_newcols) %>%
              select(all_of(wsc_select_cols))
##### Issue Parcels #####
{
  issueParcels_df <- read_excel(glue(input_path,"IssueParcel/","IssueParcel {mtoday}.xlsx"),
                             col_types = c('text','date')) %>%
  'colnames<-' (c('Waybill','min_Date')) %>%
  group_by(Waybill) %>%
  summarise(min_Date = min(min_Date))

  DeliveryScan_df <- read_excel(glue(input_path,"Delivery Scan/","DeliveryScan {mtoday}.xlsx"),
                      col_types = c('text','date','text')) %>%
    'colnames<-' (c('Waybill','min_Date')) %>%
    select('Waybill','min_Date') %>%
    group_by(Waybill) %>%
    summarise(min_Date = min(min_Date))

  FirstAttempt_df <- bind_rows(issueParcels_df,
                               DeliveryScan_df) %>%
    group_by(Waybill) %>%
    summarise(min_Date = min(min_Date)) %>%
    'colnames<-' (c('Waybill','FirstAttemptTime'))
}

### POD Search

PODSearch <- read_excel("~/_Data/POD Search/POD.xlsx",
                    col_types = c("text", "date", "text")) %>%
mutate_at(vars(contains('time')), as.POSIXct)



# PODSearch <- POD

##### Write/Save ####
# Sys.setenv(TZ="")

##### Write/Save - SLA #####
SLA <-  WaybillSum %>%
  select(-Destination,-TransitDuration,-Reason) %>%
  left_join(wsc  %>%  select(Waybill, CreationTime)) %>%
  left_join(FirstAttempt_df) %>%
  select(all_of(final_select_cols_sla))  %>%
  mutate(pickupTime_adj =
           case_when(
             !is.na(PickupTime) == TRUE ~ as.character(PickupTime),
             !is.na(DepartureTime2DC) ~ as.character(DepartureTime2DC),
             !is.na(ArrivalTimeDC) ~ as.character(ArrivalTimeDC),
             !is.na(DCDepartureTime) ~ as.character(DCDepartureTime),
             !is.na(SiteArrivalTime) ~ as.character(SiteArrivalTime),
             !is.na(DeliveryTime) ~ as.character(DeliveryTime),
             !is.na(PODTime) ~ as.character(PODTime),
             !is.na(ReturnTime) ~ as.character(ReturnTime),
             !is.na(IssueParcleTime) ~ as.character(IssueParcleTime),
             TRUE ~ ""
           )
  ) %>%
  mutate(pickupTime_adj = ifelse(pickupTime_adj=="", NA, pickupTime_adj)) %>%
  mutate( furtherScanInd = NAindcator(DepartureTime2DC, ArrivalTimeDC,DCDepartureTime,DeliveryTime,PODTime,ReturnTime,FirstAttemptTime)) %>%
  mutate(isClosed = ifelse(!is.na(PODTime) == TRUE | !is.na(ReturnTime) == TRUE,1,0)) %>%
  left_join(PODSearch) %>%
  filter(!grepl('Test',`CreationSite`)) %>%
  filter(!grepl('Test',`ArrivalDC`)) %>%
  filter(!grepl('Test',`DepartureSite4DC`)) %>%
  filter(!grepl('Test',`PODSite`)) %>%
  filter(!grepl('Test',`ArrivalSite`)) %>%
  filter(!grepl('Test',`IssueParcleSite`)) %>%
  filter(!grepl('Test',DeliverySite))



SLA_Filter <- SLA %>%
  mutate(PickupTime = ifelse(is.na(PickupTime),as.character(pickupTime_adj), as.character(PickupTime))) %>%
  mutate(PickupTime = as.POSIXct(PickupTime)) %>%
  mutate(PickupYrMnt = format(as.Date(PickupTime), "%Y-%b"))  %>%
  filter(ShippedTime >= date_range) %>%
  filter(furtherScanInd == 1)


#
# data_band <- list(
#   # April = SLA_Filter %>% filter(PickupYrMnt == "2021-April"),
#   May = SLA_Filter %>% filter(PickupYrMnt == "2021-May"),
#   June = SLA_Filter %>% filter(PickupYrMnt == "2021-Jun"),
#   July = SLA_Filter %>% filter(PickupYrMnt == "2021-Jul")
# )
#



# filter(ShippedTime >= date_range) %>%
# writexl::write_xlsx(glue(output_path,"SLA_v3_{date_range}_{mtoday}_V2.xlsx"))

# file_download <- list(filter_data = SLA_Filter, all_data = SLA)

# writexl::write_xlsx(x = file_download, path = glue(output_path,"SLA_v5_{mtoday}.xlsx"))


# writexl::write_xlsx(x = data_band, path = glue(output_path,"SLA_v6_split_{mtoday}.xlsx"))
writexl::write_xlsx(x = SLA_Filter, path = glue(output_path,"SLA_v6_all_{mtoday}.xlsx"))



