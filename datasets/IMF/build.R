library(readxl)
library(countrycode)
library(geojsonsf)

# Nomenclature

url = "https://gitlab.huma-num.fr/nlambert/resources/-/raw/master/basemaps/world_countries.geojson"
nomenclature <- sf <- geojson_sf(url)
nomenclature <- nomenclature[,c("ISO3","NAMEfr","NAMEen")]

# GDP from IMF (https://www.imf.org/external/datamapper/NGDPD@WEO/OEMDC/ADVEC/WEOWORLD)

imf <- data.frame(read_xls("IMF/imf-dm-export-20210323 (1).xls"))
imf$iso3c = countrycode(imf[,1], 'country.name', 'iso3c')
imf <- imf[,c("iso3c","GDP..current.prices..Billions.of.U.S..dollars.","X2021")]
colnames(imf) <- c("iso3c","name","gdp")

# Check nomenclature

gdp <- merge(x = nomenclature, y = imf, by.x = "ISO3", by.y ="iso3c", all.x = TRUE)
gdp$source[!is.na(gdp$gdp)] <- "IMF (2021)"

# On bouche les trous avec World bank

wb <- data.frame(read_xls("WorldBank/API_NY.GDP.MKTP.CD_DS2_en_excel_v2_2055584.xls", skip = 3))

# Cuba
gdp[gdp$ISO3 == "CUB","gdp"] <- wb[wb$Country.Code =="CUB", "X2018"] / 1000000000
gdp[gdp$ISO3 == "CUB","source"] <- "World Bank (2018)" 
# Andora
gdp[gdp$ISO3 == "AND","gdp"] <- wb[wb$Country.Code =="AND", "X2019"] / 1000000000
gdp[gdp$ISO3 == "AND","source"] <- "World Bank (2019)" 
# Greenland
gdp[gdp$ISO3 == "GRL","gdp"] <- wb[wb$Country.Code =="GRL", "X2018"] / 1000000000
gdp[gdp$ISO3 == "GRL","source"] <- "World Bank (2018)" 
# Lebanon
gdp[gdp$ISO3 == "LBN","gdp"] <- wb[wb$Country.Code =="LBN", "X2019"] / 1000000000
gdp[gdp$ISO3 == "LBN","source"] <- "World Bank (2019)" 
# Pakistan
gdp[gdp$ISO3 == "PAK","gdp"] <- wb[wb$Country.Code =="PAK", "X2019"] / 1000000000
gdp[gdp$ISO3 == "PAK","source"] <- "World Bank (2019)" 
# Syria
gdp[gdp$ISO3 == "SYR","gdp"] <- wb[wb$Country.Code =="SYR", "X2007"] / 1000000000
gdp[gdp$ISO3 == "SYR","source"] <- "World Bank (2007)" 
# Faroe Island
gdp[gdp$ISO3 == "FRO","gdp"] <- wb[wb$Country.Code =="FRO", "X2018"] / 1000000000
gdp[gdp$ISO3 == "FRO","source"] <- "World Bank (2018)" 
# Isle of Man 
gdp[gdp$ISO3 == "IMN","gdp"] <- wb[wb$Country.Code =="IMN", "X2018"] / 1000000000
gdp[gdp$ISO3 == "IMN","source"] <- "World Bank (2018)" 

View(gdp)
View(wb)

wb[wb$Country.Code =="IMN",]

IMN
JEY
KOS
LIE
MCO
NCL
PRK
SAH
VAT
