library(magick)
library(tesseract)
library(purrr)
library(lubridate)
library(stringr)
library(data.table)
library(this.path)

#partial_path <- c("Desktop", "videoReader") %>% lift_dv(file.path)(fsep = "\\") # designates path end
#full_path <- file.path(Sys.getenv("USERPROFILE"), partial_path, fsep = "\\") %>% # designates path beginning
#  setwd() 

full_path <- dirname(this.path()) %>% # designates path to repo
  setwd()
  
system("filepath.bat", show.output.on.console = FALSE) # runs filepath, querying user with file dialog
system("videoconverter.bat", show.output.on.console = FALSE) # runs video to .jpg conversion
length <- system("videolength.bat", intern = TRUE) # runs camera length operator

file.path(full_path, "imagepath", fsep = "/") %>% # sets working directory as imagepath
  setwd() 
files <- list.files(pattern = "\\.jpg$", full.names = FALSE, recursive = FALSE) # creates list of files in imagepath
counter <- 1
datalist <- list()

for(i in files){
  cam <- image_read(files[counter]) %>% # captures and MAGICKly pre-processes base image
    image_reducenoise() %>%
    image_convert() %>%
    image_quantize()
  
  pressure <- image_crop(image = cam, geometry = "329x35+0+0") %>% # captures air pressure
    ocr_data() -> pressure
    pressure <- pressure[-c(2,3), -c(2,3)]
    
    
  temp <- image_crop(image = cam, geometry = "182x35+320+0") %>% # captures temperature
    ocr_data() -> temp
    temp <- temp[-c(1), -c(2,3)]

    if(str_sub(temp,-1,-1)=="5"){
      str_sub(temp,-1,-1) <- "F"
    }
    if(str_sub(temp,-1,-1)=="0"||str_sub(temp,-1,-1)=="O"){ # replaces misread thermal units
      str_sub(temp,-1,-1) <- "C"
    }
    
temp <- gsub("([1-9])([A-Z])","\\1 \\2", temp) # adds a space between the temperature and thermal unit
    
  date <- image_crop(image = cam, geometry = "279x35+569+0") %>% # captures date
    ocr_data() -> date
    date <- date[,-c(2,3)]
    date <- str_replace_all(date,"O","0") # replaces the zero (misread as 'O') in date with a zero
  
  time <- image_crop(image = cam, geometry = "197x35+866+0") %>% # captures time
    ocr_data() -> time
    time <- time[,-c(2,3)]
    time <- gsub("([1-9])([A-Z])","\\1 \\2", time) # adds a space between the time and meridiem signature
    
  letter <- image_crop(image = cam, geometry = "252x35+1072+0") %>% # captures camera letter
    ocr_data() -> letter
  letter <- letter[,-c(2,3)]
  letter <- str_replace_all(letter,"CAMERA","") # isolates camera letter or number
    
  duration(as.integer(length[counter])) %>%  # converts video lengths from seconds to minute:seconds
    as.Date("2000-08-23") %>% # date wholly irrelevant...I put my birthday
    format("%M:%S") -> length[counter]
  
  blank <- ""
  blank2 <- ""

  datalist[[i]] <- t(c(letter, time, pressure, temp, date, blank, blank2)) # combines all vectors into a master list
  counter <- counter + 1 
}

for(i in files){
  files <- gsub(".*?([0-9]+).*", "\\1", files) # strips non-numerics from video name
}

cam_data <- do.call(rbind, datalist) # compiles data into list
  video_log <- cbind(files, length, cam_data) # staples together data frames
  video_log <- video_log[,c(3,1,2,7,8,4,9,5,6)] # reorders columns to video log organization

setwd(full_path) # repaths to videoreadeR directory
  write.table((video_log),"videolog.csv", sep = ",", col.names = FALSE, row.names = FALSE) # writes data to Excel table
  file.path(full_path, "imagepath", fsep = "\\") %>% 
    unlink(recursive = TRUE) # deletes imagepath
  