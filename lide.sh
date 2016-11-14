#!/bin/sh

#LUA_BIN='/datos/Proyectos/lide/commandline'

#$LUA_BIN/lua514 -l lide.init $LUA_BIN/lide.lua $1 $2 $3
lua5.1 -e 'package.path = package.path ..";"..os.getenv "LIDE_PATH" .."/?.lua" require "lide.core.init" ' $LIDE_PATH/lide.lua $1 $2 $3