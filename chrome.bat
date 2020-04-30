REM Do the following for pranking
REM Add: @echo off
REM Remove: set /p n="Enter no. of incognito Windows: "
REM Remove: %n% with any number of your choice
cls
set /p n="Enter no. of incognito Windows: "
FOR /L %%A IN (1,1,%n%) DO (
  start /max /d "C:\Program Files (x86)\Google\Chrome\Application" chrome.exe --incognito
)
exit
