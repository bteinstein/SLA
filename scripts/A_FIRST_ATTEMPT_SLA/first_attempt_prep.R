# Library
library(readr)
library(dplyr)
library(tidyr)
library(dbplyr)
library(data.table)

source("~/Documents/Project/SLA/data/create_empty_data_frame.R")
source("~/Documents/Project/SLA/scripts/FIRST_ATTEMPT_SLA/function_first_attempt.R")


{
## Template

# https://stackoverflow.com/questions/27565507/update-existing-row-instead-of-creating-a-new-one-in-mysql

### Insert and Update
# https://stackoverflow.com/questions/27565507/update-existing-row-instead-of-creating-a-new-one-in-mysql
# $sql="INSERT INTO checkpoints (Team, CP2_Arrival) 
# VALUES (
#  '".$Team."',
#  '".$cp."00' 
# ) ON DUPLICATE KEY UPDATE CP2_Arrival='".$cp."00'";
# 
# OR
# $sql="UPDATE checkpoints SET CP2_Arrivale='".$cp."00' WHERE Team='".$Team."';
# 
# ALTER TABLE checkpoints ADD PRIMARY KEY(Team);
}
# Load Data
# 1. IssueParcel
IssueParcel <- readr::read_csv("data/prep data/IssueParcel.csv",
                                col_types = cols(REGISTRATION_DATE = col_datetime(format = "%m/%d/%Y %H:%M")))
# 2. Delivery 
Delivery <- readr::read_csv('./data/prep data/Delivery 2021-08.csv', col_types = 'c??TT')
# 3. Pickup
Pickup <- readr::read_csv('./data/prep data/Pickup 2021-08.csv', col_types = 'c?TT')



# Prep temp
attempt_temp_df <- prep_first_attempt_temp_table(IssueParcelTable = IssueParcel, DeliveryScanTable = Delivery)
# First Attempt 
f_attempt_df <- get_first_attempt_time_site(attempt_temp_df)
# Last Attempt 
l_attempt_df <- get_last_attempt_time_site(attempt_temp_df)
# Attempt Counter
attempt_counter <- get_attempt_counter(attempt_temp_df)


#### Joins
## Initialize table
AWB <- Pickup$BILL_CODE
TBL_ATTEMPT_TABLE <- data.table::data.table()#(length(AWB))
# TBL_ATTEMPT_TABLE <- create_TBL_Attempt_TABLE(length(AWB))

# Upload 
TBL_ATTEMPT_TABLE$AWB <- AWB
up_timestamp <- gsub(pattern = "[^[:alnum:]]", replacement = "",Sys.time())
  
TBL_ATTEMPT_TABLE <- TBL_ATTEMPT_TABLE %>% 
  left_join(f_attempt_df, copy = T) %>% 
  left_join(l_attempt_df, copy = T) %>% 
  left_join(attempt_counter, copy = T) %>% 
  mutate(upload_time = up_timestamp)


# Correct for LTL (To be implemented)

############################################################ Clean up #############################################################################
rm(Delivery, IssueParcel)
rm(f_attempt_df, l_attempt_df, attempt_counter)

########################################################## 01. Connect to DB ###############################################################################
SLA_temp_db <- DBI::dbConnect(RSQLite::SQLite(), "db/SLA_temp_DB.sqlite")

######################################################## 03. Write to DB #################################################################################
# Update
##### $sql="UPDATE checkpoints SET CP2_Arrivale='".$cp."00' WHERE Team='".$Team."';
copy_to(dest = SLA_temp_db, df = TBL_ATTEMPT_TABLE)

########################################################## 02. Querries ########################################################################
tbl(SLA_temp_db, sql("SELECT * FROM TBL_ATTEMPT_TABLE"))

##

######################################################### 04. Close Connection ############################################################################
DBI::dbDisconnect(SLA_temp_db)
