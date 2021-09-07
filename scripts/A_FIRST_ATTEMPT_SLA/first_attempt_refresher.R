# Library
library(readr)
library(dplyr)
library(tidyr)
library(dbplyr)
library(data.table)
library(DBI)

source("./scripts/2_LOAD_DATA/create_empty_data_frame.R")
source("./scripts/A_FIRST_ATTEMPT_SLA/function_first_attempt.R")

# Load Data
# 1. IssueParcel
IssueParcel <- readr::read_csv("data/refresher/IssueParcel.csv",
                               col_types = cols(REGISTRATION_DATE = col_datetime(format = "%m/%d/%Y %H:%M")))
# 2. Delivery 
Delivery <- readr::read_csv('./data/refresher/Delivery 2021-08.csv', col_types = 'c??TT')
# 3. Pickup
Pickup <- readr::read_csv('./data/refresher/Pickup 2021-08.csv', col_types = 'c?TT')


# Prep temp
R_attempt_temp_df <- prep_first_attempt_temp_table(IssueParcelTable = IssueParcel, DeliveryScanTable = Delivery)
# First Attempt 
R_f_attempt_df <- get_first_attempt_time_site(R_attempt_temp_df)
# Last Attempt 
R_l_attempt_df <- get_last_attempt_time_site(R_attempt_temp_df)
# Attempt Counter
R_attempt_counter <- get_attempt_counter(R_attempt_temp_df)


################################# Joins #################################
## Initialize table
R_AWB <- Pickup$BILL_CODE
R_TBL_ATTEMPT_TABLE <- data.table::data.table()

R_TBL_ATTEMPT_TABLE$AWB <- R_AWB

R_TBL_ATTEMPT_TABLE <- R_TBL_ATTEMPT_TABLE %>% 
  left_join(R_f_attempt_df, copy = T) %>% 
  left_join(R_l_attempt_df, copy = T) %>% 
  left_join(R_attempt_counter, copy = T) 

################################################## Rename ##################################
R_names <- names(R_TBL_ATTEMPT_TABLE)
renm_R_names <- paste0("R_",R_names[-1])

names(R_TBL_ATTEMPT_TABLE)[-1] <- paste0("R_",R_names[-1])


################################################## Join with DB Backup #####################################

####################### Connect to DB ############# 
#### Note some issue with joining on two different sources :: https://github.com/r-dbi/bigrquery/issues/219
conn_SLA_temp_db <- create_SLA_temp_DBConnection()

# .....
# Write R_TBL_ATTEMPT_TABLE to local db
dbWriteTable(conn_SLA_temp_db, "TBL_ATTEMPTS_TEMP", R_TBL_ATTEMPT_TABLE, overwrite = T) # always overwrite

ATTEMPT_TBL_ref <- tbl(conn_SLA_temp_db, "TBL_ATTEMPTS")
ATTEMPT_TBL_R <- tbl(conn_SLA_temp_db, "TBL_ATTEMPTS_TEMP")

Merge_TBL_ATTEMPT <- ATTEMPT_TBL_R %>% 
  left_join(ATTEMPT_TBL_ref)


################################################ Subsetting - Separate Insert and upload ################################
UPT_ATTEMPT_TBL <- filter(Merge_TBL_ATTEMPT, !is.na(upload_time)) %>% collect() # Pull to R Session (I don't like trouble)
INS_TBL_ATTEMPT <- filter(Merge_TBL_ATTEMPT, is.na(upload_time))


################################################# Run Calculation on the Update-Subset #######################################
## "AWB"                      "R_First_Attempt_Time"     "R_First_Attempt_Site"     "R_First_Attempt_Type"     
#  "R_Last_Attempt_Time"      "R_Last_Attempt_Site"      
# "R_IssueParcel_Scan_Count" "R_Delivery_Scan_Count"    "R_Max_Attempt"   

UPT_ATTEMPT_TBL <- UPT_ATTEMPT_TBL %>% 
  # U_First_Attempt_Time
  mutate(U_First_Attempt_Time = case_when(is.na(R_First_Attempt_Time) ~ First_Attempt_Time,
                                            R_First_Attempt_Time <= First_Attempt_Time ~ R_First_Attempt_Time,
                                            TRUE ~ First_Attempt_Time)) %>% 
  # U_First_Attempt_Site
  mutate(U_First_Attempt_Site = case_when(is.na(R_First_Attempt_Time) ~ First_Attempt_Site,
                                          R_First_Attempt_Time <= First_Attempt_Time ~ R_First_Attempt_Site,
                                          TRUE ~ First_Attempt_Site)) %>% 
  # U_First_Attempt_Type
  mutate(U_First_Attempt_Type = case_when(is.na(R_First_Attempt_Time) ~ First_Attempt_Type,
                                          R_First_Attempt_Time <= First_Attempt_Time ~ R_First_Attempt_Type,
                                          TRUE ~ First_Attempt_Type)) %>% 
  # U_Last_Attempt_Time
  mutate(U_Last_Attempt_Time = case_when(is.na(R_Last_Attempt_Time) ~ Last_Attempt_Time,
                                         R_Last_Attempt_Time >= Last_Attempt_Time ~ R_Last_Attempt_Time,
                                          TRUE ~ Last_Attempt_Time)) %>% 
  # R_Last_Attempt_Site
  mutate(U_Last_Attempt_Site = case_when(is.na(R_Last_Attempt_Time) ~ Last_Attempt_Site,
                                         R_Last_Attempt_Time >= Last_Attempt_Time ~ R_Last_Attempt_Site,
                                         TRUE ~ Last_Attempt_Site)) %>% 
  rowwise() %>%
  # R_IssueParcel_Scan_Count
  mutate(U_IssueParcel_Scan_Count = sum(R_IssueParcel_Scan_Count,IssueParcel_Scan_Count, na.rm = T)) %>%
  # R_Delivery_Scan_Count
  mutate(U_Delivery_Scan_Count = sum(R_Delivery_Scan_Count,Delivery_Scan_Count, na.rm = T)) %>%
  # R_Max_Attempt
  mutate(U_Max_Attempt = sum(U_Delivery_Scan_Count,R_IssueParcel_Scan_Count, na.rm = T))
  
