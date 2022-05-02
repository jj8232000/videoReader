@echo off
setlocal enabledelayedexpansion 

cd "%-dp0"
mkdir imagepath

cd %videopath%
FOR %%i IN (*.mp4 *.avi) DO ffmpeg -ss 1 -i "%%i" -pix_fmt yuvj422p -vf  "scale=1600:900,crop=1325:35:136:866" -vframes 1 "%~dp0\imagepath\%%i.jpg"

exit