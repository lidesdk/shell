#!/bin/sh

#LUA_BIN='/datos/Proyectos/lide/commandline'

#$LUA_BIN/lua514 -l lide.init $LUA_BIN/lide.lua $1 $2 $3
lua -e 'package.path = (package.path or '') ..";"..(os.getenv "LIDE_PATH" or '') .."/?.lua" require "lide.core.init" ' $LIDE_PATH/lide.lua $1 $2 $3 $4 $5 $6 $7