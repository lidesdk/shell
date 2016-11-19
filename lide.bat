@echo off

lua -e "assert(os.getenv 'LIDE_PATH', 'Declare la variable de entorno LIDE_PATH'); package.path = os.getenv 'LIDE_PATH' ..'\\?.lua'; require 'lide.core.init'" %LIDE_PATH%\lide.lua %1 %2 %3