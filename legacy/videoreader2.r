library(magrittr)
library(stringr)
library(purrr)
library(future.apply)
library(data.table)
library(magick)
library(tesseract)


partial_path <- c("Desktop", "videoReader") %>% lift_dv(file.path)(fsep = "//") # designates path end
full_path <- file.path(Sys.getenv("USERPROFILE"), partial_path, fsep = "//") %>% setwd() # designates path beginning

system("filepath.bat", show.output.on.console = FALSE) # runs filepath.bat, querying user for video directory

lengths <- system("videolength.bat", intern = TRUE) # runs videolength.bat, storing lengths

system("videoconverter.bat", show.output.on.console = FALSE) # runs videoconverter.bat, pre-processing videos

file.path(full_path, "imagepath", fsep = "//") %>% setwd() #  sets working directory to images
files <- list.files() %>% keep(like, "*.jpg") # stores list of .JPGs in working directory

process_image <- function(img){ # processes images via MAGICK
  img %<>% # operator passes output between functions
    image_read() %>% # reads image
    image_reducenoise() %>%
    image_convert() %>%
    image_quantize()
  
  imgDT <- img %>% # formats OCR data into table
    ocr_data() %>%
    as.data.table()
  
  imgDT_subset <- imgDT[-c(2,3,5,8), -c(2,3)] # omits OCR metadata and symbols
  substring(imgDT_subset[2,][[1]], nchar(imgDT_subset[2,][[1]])) %<>%
    map_chr(~dplyr::case_when(.x == 5 ~ "F", .x == 0 ~ "C", TRUE ~ .x)) # fixes OCR thermal unit misreading
  
  imgDT_subset[2,] <- str_replace(imgDT_subset[2,], "([1-9])([A-Z])", "\\1 \\2") # fixes OCR misreading letters->digits
  imgDT_subset[3,] <- str_replace_all(imgDT_subset[3,],"O","0") # converts O->zero
  imgDT_subset[4,] <- str_replace(imgDT_subset[4,], "([1-9])([A-Z])", "\\1 \\2") # adds space between time and meridiem signature
  
  return(imgDT_subset)
}

plan(multisession) # renames list in parallel R session
processed_images <- future_sapply(files, process_image) %>%
  map_dfc(~.x) %>%
  dplyr::rename_with(~str_replace(.x, pattern = "\\..*", replacement = ""))

processed_data <- as.data.frame(t(processed_images))
#paste0(as.integer(lengths[4]) %/% 60,":",floor(as.integer(lengths[4]) %% 60))
processed_data$v5 <- as.integer(lengths)
processed_data <- processed_data[,c(5,3,4,1,2)]
colnames(processed_data) <- c("Length", "Date", "Time", "Pressure", "Temperature")

#setwd(full_path)
#write.csv((processed_data),"videolog.csv")
#file.path(full_path, "imagepath", fsep = "/") %>% unlink(recursive = TRUE) # deletes generated images
#testdata <- as.data.frame(processed_data)