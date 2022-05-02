@echo off

set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Select the video directory.',0,0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "folder=%%I"

setx videopath %folder%

exit