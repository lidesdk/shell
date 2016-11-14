@echo off

lua -e "package.path = package.path ..';'..os.getenv 'LIDE_PATH' ..'/?.lua'; require 'lide.core.init'" %LIDE_PATH%\lide.lua %1 %2 %3