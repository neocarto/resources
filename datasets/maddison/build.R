library(readxl)
library(sf)
library(geojsonsf)
library(rgdal)

# DATA FILE

maddison = data.frame(read_excel("data/mpd2020.xlsx", sheet = "Full data"))
maddison <- maddison[maddison$year>=1950,]
maddison$gdp <- maddison$gdppc * maddison$pop / 1000000

# maddison[maddison$countrycode=="FRA" & maddison$year==2018,]

# Geometries

countries <- st_read("data/world_countries_data.shp")
countries <- countries[,c("ISO3", "NAMEen", "NAMEfr","geometry")]
colnames(countries) <- c("id", "NAMEen", "NAMEfr","geometry")

# Former Sudan

list <- c("SSD", "SDN") 
df <- data.frame(id = "SDN", NAMEen = "Sudan (former)", NAMEfr = "Soudan")
geom <- st_union(st_geometry(countries[countries$id %in% list,]))
SDN <- st_as_sf(geometry = geom, df)
countries <- countries[!countries$id %in% list,]
countries <- rbind(countries,SDN)

# Czechoslovakia

list <- c("SVK","CZE")
df <- data.frame(id = "CSK", NAMEen = "Czechoslovakia", NAMEfr = "Tchécoslovaquie")
geom <- st_union(st_geometry(countries[countries$id %in% list,]))
CSK <- st_as_sf(geometry = geom, df)
countries <- rbind(countries,CSK)

# Former Yugoslavia

list <- c("SVN","HRV","BIH","SRB", "MNE","MKD","KOS")
df <- data.frame(id = "YUG", NAMEen = "Former Yugoslavia", NAMEfr = "Ex-Yougoslavie")
geom <- st_union(st_geometry(countries[countries$id %in% list,]))
YUG <- st_as_sf(geometry = geom, df)
countries <- rbind(countries,YUG)

# Former USSR

list <- c("RUS","UKR","BLR","MDA","UZB","KAZ","KGZ","TJK","TKM","GEO","AZE","ARM","LTU","LVA","EST")
df <- data.frame(id = "SUN", NAMEen = "Former USSR", NAMEfr = "URSS")
geom <- st_union(st_geometry(countries[countries$id %in% list,]))
SUN <- st_as_sf(geometry = geom, df)
countries <- rbind(countries,SUN)

# Export
geojsonio::geojson_write(countries, file = "output/countries.geojson")
write.csv(maddison, "output/maddison.csv", row.names = FALSE)

# # Tests
countries <- st_read("data/world_countries_data.shp")
countries <- countries[,c("ISO3", "NAMEen", "NAMEfr","geometry")]
colnames(countries) <- c("id", "NAMEen", "NAMEfr","geometry")
year = 1973
tmp <- maddison[maddison$year==year,]
# View(tmp)
m <- merge(x = countries, y = tmp, by.x = "id", by.y = "countrycode", all.x = TRUE, all.y = TRUE)
View(m)
x <- as.vector(m[is.na(m$pop),"id"] %>% st_drop_geometry())

plot(st_geometry(countries), col = "red", border = "black")
plot(st_geometry(mm), col = "blue", border = "blue", add=T)

AND
8   ATA
9   ATG
20  BHS
23  BLZ
27  BRN
28  BTN
55  ERI
60  FJI
61  FLK
63  FRO
64  FSM
68  GGY
75  GRD
76  GRL
78  GUY
85  IMN
94  JEY
101 KIR
102 KNA
104 KOS
111 LIE
117 MAC
119 MCO
122 MDV
124 MHL
137 NCL
144 NRU
151 PLW
152 PNG
163 SAH
168 SLB
171 SMR
172 SOM
174 SSD
177 SUR
189 TLS
190 TON
194 TUV
202 VAT
203 VCT
206 VUT
207 WSM
