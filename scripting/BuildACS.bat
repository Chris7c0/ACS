@echo off

rem This batch file is a 1 click build and copy acs.smx
rem To make copy work for you:
rem 1) Change the path(s) below to what you need
rem 2) Remove the rem on the xcopy line(s) below

set l4d2pluginfolder="C:\Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2 Dedicated Server\left4dead2\addons\sourcemod\plugins\"
set l4d2networkfolder="D:\Your Path Here\"

spcomp .\acs.sp -v 0

@echo off

rem xcopy ".\acs.smx" %l4d2pluginfolder% /Y >NUL
rem xcopy ".\acs.smx" %l4d2networkfolder% /Y >NUL

@echo               %time%