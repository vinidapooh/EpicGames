EpicGames_RocketLeague_2021 <- function() {
  
  
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
  
  
  #Delivery Report for Rocket League
  Delivery_final_RL <- Delivery_semis %>% select(Date,`Campaign Name`,`Line Item`,`Line Item Name / Target`,`Creative Name`,'Impressions','Clicks',`CTR%`,`Budget Delivered`,`RL`) %>% filter(`RL` == "RL")
  
  Delivery_final_RL <- subset(Delivery_final_RL, select = -c(`RL`))  #Remove RL column
  
  
  
  #Adding columns to Delivery_final_RL
  
  Delivery_final_RL[,"Click Based Conversions"] <- Delivery_final_RL
  Delivery_final_RL[,"View Based Conversions"] <- Delivery_final_RL
  Delivery_final_RL[,"ProductDisplayName"] <- Delivery_final_RL
  Delivery_final_RL[,"Revenue"] <- Delivery_final_RL
  Delivery_final_RL[,"Sum of Revenue_Click"] <- Delivery_final_RL
  Delivery_final_RL[,"Sum of Revenue_View"] <- Delivery_final_RL
  
  
  #Converting them to blanks
  Delivery_final_RL$`Click Based Conversions` <- " "
  Delivery_final_RL$`View Based Conversions` <- " "
  Delivery_final_RL$`ProductDisplayName` <- " "
  Delivery_final_RL$`Revenue` <- " "
  Delivery_final_RL$`Sum of Revenue_Click` <- " "
  Delivery_final_RL$`Sum of Revenue_View` <- " "
  
  Conversions_map_RL <- EC_Raw_Conversions%>%select(everything())%>%filter(grepl("RocketLeague",EC_Raw_Conversions$BannerName))
  
  
  
  #making new columns for RL
  Conversions_map_RL [,"Impressions"]  <- Conversions_map_RL
  Conversions_map_RL [,"Clicks"] <- Conversions_map_RL
  Conversions_map_RL [,"CTR%"] <- Conversions_map_RL
  Conversions_map_RL [,"Budget Delivered"] <- Conversions_map_RL
  
  
  
  #Removing data for RL
  Conversions_map_RL$Impressions <- " "
  Conversions_map_RL$Clicks <- " "
  Conversions_map_RL$`CTR%` <- " "
  Conversions_map_RL$`Budget Delivered`<- " "
  
  
  
  Conversions_RL <- Conversions_map_RL %>% select(PurchaseTime,`Campaign Name`,LineId,MediaPlanLineName,BannerName,Impressions,Clicks,`CTR%`,`Budget Delivered`,`Click Based Conversions`,`View Based Conversions`,ProductDisplayName,Revenue,`Sum of Revenue_Click`,`Sum of Revenue_View`)
  
  
  names(Delivery_final_RL)[1] <- "PurchaseTime" 
  names(Delivery_final_RL)[3] <- "LineId" 
  names(Delivery_final_RL)[4] <- "Line Name" 
  names(Delivery_final_RL)[5] <- "BannerName" 
  names(Delivery_final_RL)[12] <- "ProductDisplayName"
  
  
  names(Conversions_RL)[4] <- "Line Name"  #turn to Line Name from Match, after lookup
  
  #format corrections
  Conversions_RL$Impressions <- as.numeric(Conversions_RL$Impressions)
  Conversions_RL$Clicks<- as.numeric(Conversions_RL$Clicks)
  Conversions_RL$`CTR%`<- as.numeric(Conversions_RL$`CTR%`)
  Conversions_RL$`Budget Delivered`<- as.numeric(Conversions_RL$`Budget Delivered`)
  
  Delivery_final_RL$`Click Based Conversions` <- as.numeric(Delivery_final_RL$`Click Based Conversions`)
  Delivery_final_RL$`View Based Conversions` <- as.numeric(Delivery_final_RL$`View Based Conversions`)
  
  
  Delivery_final_RL$`Revenue` <- as.numeric(Delivery_final_RL$`Revenue`)
  Delivery_final_RL$`Sum of Revenue_Click` <- as.numeric(Delivery_final_RL$`Sum of Revenue_Click`)
  Delivery_final_RL$`Sum of Revenue_View` <- as.numeric(Delivery_final_RL$`Sum of Revenue_View`)
  
  Delivery_final_RL$PurchaseTime <- as.Date(Delivery_final_RL$PurchaseTime)
  
  Conversions_RL$PurchaseTime <- as.Date(Conversions_RL$PurchaseTime)
  
  combinedfinal_RL<- bind_rows(Conversions_RL,Delivery_final_RL)
  
  #Acquisition and Retention assignment
  combinedfinal_RL<- mutate(combinedfinal_RL, Targeting = ifelse(regexpr("not DL'ed|Not DL'ed",combinedfinal_RL$`Line Name`) > 0,"Acquisition","Retention"))
  
  #Extract Region from Line Item Name
  combinedfinal_RL<- mutate(combinedfinal_RL, Region = substr(combinedfinal_RL$`Line Name`,1,2))
  
  #Extract WeekDay 
  combinedfinal_RL<- mutate(combinedfinal_RL, Week = combinedfinal_RL$PurchaseTime-wday(combinedfinal_RL$PurchaseTime,label = FALSE,week_start = 1)+1)
  
  #Extract Week of Day
  combinedfinal_RL<- mutate(combinedfinal_RL, `Day of Week` = wday(combinedfinal_RL$PurchaseTime,label = TRUE,abbr = FALSE))
  
  #Home vs Store
  combinedfinal_RL<- mutate(combinedfinal_RL, PlacementLocation = ifelse(regexpr("416x216",combinedfinal_RL$`BannerName`) > 0,"Home","Store"))
  
  #Roadblock vs Rotational
  combinedfinal_RL<- mutate(combinedfinal_RL, RBvsRot = ifelse(regexpr("Roadblock",combinedfinal_RL$`Line Name`) > 0,"Roadblock","Rotational"))
  
  #Sweep vs Non Sweep
  
  combinedfinal_RL<- mutate(combinedfinal_RL, `Sweeps/NonSweeps` = ifelse(regexpr("Sweeps",combinedfinal_RL$`Line Name`) > 0,"Sweeps","Non Sweeps"))
  
  
  combinedfinal_RL<-combinedfinal_RL%>%arrange(combinedfinal_RL$PurchaseTime)
  Conversions_RL <- Conversions_RL%>%arrange(Conversions_RL$PurchaseTime)
  Delivery_final_RL <- Delivery_final_RL%>%arrange(Delivery_final_RL$PurchaseTime)
  
  
  sheets_RL<- list("Delivery" = Delivery_final_RL, "Conversions" = Conversions_RL, "Combined" = combinedfinal_RL)
  
  
  write_xlsx(sheets_RL, "Epic Games Client RL.xlsx")
  
  
}


