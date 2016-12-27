@echo off

lua -e "assert(os.getenv 'LIDE_PATH', 'Declare la variable de entorno LIDE_PATH'); package.path =  os.getenv 'LIDE_PATH' ..'\\?.lua;' ..os.getenv 'LIDE_PATH' ..'\\lua\\windows\\?.lua;'.. os.getenv 'LIDE_PATH' ..'\\libraries\\?.lua;'; require 'lide.core.init'" %LIDE_PATH%\lide.lua %1 %2 %3 %4 %5 %6 %7