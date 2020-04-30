@echo off
cls
::start Taskmgr.exe
FOR /L %%A IN (1,1,50) DO start cmd.exe /k "cd.. && cd .. && cd .. && tree"
exit 0
