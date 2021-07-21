# Packages

library(raster)
library(sf)
library(cartography)
library(SpatialPosition)
library(sp)
library(readxl)
library(rgdal)
library(rmapshaper)

# ----------------------
# Data import & handling
# ----------------------

# Total population by age group (Souce : United Nations, Department of Economic and Social Affairs, Population Division (2017). World Population Prospects: The 2017 Revision, DVD Edition.)

pop <- read_excel("../data/WPP2017_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx", sheet = "MEDIUM VARIANT", skip = 16)
pop <- as.data.frame(pop)
pop <- pop[pop[6] == 2015,]
pop$total <- rowSums(pop[,7:27] )
pop$children <- rowSums(pop[,7:9])


pop <-  pop[,c("Country code", "Region, subregion, country or area *","children","total")]
pop$share <- pop$children/pop$total
pop <- pop[,c("Country code","Region, subregion, country or area *","share")]
colnames(pop) <- c("id","name","share")

# Countries

world <- st_read(dsn = "../data/world_countries_data.shp", stringsAsFactors = F)
fields <- c("ISONUM", "NAMEfr")
world <- world[,fields]
world <- st_transform(world,"+proj=longlat +datum=WGS84 +no_defs ")

# population grid

# r <- raster("../data/gpw_v4_population_density_adjusted_to_2015_unwpp_country_totals_rev10_2015_1_deg.asc")
# fact <- 2
r <- raster("../data/gpw_v4_population_count_adjusted_to_2015_unwpp_country_totals_rev11_2020_30_min.tif")
st_crs(r)
fact <- 5
dots <- aggregate(r, fact=fact, fun=sum)
dots <- as(dots, 'SpatialPointsDataFrame')
dots <- st_as_sf(dots)
dots <- st_transform(dots, crs(world))
colnames(dots) <- c("pop","geometry")



# Nearest country -> id codes
for (i in 1:dim(dots)[1]){
  countries <- world
  dot <- dots[i,]
  d <- st_distance(countries, dot, by_element = TRUE,  which = "distance")
  countries$dist <- as.numeric(d)
  min <- min(countries$dist)
  myid <- countries$ISONUM[countries$dist == min][1]
  dots[i,"id"] <- myid
}


# get nb of children by dots

dots <- merge(x = dots, y = pop, by = "id", all.x=T)
dots$children <- dots$pop * dots$share
colnames(dots)
dots <- dots[,c("id","name","children","geometry")]


# plot(st_geometry(countries), col="#CCCCCC", border="white")
# plot(st_geometry(dots), col="black", pch=20,add=T)
# plot(st_geometry(dots[is.na(dots$share),]), col="red", pch=20, add=T)

dots$children <- round(dots$children,0)
dots$children[is.na(dots$children)] <- 0
dots <- dots[dots$children > 0,]
dots$children <- dots$children / 1000

st_write(dots, "../output/dots.shp", append = FALSE)

# -----------
# LISSAGE
# -----------

dots <- read_sf("../output/dots.shp")

min(dots$children, na.rm=T)
max(dots$children, na.rm=T)

dots$id <- c(1:nrow(dots))

pot <- quickStewart(x = dots,
                    var = "children",
                    span = 500000,
                    breaks = c(0, 100, 200, 500, 1000, 2000, 5000, 10000, 20000 ,50000, 70000, 100000, 130000  ),
                    resolution = 1,
                    beta = 2, 
                    returnclass = "sf")

st_write(pot,"../output/smooth_big.shp")

plot(st_geometry(pot))

# Simplification

x <- st_read("../output/smooth_big.shp")
smooth <- ms_simplify(x, keep = 0.25)

# Clip
land <- st_read(dsn = "../data/land.shp", stringsAsFactors = F)
smooth2 <- st_intersection(smooth,land)

# Group

tmp <- smooth2 %>%  
  split(.$id) %>% 
  lapply(st_union) %>% 
  do.call(c, .) %>% # bind the list element to a single sfc
  st_cast() 

output <- smooth2[c(1:13),]
output$geometry <- tmp

# Colors

output$col <- c("#5A9974","#8FC7A8","#D2E2CA","#F9F7D3","#FFEDA0","#FFD977","#F9B14E","#F28B41","#E95032","#E31C1E","#BD1829","#7F152A","#520D22")
output <- output[,c("id","min","max","center","col","geometry")]

# Export
st_write(output, "../output/smooth.shp")

# Tanaka

x <- st_read("../output/smooth.shp")

x2 <- x
x3 <- x
st_geometry(x2) <- st_geometry(x) + c(0.4,-0.4)
st_crs(x2) <- st_crs(x)
x2$col <- "#ffffff"
st_geometry(x3) <- st_geometry(x) + c(-0.4,0.4)
st_crs(x3) <- st_crs(x)
x3$col <- "#545252"

smooth_tanaka <- x[0,]
nb <- nrow(x)
for (i in 1:nb){
  smooth_tanaka <- rbind(smooth_tanaka, x[i,])
  smooth_tanaka <- rbind(smooth_tanaka, x2[i,])
  smooth_tanaka <- rbind(smooth_tanaka, x3[i,])
 }

st_write(smooth_tanaka, "../output/smooth_tanaka.shp")
