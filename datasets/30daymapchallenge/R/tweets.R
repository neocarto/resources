library(rtweet)
library(stringr)

# mapchallenge

getwd()
mapchallenge <- read.csv("../input/30daymapchallenge.csv")

# get timeline @neocartocnrs

timeline <- get_timeline(
  user = "neocartocnrs",
  n = 1000)

timeline$hashtag <- NA

for (i in 1:nrow(timeline)){ timeline$hashtag[i] <- unlist(timeline$hashtags[i])[1]}
df <- data.frame(timeline[timeline$hashtag == "30DayMapChallenge" & timeline$is_retweet == FALSE,])
df <- df[!is.na(df$status_id),c("status_id","created_at","text","favorite_count","retweet_count","media_url")]

# merge

for (i in 1:nrow(df)){
  df$day[i] <- str_split(df$text[i], " ")[[1]][2]
  x <- str_split(df$url[i]," ")
  if (length(unlist(x)) == 2){df$url[i] <- unlist(x)[2]}
}

mapchallenge <- merge(x = mapchallenge, y = df, by.x = "day", day.y = day)

# count comments

first <- "1323203143140810752"
mentions <- get_mentions(since_id = first)

for (i in 1:nrow(mapchallenge)){
status <- mapchallenge$status_id[i]
tmp <- mentions[mentions$status_in_reply_to_status_id == status,]
tmp <- tmp[!is.na(tmp$status_id),]
mapchallenge$comment_count[i] <- nrow(tmp)
}

mapchallenge$media_url <- as.character(mapchallenge$media_url)
write.csv(mapchallenge,"../30dmc2020.csv", row.names = FALSE)
write.table(Sys.Date(), "../update.txt", row.names = FALSE, col.names = FALSE)
