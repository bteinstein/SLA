prep_first_attempt_temp_table <- function(IssueParcelTable, DeliveryScanTable){
  bind_rows(
    # IssueParcel Table
    IssueParcelTable %>% 
      select("BILL_CODE","REGISTRATION_SITE","REGISTRATION_DATE") %>%
      `colnames<-` (c("AWB", "Site", "Time")) %>%
      mutate(AWB_Time = paste0(AWB,"_",Time)) %>%
      mutate(type = "ISP"),
    # Delivery Table
    DeliveryScanTable %>% 
      select("BILL_CODE",SCAN_SITE_CODE,SCAN_DATE) %>% 
      `colnames<-` (c("AWB", "Site", "Time")) %>% 
      mutate(Site = as.character(Site)) %>%
      mutate(AWB_Time = paste0(AWB,"_",Time)) %>%
      mutate(type = "DLV")
      # unite(AWB, Time, sep="_", remove =)
  )
}

get_first_attempt_time_site <- function(attempts_df){
  attempts_df%>% 
  group_by(AWB) %>% 
  summarise(First_Attempt_Time = min(Time), .groups = "drop") %>% 
  mutate(AWB_Time = paste0(AWB,"_",First_Attempt_Time)) %>%
  left_join(
    attempts_df %>% select(AWB_Time, Site,type), 
            by = c("AWB_Time" = "AWB_Time")
    ) %>% 
  # rename(First_Attempt_Site = Site) %>% 
  select(AWB,First_Attempt_Time, First_Attempt_Site = Site, First_Attempt_Type = type)
}

get_last_attempt_time_site <- function(attempts_df){
  attempts_df%>% 
    group_by(AWB) %>% 
    summarise(Last_Attempt_Time = max(Time), .groups = "drop") %>% 
    mutate(AWB_Time = paste0(AWB,"_",Last_Attempt_Time)) %>%
    left_join(
      attempts_df %>% select(AWB_Time, Site), 
      by = c("AWB_Time" = "AWB_Time")
    ) %>% 
    # rename(First_Attempt_Site = Site) %>% 
    select(AWB,Last_Attempt_Time, Last_Attempt_Site = Site)
}


get_attempt_counter <- function(attempts_df) {
  attempt_temp_df %>% 
    count(AWB,type) %>% 
    pivot_wider(names_from = type, values_from = n) %>% 
    select(AWB, IssueParcel_Scan_Count = ISP, Delivery_Scan_Count = DLV) %>% 
    replace_na(list(IssueParcel_Scan_Count = 0, Delivery_Scan_Count = 0))    %>% 
    rowwise(AWB) %>% 
    mutate(Max_Attempt = max(IssueParcel_Scan_Count, Delivery_Scan_Count))
}
