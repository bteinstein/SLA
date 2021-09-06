# https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html#Creating_a_new_SQLite_database

# Library
library(readr)
library(dplyr)
library(dbplyr)
library(data.table)
library(tidyverse)


### Create Table
# TBL_ATTEMPT_TABLE <- data.table::data.table()
# TBL_ATTEMPT_TABLE <- data.table::data.table(
TBL_ATTEMPT_TABLE <- data.table::data.table(
  # data_frame(
  AWB = character(),
  # Expected
  First_Attempt_Time = as.POSIXct(character()),
  First_Attempt_Site = character(nr),
  # Optional
  Last_Attempt_Time = as.POSIXct(character()),
  Last_Attempt_Site = character(nr),
  # Temp Table
  First_IssueParcel_Time = as.POSIXct(character()),
  First_IssueParcel_Site = character(nr),
  First_delivery_Time = as.POSIXct(character()),
  First_delivery_Site = character(nr),
  # Counter
  Max_Attempt = integer(nr),
  IssueParcel_Scan_Count = integer(nr),
  Delivery_Scan_Count = integer(nr),
  First_Attempt_Type = character(nr)
)

my_db_file <- "db/SLA_temp_DB.sqlite"
my_db <- src_sqlite(path = my_db_file, create = TRUE)

copy_to(my_db, TBL_ATTEMPT_TABLE)



# Close connection 
# DBI::dbDisconnect(RSQLite::SQLite(),my_db)
