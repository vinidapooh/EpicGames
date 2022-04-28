#Epic Games Fortnite

import pandas as pd
import numpy as np
from datetime import datetime
import re


path = 'Epic Games Raw.xlsx'

#reading the datasets and assigning to objects
EC_Raw_Delivery = pd.read_excel(path,sheet_name = 'Delivery',header = 0,usecols = "A:I")
EC_Raw_Conversions = pd.read_excel(path,sheet_name = 'Conversions',header = 0, usecols = "A:L")
EC_Raw_Linemap = pd.read_excel(path,sheet_name = 'Line Mapping',header = 0,usecols = "A:B")
EC_Raw_RLmap = pd.read_excel(path,sheet_name = 'RL Map',header = 0,usecols = "A:B")


Deliveryraw_Fortnite = pd.merge(EC_Raw_Delivery,EC_Raw_RLmap,how = 'outer', on = 'Line Item')#mapping RL Line IDs
Deliveryraw_Fortnite = Deliveryraw_Fortnite[Deliveryraw_Fortnite['RL'].isnull()]
Deliveryraw_Fortnite = Deliveryraw_Fortnite.drop(columns = ['RL'],axis = 0) #We now have the RL data separated, so we remove the RL column

#Creating new columns in Delivery raw report to match Conversions raw tab
Deliveryraw_Fortnite['Click Based Conversions'] = ""
Deliveryraw_Fortnite['View Based Conversions'] = ""
Deliveryraw_Fortnite['ProductDisplayName'] = ""
Deliveryraw_Fortnite['Revenue'] = ""
Deliveryraw_Fortnite['Sum of Revenue_Click'] = ""
Deliveryraw_Fortnite['Sum of Revenue_View'] = ""



#Filtering out Fortnite data

EC_Conversions_Fortnite = EC_Raw_Conversions[EC_Raw_Conversions['BannerName'].str.contains('Fortnite')]


#Adding columns of Delivery Report into Conversions to match headers
EC_Conversions_Fortnite['Impressions'] = ""
EC_Conversions_Fortnite['Clicks'] = ""
EC_Conversions_Fortnite['CTR%'] = ""
EC_Conversions_Fortnite['Budget Delivered'] = ""

EC_Conversions_Fortnite = EC_Conversions_Fortnite.rename(columns = {'MediaPlanLineName':'Line Name'})     #Changing column name in Conversions Raw

#Re-arranging column order in Conversions report.
Conv_col = ['PurchaseTime','Campaign Name','LineId','Line Name','BannerName','Impressions','Clicks','CTR%','Budget Delivered','Click Based Conversions','View Based Conversions','ProductDisplayName','Revenue']

EC_Conversions_Fortnite = EC_Conversions_Fortnite[Conv_col]    #Updating new column order

#Changing column names in Delivery Reports
Deliveryraw_Fortnite = Deliveryraw_Fortnite.rename(columns = {'Date':'PurchaseTime','Line Item Name / Target':'Line Name','Line Item':'LineId','Creative Name':'BannerName'})

#Re-arranging column order in Delivery Reports
Delv_col = ['PurchaseTime','Campaign Name','LineId','Line Name','BannerName','Impressions','Clicks','CTR%','Budget Delivered','Click Based Conversions','View Based Conversions','ProductDisplayName','Revenue']

Deliveryraw_Fortnite = Deliveryraw_Fortnite[Delv_col]       #Updating new Column order on delivery raw report

combined_Fortnite = pd.concat([EC_Conversions_Fortnite,Deliveryraw_Fortnite])   #combine Conversions and Delivery raw reports into one report, Combined.


#Date formatting and sorting by date
combined_Fortnite['PurchaseTime'] = pd.to_datetime(combined_Fortnite['PurchaseTime']).dt.date
combined_Fortnite = combined_Fortnite.sort_values(by = "PurchaseTime", ascending = True)
Deliveryraw_Fortnite['PurchaseTime'] = pd.to_datetime(Deliveryraw_Fortnite['PurchaseTime']).dt.date
Deliveryraw_Fortnite = Deliveryraw_Fortnite.sort_values(by = "PurchaseTime", ascending = True)
EC_Conversions_Fortnite['PurchaseTime'] = pd.to_datetime(EC_Conversions_Fortnite['PurchaseTime']).dt.date
EC_Conversions_Fortnite = EC_Conversions_Fortnite.sort_values(by = "PurchaseTime",ascending = True)

#Adding New Columns based on extraction
combined_Fortnite['Targeting'] = np.where(combined_Fortnite['Line Name'].str.contains("not DL'ed|Not DL'ed"),"Acquisition","Retention")
combined_Fortnite['Region'] = combined_Fortnite['Line Name'].str[:2]

combined_Fortnite['Week'] = combined_Fortnite['PurchaseTime']-pd.offsets.Week(weekday = 0)
combined_Fortnite['Week'] = pd.to_datetime(combined_Fortnite['Week']).dt.date

combined_Fortnite['Day of Week'] = pd.to_datetime(combined_Fortnite['PurchaseTime']).dt.strftime('%A')

combined_Fortnite['PlacementLocation'] = np.where(combined_Fortnite['BannerName'].str.contains("416x216"),"Home","Store")
combined_Fortnite['RBvsRot'] = np.where(combined_Fortnite['Line Name'].str.contains("Rotational"),"Rotational","Roadblock")
combined_Fortnite['Sweeps/NonSweeps'] = np.where(combined_Fortnite['BannerName'].str.contains("Sweeps"),"Sweeps","NonSweeps")
combined_Fortnite['AV'] = np.where(combined_Fortnite['Line Name'].str.contains("AV"),"AV","")


#Writing the datasets to Excel file.
writer = pd.ExcelWriter('Epic Games Fortnite_Python.xlsx')
combined_Fortnite.to_excel(writer,sheet_name = 'Combined',index = False)
EC_Conversions_Fortnite.to_excel(writer,sheet_name = 'Conversions',index = False)
Deliveryraw_Fortnite.to_excel(writer,sheet_name = 'Delivery',index = False)

writer.close()