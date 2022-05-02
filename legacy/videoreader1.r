library(magick)
library(tesseract)
library(purrr)
library(stringr)
library(data.table)

partial_path <- c("Desktop", "videoReader") %>% lift_dv(file.path)(fsep = "//") # designates path end
full_path <- file.path(Sys.getenv("USERPROFILE"), partial_path, fsep = "//") %>% setwd() # designates path beginning

#system("filepath.bat", show.output.on.console = FALSE) # runs filepath, querying user with file dialog
#system("videoconverter.bat", show.output.on.console = FALSE) # runs video to jpg conversion
length <- system("videolength.bat", intern = TRUE) # runs camera length operator

file.path(full_path, "imagepath", fsep = "/") %>% setwd() # sets working directory as imagepath
files <- list.files(pattern = "\\.jpg$", full.names = FALSE, recursive = FALSE) # creates list of files in imagepath
datalist <- list()
counter <- 1

for(i in files){
  camera <- image_read(files[counter]) %>%
    image_reducenoise() %>%
    image_convert() %>%
    image_quantize()
  
  pres <- image_crop(image = camera, geometry = "329x35+0+0") %>%
    ocr_data() -> pres
  pres <- pres[-c(2,3),]
  
  temp <- image_crop(image = camera, geometry = "182x35+320+0") %>%
    ocr_data() -> temp
  temp <- temp[-c(1),]
  
  date <- image_crop(image = camera, geometry = "279x35+569+0") %>%
    ocr_data() -> date
  
  time <- image_crop(image = camera, geometry = "197x35+866+0") %>%
    ocr_data() -> time
  
  
  if(str_sub(temp[1],-1,-1)=="5"){
    str_sub(temp[1,],-1,-1) <- "F"
  }
  if(str_sub(temp[1],-1,-1)=="0"||str_sub(temp[1],-1,-1)=="O"){
    str_sub(temp[1],-1,-1) <- "C"
  } # if exceptions for F and C being misread as 5, O/o respectively
  temp[1] <- gsub("([1-9])([A-Z])","\\1 \\2", temp[1]) # adds a space between the temperature and thermal unit denotation
  date[1] <- str_replace_all(date[1],"O","0") # replaces the zero (misread as 'O') in date with a zero
  time[1] <- gsub("([1-9])([A-Z])","\\1 \\2", time[1]) # adds a space between the time and meridiem signature
  #length[counter] <- as.integer(lengths[counter])
  bigdata <- rbind(pres,temp,date,time)
  bigdata <- bigdata[-c(2,3)]
  datalist[[i]] <- bigdata
  counter <- counter + 1
}

#CAM.data = do.call(cbind, datalist)
CAM.datatest <- CAM.data
CAM.datatest <- cbindlist(datalist) 
t(CAM.datatest)


for(i in files){
  CAM.names <- data.frame(t(files))
}

CAM.names[1,] <- gsub("\\..*", "", CAM.names[1,]) # removes everything after the first period in names
CAM.data <- as.data.frame(t(CAM.data)) # transposes matrix horizontally
CAM.data$V5 <-t(CAM.names) # staples names to the end of the matrix
#CAM.lengths <- head(CAM.lengths, -1)
CAM.data$v6 <- CAM.lengths
CAM.data <- CAM.data[,c(5,6,1,2,3,4)] # reorders columns to reflect data organization
colnames(CAM.data) <- c("Video #","Video Lengths","Air Pressure","Temperature","Date","Time") # renames columns to fit data standards

#write.csv(CAM.data,videolog) # writes matrix to an excel sheet
#setwd(full_path) # resets path
#file.path(full_path, "imagepath", fsep = "/") %>% unlink(recursive = TRUE) # deletes imagepath