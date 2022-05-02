@echo off
setlocal enabledelayedexpansion

cd "%videopath%"
FOR %%i IN (*.mp4 *.avi) DO ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%%i"

exit