@echo off 
if %PROCESSOR_ARCHITECTURE%==x86 (
  %LIDE_PATH%\bin\windows\x86\lua5.1.exe %LIDE_PATH%\lide.lua %1 %2 %3 %4 %5 %6 %7
) else (
  %LIDE_PATH%\bin\windows\x64\lua5.1.exe %LIDE_PATH%\lide.lua %1 %2 %3 %4 %5 %6 %7
)
