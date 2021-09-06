library(dplyr)
Nweekdays <- Vectorize(
  function(a, b, weekend=11)
  {
    # 1 - Saturday and Sunday
    if (weekend == 1) weekenddays = c("Saturday", "Sunday")
    if (weekend == 11) weekenddays = "Sunday"

    ifelse(a < b,
           return(sum(!weekdays(seq(a, b, "days")) %in% weekenddays) - 1),
           return(sum(!weekdays(seq(b, a, "days")) %in% weekenddays) - 1))
  })




Nweekdays2 <- Vectorize(
  function(a, b, weekend=11)
  {
    # 1 - Saturday and Sunday
    if (weekend == 1) weekenddays = c("Saturday", "Sunday")
    if (weekend == 11) weekenddays = "Sunday"
    
    ifelse(a < b,
           # return(sum(!weekdays(seq(a, b, "days")) %in% weekenddays) - 1),
           return(sum(!weekdays(seq(a, b, "days")[!seq(a, b, "days") %in% as.Date(c("2021-06-12", "2021-06-14", "2021-07-20", "2021-07-21", "2021-10-01", "2021-10-19", "2021-12-25", "2021-12-26"))]) %in% weekenddays) - 1),
           # return(sum(!weekdays(seq(b, a, "days")) %in% weekenddays) - 1))
           return(sum(!weekdays(seq(b, a, "days")[!seq(b, a, "days") %in% as.Date(c("2021-06-12", "2021-06-14", "2021-07-20", "2021-07-21", "2021-10-01", "2021-10-19", "2021-12-25", "2021-12-26"))]) %in% weekenddays) - 1)
    )
    
  })



min_vec <- Vectorize(
  function(a, b)
  {
    min(a,b,na.rm = T)
  })





NAindcator <- Vectorize(
  function(v1,v2,v3, v4, v5,v6,v7)
  {
    ifelse(sum(as.numeric(!is.na(c(v1,v2,v3,v4,v5,v6,v7)))) > 0,1,0)
  })

getClientType <- function(Sender){
 Sender 
}



min_vec <- Vectorize(
  function(a, b)
  {
    min(a,b,na.rm = T)
  })


# df = tibble::tibble(d1 = c(as.Date("2021-12-02"), as.Date("2021-12-02"),NA,as.Date("2021-12-01")),
#                     d2 = c(as.Date("2021-10-12"), NA, as.Date("2021-12-02"), as.Date("2021-12-01")),
#                     s1 = c('site A', 'site B','site C','site D'),
#                     s2 = c('site D', 'site C','site B','site A')
#                     )
# 
# df  %>%  mutate(dd = Nweekdays(d1,d2,11))
# 
# 
# get_1stSite <- Vectorize(
#   function(d1,d2,s1,s2){
#     d <- ifelse(!is.na(d1)&!is.na(d2), "",
#                 ifelse(!is.na(d1)&is.na(d2), 
#                 s1, 
#                 ifelse(is.na(d1)&!is.na(d2), 
#                        s2, min(d1,d2))))
#     # if (d== d1) {
#     #   return(s1)
#     # }
#   #   if (min(d1,d2,na.rm = T) == d2) {
#   #    return(s2) 
#   #   }else{
#   #     return('')
#   #   }
#     d
#   }
# )
# 
# df %>% mutate(frstSite = get_1stSite(d1,d2,s1,s2))