# left_join( 
#   UPT_ATTEMPT_TBL %>% 
#   select(AWB, R_IssueParcel_Scan_Count, IssueParcel_Scan_Count,R_Delivery_Scan_Count,Delivery_Scan_Count) %>% 
#   group_by(AWB) %>% 
#   # mutate(U_IssueParcel_Scan_Count = R_IssueParcel_Scan_Count+IssueParcel_Scan_Count) %>% 
#   mutate(U_IssueParcel_Scan_Count = R_IssueParcel_Scan_Count+IssueParcel_Scan_Count ) %>% 
#   mutate(U_Delivery_Scan_Count = R_Delivery_Scan_Count+Delivery_Scan_Count) 
# )

########################################################## Insert ######################################################
up_timestamp <- gsub(pattern = "[^[:alnum:]]", replacement = "",Sys.time())
# .....
INS_TBL_ATTEMPT <- INS_TBL_ATTEMPT %>% select(AWB, !contains('R_')) %>%  
  mutate(upload_time = up_timestamp) %>% collect()

names(INS_TBL_ATTEMPT)
# Write INS_TBL_ATTEMPT to local db
dbWriteTable(conn_SLA_temp_db, "TBL_ATTEMPTS", INS_TBL_ATTEMPT, append = T) # always overwrite


########################################################## Update DB  ######################################################
WRT_UPT_ATTEMPT_TBL <- UPT_ATTEMPT_TBL %>% select(AWB, contains('U_')) %>%  
  mutate(upload_time = up_timestamp) #%>% collect()
# Rename
names(WRT_UPT_ATTEMPT_TBL) <- gsub(pattern = "U_",replacement = "", names(WRT_UPT_ATTEMPT_TBL) )
names(WRT_UPT_ATTEMPT_TBL) 

# Write WRT_UPT_ATTEMPT_TBL to local db
dbWriteTable(conn_SLA_temp_db, "TEMP_UPT_ATTEMPT_TBL", WRT_UPT_ATTEMPT_TBL, overwrite = T) # always overwrite


upd_sql <- 'UPDATE TBL_ATTEMPTS
SET(First_Attempt_Time,First_Attempt_Site,First_Attempt_Type,Last_Attempt_Time,Last_Attempt_Site,IssueParcel_Scan_Count,Delivery_Scan_Count,Max_Attempt) = (TEMP_UPT_ATTEMPT_TBL.First_Attempt_Time, TEMP_UPT_ATTEMPT_TBL.First_Attempt_Site, TEMP_UPT_ATTEMPT_TBL.First_Attempt_Type, TEMP_UPT_ATTEMPT_TBL.Last_Attempt_Time, TEMP_UPT_ATTEMPT_TBL.Last_Attempt_Site,TEMP_UPT_ATTEMPT_TBL.IssueParcel_Scan_Count, TEMP_UPT_ATTEMPT_TBL.Delivery_Scan_Count, TEMP_UPT_ATTEMPT_TBL.Max_Attempt)
FROM TEMP_UPT_ATTEMPT_TBL
WHERE TEMP_UPT_ATTEMPT_TBL.AWB = TBL_ATTEMPTS.AWB;'



dbBegin(conn_SLA_temp_db)
dbExecute(conn_SLA_temp_db, upd_sql)
dbCommit(conn_SLA_temp_db)
# dbRollback(conn_SLA_temp_db)


######################################################### Clean ups ####################################################
dbListTables(conn_SLA_temp_db)
dbRemoveTable(conn_SLA_temp_db, "TBL_ATTEMPTS_TEMP")
dbRemoveTable(conn_SLA_temp_db, "TEMP_UPT_ATTEMPT_TBL")
rm(R_attempt_temp_df, R_TBL_ATTEMPT_TABLE, U_TBL_ATTEMPT_TABLE, WRT_UPT_ATTEMPT_TBL,UPT_ATTEMPT_TBL,INS_TBL_ATTEMPT,ATTEMPT_TBL_ref)
########################################################## 02. Querries ########################################################################
tbl(conn_SLA_temp_db, sql("SELECT * FROM TBL_ATTEMPTS"))

##

######################################################### 04. Close Connection ############################################################################
DBI::dbDisconnect(SLA_temp_db)
