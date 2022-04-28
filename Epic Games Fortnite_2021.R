EpicGames_Fortnite_2021 <- function() {
  
  
  library(tidyverse)
  library(dplyr)
  library(readxl)
  library(writexl)
  library(magrittr)
  library(lubridate)
  
  
  
  EC_Raw <- read_excel("Documents/Epic Games R/Epic Games Raw.xlsx")
  
  EC_Raw_Delivery <- read_excel("Documents/Epic Games R/Epic Games Raw.xlsx",sheet = "Delivery")
  EC_Raw_Conversions <- read_excel("Documents/Epic Games R/Epic Games Raw.xlsx",sheet = "Conversions")
  EC_Linemap <- read_excel("Documents/Epic Games R/Epic Games Raw.xlsx",sheet = "Line Mapping")
  EC_RLmap <- read_excel("Documents/Epic Games R/Epic Games Raw.xlsx",sheet = "RL Map")
  
  #Differentiate between RL and Fortnite
  Delivery_semis <- merge(EC_Raw_Delivery,EC_RLmap, by.x = "Line Item", all.x  = TRUE)
  
  #Delivery Report for Fortnite
  Delivery_final_Fortnite <- Delivery_semis %>% select(Date,`Campaign Name`,'Line Item',`Line Item Name / Target`,`Creative Name`,'Impressions','Clicks',`CTR%`,`Budget Delivered`,`RL`) %>% filter(is.na(`RL`))
  
  Delivery_final_Fortnite <- subset(Delivery_final_Fortnite, select = -c(`RL`))  #Remove RL column
  
  
  
  
  #Adding columns to Delivery_final_Fortnite
  
  Delivery_final_Fortnite[,"Click Based Conversions"] <- Delivery_final_Fortnite
  Delivery_final_Fortnite[,"View Based Conversions"] <- Delivery_final_Fortnite
  Delivery_final_Fortnite[,"ProductDisplayName"] <- Delivery_final_Fortnite
  Delivery_final_Fortnite[,"Revenue"] <- Delivery_final_Fortnite
  Delivery_final_Fortnite[,"Sum of Revenue_Click"] <- Delivery_final_Fortnite
  Delivery_final_Fortnite[,"Sum of Revenue_View"] <- Delivery_final_Fortnite
  
  
  #Converting them to blanks
  Delivery_final_Fortnite$`Click Based Conversions` <- " "
  Delivery_final_Fortnite$`View Based Conversions` <- " "
  Delivery_final_Fortnite$`ProductDisplayName` <- " "
  Delivery_final_Fortnite$`Revenue` <- " "
  Delivery_final_Fortnite$`Sum of Revenue_Click` <- " "
  Delivery_final_Fortnite$`Sum of Revenue_View` <- " "
  
  
  
  #Conversions Report Processing
  
  names(EC_RLmap)[1] <- "LineId"                                                                          #changing the name in mapping to match Column Name in Conversions report
  EC_Raw_Conversions_semis <- merge(EC_Raw_Conversions,EC_RLmap,by.x = "LineId",all.x = TRUE)              #map by lineIDs
  Conversions_map_Fortnite <- EC_Raw_Conversions_semis%>%select(everything()) %>% filter(is.na(RL))      #filtering out those which are not RL rows
  Conversions_map_Fortnite <- subset(Conversions_map_Fortnite, select = -c(RL))                          #deleting RL column, as it's only a differentiator
  
  
  #making new columns for Fortnite
  Conversions_map_Fortnite [,"Impressions"]  <- Conversions_map_Fortnite
  Conversions_map_Fortnite [,"Clicks"] <- Conversions_map_Fortnite
  Conversions_map_Fortnite [,"CTR%"] <- Conversions_map_Fortnite
  Conversions_map_Fortnite [,"Budget Delivered"] <- Conversions_map_Fortnite
  
  
  
  #Removing data for Fortnite
  Conversions_map_Fortnite$Impressions <- " "
  Conversions_map_Fortnite$Clicks <- " "
  Conversions_map_Fortnite$`CTR%` <- " "
  Conversions_map_Fortnite$`Budget Delivered` <- " "
  
  Conversions_Fortnite <- Conversions_map_Fortnite %>% select(PurchaseTime,`Campaign Name`,LineId,MediaPlanLineName,BannerName,Impressions,Clicks,`CTR%`,`Budget Delivered`,`Click Based Conversions`,`View Based Conversions`,ProductDisplayName,Revenue,`Sum of Revenue_Click`,`Sum of Revenue_View`)
  
  
  
  
  #Renaming columns to append data
  
  #Delivery Report Fornite
  names(Delivery_final_Fortnite)[1] <- "PurchaseTime"
  names(Delivery_final_Fortnite)[3] <- "LineId" 
  names(Delivery_final_Fortnite)[4] <- "Line Name" 
  names(Delivery_final_Fortnite)[5] <- "BannerName" 
  names(Delivery_final_Fortnite)[12] <- "ProductDisplayName"
  
  
  
  
  #Conversions Report renaming
  
  names(Conversions_Fortnite)[4] <- "Line Name"  #turn to Line Name from Match, after lookup 
  
  Conversions_Fortnite$Impressions <- as.numeric(Conversions_Fortnite$Impressions)
  Conversions_Fortnite$Clicks<- as.numeric(Conversions_Fortnite$Clicks)
  Conversions_Fortnite$`CTR%`<- as.numeric(Conversions_Fortnite$`CTR%`)
  Conversions_Fortnite$`Budget Delivered`<- as.numeric(Conversions_Fortnite$`Budget Delivered`)
  
  
  
  Delivery_final_Fortnite$`Click Based Conversions` <- as.numeric(Delivery_final_Fortnite$`Click Based Conversions`)
  Delivery_final_Fortnite$`View Based Conversions` <- as.numeric(Delivery_final_Fortnite$`View Based Conversions`)
  
  Delivery_final_Fortnite$`Revenue` <- as.numeric(Delivery_final_Fortnite$`Revenue`)
  Delivery_final_Fortnite$`Sum of Revenue_Click` <- as.numeric(Delivery_final_Fortnite$`Sum of Revenue_Click`)
  Delivery_final_Fortnite$`Sum of Revenue_View` <- as.numeric(Delivery_final_Fortnite$`Sum of Revenue_View`)
  
  
  
  #fixing dates
  Delivery_final_Fortnite$PurchaseTime <- as.Date(Delivery_final_Fortnite$PurchaseTime)
  
  
  Conversions_Fortnite$PurchaseTime <- as.Date(Conversions_Fortnite$PurchaseTime)
  
  combinedfinal_Fortnite<- bind_rows(Conversions_Fortnite,Delivery_final_Fortnite)    
  
  #Acquisition and Retention assignment
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, A_R = ifelse(regexpr("E",combinedfinal_Fortnite$`Line Name`) > 0,"Acquisition","Retention"))
  
  #Extract Region from Line Item Name
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, Region = substr(combinedfinal_Fortnite$`Line Name`,1,2))
  
  #Extract Weekday 
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, Week = combinedfinal_Fortnite$PurchaseTime-wday(combinedfinal_Fortnite$PurchaseTime,label = FALSE,week_start = 1)+1)
  
  
  #Extract Week of Day
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, `Day of Week` = wday(combinedfinal_Fortnite$PurchaseTime,label = TRUE,abbr = FALSE))
  
  
  #Home vs Store
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, PlacementLocation = ifelse(regexpr("416x216",combinedfinal_Fortnite$`BannerName`) > 0,"Home","Store"))
  
  
  #Roadblock vs Rotational
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, RBvsRot = ifelse(regexpr("Roadblock",combinedfinal_Fortnite$`Line Name`) > 0,"Roadblock","Rotational"))
  
  
  #Sweep vs Non Sweep
  
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, `Sweeps/NonSweeps` = ifelse(regexpr("Sweeps",combinedfinal_Fortnite$`BannerName`) > 0,"Sweeps","Non Sweeps"))
  combinedfinal_Fortnite<- mutate(combinedfinal_Fortnite, `AV` = ifelse(regexpr("AV",combinedfinal_Fortnite$`Line Name`) > 0,"AV",""))
  
  #Arranging in Ascending order by Date
  combinedfinal_Fortnite<-combinedfinal_Fortnite%>%arrange(combinedfinal_Fortnite$PurchaseTime)
  Delivery_final_Fortnite<-Delivery_final_Fortnite%>%arrange(Delivery_final_Fortnite$PurchaseTime)
  Conversions_Fortnite<-Conversions_Fortnite%>%arrange(Conversions_Fortnite$PurchaseTime)
  
  #compiling
  
  sheets_Fortnite<- list("Delivery" = Delivery_final_Fortnite, "Conversions" = Conversions_Fortnite, "Combined" = combinedfinal_Fortnite)
  
  write_xlsx(sheets_Fortnite, "Epic Games Client Fortnite.xlsx")
  
}
