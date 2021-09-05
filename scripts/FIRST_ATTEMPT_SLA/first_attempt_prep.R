# Library
library(readr)
library(dplyr)
library(data.table)
## Template

### Table
TBL_ATTEMPT_TABLE <- data.table::data.table()
# TBL_ATTEMPT_TABLE <- data.table::data.table(
#   AWB = character(), 
#   # Expected
#   first_attempt_time = as.POSIXct(character()),
#   first_attempt_site = character(),
#   # Optional
#   last_attempt_time = as.POSIXct(character()),
#   last_attempt_site = character(),
#   # Temp Table
#   first_IssueParcel_time = as.POSIXct(character()),
#   first_IssueParcel_site = character(),
#   first_delivery_time = as.POSIXct(character()),
#   first_delivery_site = character(),
#   # Counter
#   total_attempt_count = integer(),
#   IssueParcel_Scan_count = integer(),
#   Delivery_Scan_count = integer(),
#   first_attempt_type = character()
# )




# Load Data
# 1. IssueParcel
IssueParcel <- readr::read_csv("data/prep data/IssueParcel 2021-08.csv",
                                col_types = cols(REGISTRATION_DATE = col_datetime(format = "%m/%d/%Y %H:%M")))
# 2. Delivery 
Delivery <- readr::read_csv('./data/prep data/Delivery 2021-08.csv', col_types = 'c??TT')
# 3. Pickup
Pickup <- readr::read_csv('./data/prep data/Pickup 2021-08.csv', col_types = 'c?TT')


# AWBs
AWB <- Pickup$BILL_CODE





# Upload 
TBL_ATTEMPT_TABLE$AWB =  AWB

