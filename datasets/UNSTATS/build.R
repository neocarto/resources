library(readxl)
library(countrycode)
library(geojsonsf)
library(sf)

# Nomenclature

nomenclature <- sf <- geojson_sf("UNSTATS/world.geojson")

# GDP from UNSTATS

un <- data.frame(read_xlsx("UNSTATS/Download-GDPcurrent-USD-countries.xlsx", skip = 2))
un <- un[un$IndicatorName == "Total Value Added",]
un <- un[,c("CountryID", "Country", "X2019")]

# Merge

gdp <- merge(x = nomenclature, y = un, by.x = "ISONUM", by.y ="CountryID", all.x = TRUE)
# gdp <- gdp[!is.na(gdp$X2019),] %>% st_drop_geometry()
gdp <- gdp %>% st_drop_geometry()
gdp <- gdp[,c("ISO3", "NAMEfr", "NAMEen", "X2019")]
colnames(gdp) <- c("ISO3", "NAMEfr", "NAMEen", "GDP2019")
write.csv(gdp, "gdp2019.csv")
