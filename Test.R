library(data.table)
library(readr)
dataset <- data.table(read_csv('../repdata-data-StormData.csv.bz2'))

# Extract a summary of storm data events, a count of each EventType, and combine the two tables. EVCOUNT is forced to double precision, to suppress warning messages from  melt.data.table.
# There is a bug in data.table 1.9.6
StormSum1 <- dataset[, lapply(.SD, sum, na.rm=TRUE), by=EVTYPE, 
                     .SDcols=c('FATALITIES', 'INJURIES', 'PROPDMG', 'CROPDMG')]
StormCount1 <- dataset[, .N, by = EVTYPE]
names(StormCount1)[2] <- 'EVCOUNT'
StormCount1$EVCOUNT <- as.double(StormCount1$EVCOUNT)
setkey(StormSum1,EVTYPE)
setkey(StormCount1,EVTYPE)
StormSum2 <- StormSum1[StormCount1, on='EVTYPE']
# StormSum2 <- merge(StormSum1, StormCount1) has a bug.

# Convert all EventTypes to upper case to reduce variation in Event Types
StormSum4 <- StormSum2 
StormSum2[,EVTYPE := toupper(EVTYPE)]

# Get rid of spelling and punctuation variations.
StormSum2[EVTYPE == 'AVALANCE',  EVTYPE := 'AVALANCHE']
StormSum2[EVTYPE == 'BEACH EROSIN',  EVTYPE := 'BEACH EROSION']
StormSum2[EVTYPE == 'COLD TEMPERATURES',  EVTYPE := 'COLD TEMPERATURE']
StormSum2[EVTYPE == 'TORNDAO',  EVTYPE := 'TORNADO']
StormSum2[EVTYPE == 'WAYTERSPOUT',  EVTYPE := 'WATERSPOUT']
StormSum2[EVTYPE == 'WET MICOBURST',  EVTYPE := 'WET MICROBURST']
StormSum2[EVTYPE %like% 'WINTER WEATHER |/MIX', EVTYPE := 'WINTER WEATHER MIX']
StormSum2[EVTYPE %like% 'WINTE*RY MIX', EVTYPE := 'WINTRY MIX']
StormSum2[EVTYPE == 'UNSEASONABLE COLD',  EVTYPE := 'UNSEASONABLY COLD']

# Goal: THUNDERSTORM WINDS. Lots of different patterns in Grep.
# Starting with TH and ending in NDS
setkey(StormSum2, EVTYPE)
StormSum2[StormSum2[EVTYPE %like% '^TH.'][EVTYPE %like% 'ND$|DS$'], EVTYPE := 'THUNDERSTORM WINDS']
# StormSum1[EVTYPE %like% '^TH.*NDS$', EVTYPE := 'THUNDERSTORM WINDS']
# Starting with TH and ending in IND or INS
# StormSum1[EVTYPE %like% '^TH.*IND$|^TH.*INS$', EVTYPE := 'THUNDERSTORM WINDS']
# Starting with TH and ending in NDS. or ND.
# StormSum1[EVTYPE %like% '^TH.*NDS\\.$|^TH.*ND\\.$', EVTYPE := 'THUNDERSTORM WINDS']

# Melt the summary to prepare for re-calculating the sums for each Event Type.
StormMelt <- melt.data.table(StormSum2, id.vars = 'EVTYPE', variable.name = 'DamageType')

# Redo the summary table, which essentially collapses duplicate rows created by correcting spelling and punctuation variations in EventType.
StormSum3 <- dcast(StormMelt, EVTYPE ~ DamageType, value.var = 'value', fun.aggregate = sum )