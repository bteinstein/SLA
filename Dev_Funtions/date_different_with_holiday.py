## Package Plan ##
# environment location: /home/bt/.local/share/r-miniconda


# import pandas as pd
# from pandas.tseries.holiday import USFederalHolidayCalendar
# from pandas.tseries.offsets import CustomBusinessDay
# day1 = '2010-01-01'
# day2 = '2010-01-15'
# us_bd = CustomBusinessDay(calendar=USFederalHolidayCalendar())
# 
# print(pd.DatetimeIndex(day1,day2, freq=us_bd))
# print(len(pd.DatetimeIndex(start=day1,end=day2, freq=us_bd)))
# 


import pandas as pd
import numpy as np

date1 = "01/07/2019"
date2 = "08/07/2019"

date1 = pd.to_datetime(date1,format="%d/%m/%Y").date()
date2 = pd.to_datetime(date2,format="%d/%m/%Y").date()

days = np.busday_count( date1 , date2)
print(days)


holidays = pd.to_datetime("04/07/2019",format="%d/%m/%Y").date()
days = np.busday_count( start, end,holidays=[holidays] )
print(days)
