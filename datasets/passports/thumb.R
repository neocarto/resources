library(magick)

files <- list.files("outputs/img")
i = 1
for (i in 1:length(files)){
img <- image_read(paste0("outputs/img/",files[i]))
thumb <- image_resize(img, geometry = 100)
image_write(thumb, path = paste0("outputs/thumb/",files[i]), format = "png")
}