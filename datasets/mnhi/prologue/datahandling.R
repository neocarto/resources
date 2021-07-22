# Nicolas Lambert, 2022
# MNHI Project

library(readxl)

file = "NAT_ETR_FRANCE.xlsx"
excel_sheets(file)


years = c(1851, 1891,1931,1975,2017)

for(i in years){

tmp = cbind(date = i,data.frame(read_excel(file, paste0("NAT_ETR_",i), col_types = "text")))

if (i == years[1]){
  df = tmp 
} else {
  df = rbind(df,tmp)  
  }

}

library(sf)
world = st_read("https://gisco-services.ec.europa.eu/distribution/v2/countries/geojson/CNTR_RG_20M_2020_4326.geojson")
centroids = cbind(world %>% st_drop_geometry(), st_coordinates(st_centroid(st_geometry(world), of_largest_polygon = TRUE)) )
centroids = centroids[,c("id","X","Y")]
colnames(centroids) = c("id","lon","lat")
centroids[centroids$id == "EL","id"] = "GR"
centroids[centroids$id == "UK","id"] = "GB"
mydata = merge(x = df, y = centroids, by.x = "ISO2", by.y = "id", all.x = TRUE)

# missing localisations


setcoords = function(id, lat, lon, from = NA){
if(is.na(from)){
    mydata[mydata$ISO2 == id,"lon"] <- lon
    mydata[mydata$ISO2 == id,"lat"] <- lat
    } else {
      mydata[mydata$ISO2 == id,"lon"] <- mydata[mydata$ISO2 == from,"lon"][1]
      mydata[mydata$ISO2 == id,"lat"] <- mydata[mydata$ISO2 == from,"lat"][1]
    }
  return (mydata)
  }

mydata = setcoords("TW",23.730677315574205, 121.00832282814801)
mydata = setcoords("AU_NZ", from = "AU")
mydata = setcoords("CZ_SK",49.12005447425446, 18.064818007974004)
mydata = setcoords("EE_LV_LT",from = "LV")
mydata = setcoords("SY_LB",34.49458621095529, 37.11036640410309)
mydata = setcoords("RO_RS_BG",from = "RS")
mydata = setcoords("SI_HR_BA_ME_RS_MK_XK",from = "RS")
mydata = setcoords("Oce",from = "AU")
mydata = setcoords("Eur",from = "DE")
mydata = setcoords("Asie",34.47667454516556, 94.5527033749495)
mydata = setcoords("AdN", from = "US")
mydata = setcoords("AdC",315.84424661740091, -90.23458912356887)
mydata = setcoords("AdS",-12.603453714772108, -56.47953026441623)
mydata = setcoords("Ame",-12.603453714772108, -56.47953026441623)
mydata = setcoords("Afr",3.1839195197532746, 24.17584029494345)
mydata = setcoords("Ame_Oce",from = "AU")

write.csv(mydata,"nat_etr_france.csv")
