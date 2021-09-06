

create_TBL_Attempt_TABLE <- function(nr){
  suppressWarnings(
    data.table::data.table(
  # data_frame(
  AWB = character(),
  # Expected
  First_Attempt_Time = as.POSIXct(character()),
  # First_Attempt_Site = character(nr),
  First_Attempt_Site = character(length = nr),
  # Optional
  Last_Attempt_Time = as.POSIXct(character()),
  Last_Attempt_Site = character(length = nr),
  # Temp Table
  First_IssueParcel_Time = as.POSIXct(character()),
  First_IssueParcel_Site = character(length = nr),
  First_delivery_Time = as.POSIXct(character()),
  First_delivery_Site = character(length = nr),
  # Counter
  Max_Attempt = integer(length = nr),
  IssueParcel_Scan_Count = integer(length = nr),
  Delivery_Scan_Count = integer(length = nr),
  First_Attempt_Type = character(length = nr)
)
)
}

# p = create_TBL_Attempt_TABLE(length(AWB))
# p$AWB <- AWB
# p %>% left_join(l_attempt_df, by = c("AWB" = "AWB"))
# p %>% left_join(l_attempt_df)
