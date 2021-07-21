
# LIBRARY

library(rvest)
library(stringr)

url <- "https://www.forbes.fr/classements/classement-forbes-2020-des-milliardaires-bernard-arnault-sur-le-podium/"
webpage <- read_html(x = url)

l <- webpage %>% html_nodes(".table") %>% html_table(header = TRUE)
table <- l[[1]] 

colnames(table) <- c("rank","name","fortune","nationality","company")

for (i in 1:nrow(table)){
  val <- table$fortune[i]
  val <- strtrim(val,(nchar(val)-4))
  val <- substr(val,2,nchar(val))
  table$value[i] <- as.numeric(gsub(",", ".", val)) 
}


write.csv(table,"billionaires.csv")
