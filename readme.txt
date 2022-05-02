READ ME:
videoreadeR documentation and changelog

Who is this for?
- Anyone who needs to extract the operational data from trail cameras en masse.

REQUIREMENTS:
- Windows OS - designed for Windows with built in Shell scripts
- FFMPEG - for pre-processing videos (https://www.youtube.com/watch?v=IECI72XEox0)
- R, RStudio, and RTools - for importing packages (https://cran.r-project.org/bin/windows/Rtools/rtools40.html)
		To install packages used in the R script, run: install.packages("package_name") in the R terminal

THINGS YOU NEED TO DO:
1.) Download the videoReader folder
2.) Run videoreader.bat
3.) Select the video directory when prompted by file dialog
4.) Copy contents (CTRL+A -> CTRL+C) of the generated 'videolog.csv' into database (CTRL+V)
5.) Manually check for inconsistencies...OCR is not 100% reliable

Data columns correspond to: Letter, Number, Length, Date, Time, Pressure, Temperature

Note that date may look like "#######" in the CSV - this is by default. To make the data readable, you must expand the cell width.

You can see my work pipeline and comments on each line in 'videoreade.r'

THINGS I NEED TO DO: 
- Test EVERYTHING - I have a small video sample size, so bugtesting and squashing still needs to be done
- Test on other OS and other languages - this was developed on and for Windows and R, but it could probably be reproduced in Python on other operating systems
- Make null columns actually empty, as they currently just overwrite the formulas in E and G...
- Add exception for cameras with bugged name reptition (i.e: (IMG_153(1).mp4)
- Add documentation for batchfiles - just trust that they work, for now
- Phase out necessity of global variable declaration in the batchfiles

This is my second R project, so the syntax and implementation is terrible at best, but I hope you can work with it if you plan on retrofitting it.
The geometric dimensions of each variable are in another textfile in this directory. You may have to create your own if your camera specs are not identical to our camera trap array.
I have two legacy versions available as well - these are in varying states of functionality primarily for my own reference, or yours if you can parse them. I intend to co-opt the functions of videoreader2 into the main build eventually.