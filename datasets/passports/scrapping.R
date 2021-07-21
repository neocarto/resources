
# LIBRARY

library(rvest)
library(stringr)
library(rnaturalearth)
library(cartography)
library(sf)
library(rmapshaper)
library(reshape2)

# BASEMAP 

ctr <- st_read("https://raw.githubusercontent.com/riatelab/basemaps/master/World/countries.geojson")
ctr <- ctr[,c("ISO2","name","geometry")] 
st_write(ctr,"outputs/countries.shp")

#################################################################
# COUNTRIES, COLORS & INDEX
#################################################################

url <- "https://www.passportindex.org/byColor.php"
webpage <- read_html(x = url)

cols <- c("red","green", "blue", "black")

for (i in 1:length(cols)){
col <- paste0(".",cols[i])
name <- webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_attr("data-cname")
id <- toupper(webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_attr("data-code"))
mobilityscore <- webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_attr("data-ms")
globalrank <- webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_attr("data-rank")
individualrank <- webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_attr("data-irank")
thumb <- paste0("https://www.passportindex.org",webpage %>% html_nodes(col) %>% html_nodes("a") %>% html_nodes("img") %>% html_attr("src"))
img <- paste0("https://www.passportindex.org/countries/",tolower(id),".png")
tmp <- data.frame(id,name,thumb, img,color = cols[i], mobilityscore, globalrank, individualrank)

if (i == 1) {
  dt <- tmp
} else { dt <- rbind(dt, tmp)}

}

write.csv(dt,"outputs/ctrindex.csv", row.names = FALSE)

#################################################################
# MATRIX COUNTRIES * COUNTRIES
#################################################################

# GET DATA BY COUNTRY
links <- paste0("https://www.passportindex.org/passport/",tolower(str_replace_all(dt$name," ","-")))
nb <- length(links)

for (i in 1:nb){
url <- links[i]
webpage <- read_html(x = url)
countries <- webpage %>% html_nodes(".show-tr") %>% html_nodes("a") %>% html_text()
visas <- webpage %>% html_nodes(".show-tr") %>% html_nodes(".text-center") %>% html_text()
tmp <- data.frame(i = dt$id[i], j = countries,fij = visas)
if (i == 1){d <- tmp} else {d <- rbind(d, tmp)}

}

View(d)

d  <- merge(x = d, y = dt[,c("id","name")], by.x = "j", by.y = "name", all.x=T)
d <- d[,c("i","id","fij")]
colnames(d) <- c("i","j","fij")

dd <- dcast(d, i ~ j)

write.csv(dd,"outputs/visasmatrix.csv")

#################################################################
# POWER PASSEPORT 
#################################################################

url <- "https://www.passportindex.org/byRank.php"
webpage <- read_html(x = url)
links <- webpage %>% html_nodes(".rank-calendar-button") %>% html_nodes("a") %>% html_attr("href")

for (i in 1:length(links)){
l <- links[i]
webpage <- read_html(x = l)
id <- toupper(webpage %>% html_nodes(".allregions") %>% html_attr("data-code"))
name <- webpage %>% html_nodes(".allregions") %>% html_nodes(".name_country") %>% html_text()
rank <- webpage %>% html_nodes(".allregions") %>% html_attr("data-pr")
mobilityscore <- webpage %>% html_nodes(".allregions") %>% html_attr("data-vfs")
pop <- webpage %>% html_nodes(".allregions") %>% html_attr("data-pop")
visafree <- webpage %>% html_nodes(".vf")  %>% html_text()
visaonarrival <- webpage %>% html_nodes(".voa")  %>% html_text()
visarequired <- webpage %>% html_nodes(".vr")  %>% html_text()
tbl <- data.frame(id, name, pop, rank, mobilityscore, visafree, visaonarrival, visarequired)

file <- gsub("https://www.passportindex.org/", "outputs/", links[i])
file <- gsub(".php", ".csv", file)
write.csv(tbl,file, row.names = FALSE)
}

#################################################################
# WELCOMING
#################################################################

url <- "https://www.passportindex.org/byWelcomingRank.php"
webpage <- read_html(x = url)
links <- webpage %>% html_nodes(".rank-calendar-button") %>% html_nodes("a") %>% html_attr("href")

for (i in 1:length(links)){
l <- links[i]
webpage <- read_html(x = l)
id <- toupper(webpage %>% html_nodes(".allregions") %>% html_attr("data-code"))
name <- webpage %>% html_nodes(".allregions") %>% html_nodes(".name_country") %>% html_text()
rank <- webpage %>% html_nodes(".allregions") %>% html_attr("data-pr")
mobilityscore <- webpage %>% html_nodes(".allregions") %>% html_attr("data-vfs")
pop <- webpage %>% html_nodes(".allregions") %>% html_attr("data-pop")
welcomingscore <- webpage %>% html_nodes(".vf")  %>% html_text()
tbl <- data.frame(id, name, pop, rank, welcomingscore)

file <- gsub("https://www.passportindex.org/", "outputs/", links[i])
file <- gsub(".php", ".csv", file)
write.csv(tbl,file, row.names = FALSE)
}

