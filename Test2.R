library(data.table)

Sample1 <- structure(list(EVTYPE = c("WINTER WEATHER MIX", "WINTER WEATHER/MIX"), 
          FATALITIES = c(0, 28), INJURIES = c(68, 72), PROPDMG = c(60, 4873.5), CROPDMG = c(0, 0)),
          .Names = c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "CROPDMG"), 
          sorted = "EVTYPE", class = c("data.table", "data.frame"))

Sample2 <- structure(list(EVTYPE = c("WINTER WEATHER MIX", "WINTER WEATHER/MIX"), 
          EVCOUNT = c(6, 1104)),  .Names = c("EVTYPE", "EVCOUNT"), 
          sorted = "EVTYPE", class = c("data.table", "data.frame"))

CombinedSample <- Sample1[Sample2, on='EVTYPE']

