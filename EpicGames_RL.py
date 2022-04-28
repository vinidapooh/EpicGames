#Epic Games Rocket League

import pandas as pd
import numpy as np
from datetime import datetime


path = 'Epic Games Raw.xlsx'

#reading the datasets and assigning to objects
EC_Raw_Delivery = pd.read_excel(path,sheet_name = 'Delivery',header = 0,usecols = "A:I")
EC_Raw_Conversions = pd.read_excel(path,sheet_name = 'Conversions',header = 0, usecols = "A:L")
EC_Raw_Linemap = pd.read_excel(path,sheet_name = 'Line Mapping',header = 0,usecols = "A:B")
EC_Raw_RLmap = pd.read_excel(path,sheet_name = 'RL Map',header = 0,usecols = "A:B")


Deliveryraw_RL = pd.merge(EC_Raw_Delivery,EC_Raw_RLmap,how = 'inner', on = 'Line Item') #mapping RL Line IDs
Deliveryraw_RL = Deliveryraw_RL.drop(columns = ['RL'],axis = 0) #We now have the RL data separated, so we remove the RL column

#Creating new columns in Delivery raw report to match Conversions raw tab
Deliveryraw_RL['Click Based Conversions'] = ""
Deliveryraw_RL['View Based Conversions'] = ""
Deliveryraw_RL['ProductDisplayName'] = ""
Deliveryraw_RL['Revenue'] = ""
Deliveryraw_RL['Sum of Revenue_Click'] = ""
Deliveryraw_RL['Sum of Revenue_View'] = ""

#Filtering Rocket League data based on Banner Name contains 'RocketLeague'
EC_Conversions_RL = EC_Raw_Conversions[EC_Raw_Conversions['BannerName'].str.contains('RocketLeague')]


#Adding columns of Delivery Report into Conversions to match headers
EC_Conversions_RL['Impressions'] = ""
EC_Conversions_RL['Clicks'] = ""
EC_Conversions_RL['CTR%'] = ""
EC_Conversions_RL['Budget Delivered'] = ""


#Re-arranging column order in Conversions report.
Conv_col = ['PurchaseTime','Campaign Name','LineId','MediaPlanLineName','BannerName','Impressions','Clicks','CTR%','Budget Delivered','Click Based Conversions','View Based Conversions','ProductDisplayName','Revenue','Sum of Revenue_Click','Sum of Revenue_View']

EC_Conversions_RL = EC_Conversions_RL[Conv_col]    #Updating new column order
EC_Conversions_RL = EC_Conversions_RL.rename(columns = {'MediaPlanLineName' : 'Line Name'})

#Changing column names in Delivery Reports
Deliveryraw_RL = Deliveryraw_RL.rename(columns = {'Date':'PurchaseTime','Line Item Name / Target':'Line Name','Line Item':'LineId','Creative Name':'BannerName'})

#Re-arranging column order in Delivery Reports
Delv_col = ['PurchaseTime','Campaign Name','LineId','Line Name','BannerName','Impressions','Clicks','CTR%','Budget Delivered','Click Based Conversions','View Based Conversions','ProductDisplayName','Revenue','Sum of Revenue_Click','Sum of Revenue_View']

Deliveryraw_RL = Deliveryraw_RL[Delv_col]       #Updating new Column order on delivery raw report

combined_RL = pd.concat([EC_Conversions_RL,Deliveryraw_RL])   #combine Conversions and Delivery raw reports into one report, Combined.


#Date formatting and sorting by date
combined_RL['PurchaseTime'] = pd.to_datetime(combined_RL['PurchaseTime']).dt.date
combined_RL = combined_RL.sort_values(by = "PurchaseTime", ascending = True)
Deliveryraw_RL['PurchaseTime'] = pd.to_datetime(Deliveryraw_RL['PurchaseTime']).dt.date
Deliveryraw_RL = Deliveryraw_RL.sort_values(by = "PurchaseTime", ascending = True)
EC_Conversions_RL['PurchaseTime'] = pd.to_datetime(EC_Conversions_RL['PurchaseTime']).dt.date
EC_Conversions_RL = EC_Conversions_RL.sort_values(by = "PurchaseTime",ascending = True)

#Adding New Columns based on extraction
combined_RL['Targeting'] = np.where(combined_RL['Line Name'].str.contains("not DL'ed|Not DL'ed"),"Acquisition","Retention")
combined_RL['Region'] = combined_RL['Line Name'].str[:2]

combined_RL['Week'] = combined_RL['PurchaseTime']-pd.offsets.Week(weekday = 0)
combined_RL['Week'] = pd.to_datetime(combined_RL['Week']).dt.date

combined_RL['Day of Week'] = pd.to_datetime(combined_RL['PurchaseTime']).dt.strftime('%A')

combined_RL['PlacementLocation'] = np.where(combined_RL['BannerName'].str.contains("416x216"),"Home","Store")
combined_RL['RBvsRot'] = np.where(combined_RL['Line Name'].str.contains("Rotational"),"Rotational","Roadblock")
combined_RL['Sweeps/NonSweeps'] = np.where(combined_RL['BannerName'].str.contains("Sweeps"),"Sweeps","NonSweeps")


#Writing the datasets to Excel file.
writer = pd.ExcelWriter('Epic Games RL_Python.xlsx')
combined_RL.to_excel(writer,sheet_name = 'Combined',index = False)
EC_Conversions_RL.to_excel(writer,sheet_name = 'Conversions',index = False)
Deliveryraw_RL.to_excel(writer,sheet_name = 'Delivery',index = False)

writer.close()
