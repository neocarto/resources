# Packages

library(sf)
library(geojsonsf)

# Import data

migr <- read.csv("data/fij/migr2019_T.csv")
countries <- st_read("data/geom/countries.gpkg")
subregions <- st_read("data/geom/subregions.gpkg")

# Aggregation by subregions

keys <- data.frame(countries[,c("adm0_a3_is","Code2")])
keys$geom <- NULL
migr <- merge(x = migr, y = keys, by.x = "i", by.y = "adm0_a3_is")
colnames(migr)[4] <- "subreg_i"
migr <- merge(x = migr, y = keys, by.x = "j", by.y = "adm0_a3_is")
colnames(migr)[5] <- "subreg_j"
migr$id <- paste0(migr$subreg_i,"_",migr$subreg_j)
flows <- aggregate(migr$fij, by=list(migr$id), FUN = sum)
flows$i <- sapply(strsplit(flows$Group.1, "_"), "[", 1)
flows$j <- sapply(strsplit(flows$Group.1, "_"), "[", 2)
flows <- flows[,c("i","j","x")]
colnames(flows)[3] <- "fij"
flows$fij <- round(flows$fij/1000,0)

# stock_intra

stock_intra <- flows[flows$i == flows$j,c("i","fij")]
colnames(stock_intra) <- c("id","intra")
flows <-  flows[flows$i != flows$j,]

# Stock_i

stock_i <- aggregate(flows$fij, by=list(flows$i), FUN = sum)
colnames(stock_i) <- c("id","from")

# Stock_j

stock_j <- aggregate(flows$fij, by=list(flows$j), FUN = sum)
colnames(stock_j) <- c("id","to")

# Merge

subregions <- merge(x = subregions, y = stock_intra, by = "id")
subregions <- merge(x = subregions, y = stock_i, by = "id")
subregions <- merge(x = subregions, y = stock_j, by = "id")

# Export

if(!dir.exists("data/regional")){dir.create("data/regional")}
st_write(subregions, dsn = "data/regional/subregions.geojson")

