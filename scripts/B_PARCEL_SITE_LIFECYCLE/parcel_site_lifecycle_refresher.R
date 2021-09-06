# Library
library(readr)
library(dplyr)
library(tidyr)
library(dbplyr)
library(data.table)

source("~/Documents/Project/SLA/data/create_empty_data_frame.R")
source("~/Documents/Project/SLA/scripts/A_FIRST_ATTEMPT_SLA/function_first_attempt.R")

# Load Data
# 1. IssueParcel
IssueParcel <- readr::read_csv("data/refresher/IssueParcel.csv",
                               col_types = cols(REGISTRATION_DATE = col_datetime(format = "%m/%d/%Y %H:%M")))
# 2. Delivery 
Delivery <- readr::read_csv('./data/refresherDelivery 2021-08.csv', col_types = 'c??TT')
# 3. Pickup
Pickup <- readr::read_csv('./data/refresher/Pickup 2021-08.csv', col_types = 'c?TT')



# Prep temp
R_attempt_temp_df <- prep_first_attempt_temp_table(IssueParcelTable = IssueParcel, DeliveryScanTable = Delivery)
# First Attempt 
R_f_attempt_df <- get_first_attempt_time_site(R_attempt_temp_df)
# Last Attempt 
R_l_attempt_df <- get_last_attempt_time_site(R_attempt_temp_df)
# Attempt Counter
R_attempt_counter <- get_R_attempt_counter(R_attempt_temp_df)


################################# Joins #################################
## Initialize table
R_AWB <- Pickup$BILL_CODE
R_TBL_ATTEMPT_TABLE <- data.table::data.table()

R_TBL_ATTEMPT_TABLE$R_AWB <- R_AWB


R_TBL_ATTEMPT_TABLE <- R_TBL_ATTEMPT_TABLE %>% 
  left_join(R_f_attempt_df, copy = T) %>% 
  left_join(R_l_attempt_df, copy = T) %>% 
  left_join(R_attempt_counter, copy = T) %>% 
  mutate(upload_time = up_timestamp)

################################################## Rename ##################################

# Correct for LTL (To be implemented)
up_timestamp <- gsub(pattern = "[^[:alnum:]]", replacement = "",Sys.time())
############################################################ Clean up #############################################################################
rm(Delivery, IssueParcel)
rm(R_f_attempt_df, R_l_attempt_df, R_attempt_counter)

########################################################## 01. Connect to DB ###############################################################################
SLA_temp_db <- DBI::dbConnect(RSQLite::SQLite(), "db/SLA_temp_DB.sqlite")

######################################################## 03. Write to DB #################################################################################
# Update
##### $sql="UPDATE checkpoints SET CP2_Arrivale='".$cp."00' WHERE Team='".$Team."';
copy_to(dest = SLA_temp_db, df = R_TBL_ATTEMPT_TABLE)

########################################################## 02. Querries ########################################################################
tbl(SLA_temp_db, sql("SELECT * FROM R_TBL_ATTEMPT_TABLE"))

##

######################################################### 04. Close Connection ############################################################################
DBI::dbDisconnect(SLA_temp_db)
