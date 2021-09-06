library(dplyr)
library(readr)
library(writexl)

####### Desired Columns #######
final_select_cols_sla <- c("Waybill", #DB: AWB_Rec
                           "CreationSite", #DB: AWB_Rec
                           "CreationTime", #DB: AWB_Rec
                           "ShippedTime", #DB: AWB_Rec
                           "PickupTime", #DB: AWB_Rec
                           "DepartureTime2DC", #DB: AWB_SEND 
                           "ArrivalDC", 
                           "ArrivalTimeDC", 
                           "DepartureSite4DC", #DB: AWB_SEND 
                           "DCDepartureTime", #DB: AWB_SEND 
                           "ArrivalSite", 
                           "SiteArrivalTime", 
                           "DeliverySite",
                           "Deliverer", 
                           "DeliveryTime", 
                           "PODSite", 
                           "PODTime",
                           "ReturnSite", 
                           "ReturnTime", 
                           "IssueParcleSite", 
                           "IssueParcleTime",
                           "IssueType", 
                           "Sender",
                           "FirstAttemptTime"
)


# Waybill # Picked up waybills

SLA_base_df <- data.table::data.table(
  "Waybill", #DB: AWB_Rec
  "CreationSite", #DB: AWB_Rec
  "CreationTime"#DB: AWB_Rec)
)

# Pickup <- readr::read_csv('./data/prep data/Pickup 2021-08.csv', col_types = 'c?TT')

TBL_SLA <- data.table::data.table()


TBL_SLA$Waybill <- Pickup$BILL_CODE
TBL_SLA$PickupTime <- Pickup$SCAN_DATE
TBL_SLA$PickupSite <- Pickup$SCAN_SITE_CODE

