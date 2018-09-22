--////////////////////////////////////////////////////////////////////
--// Name:        lide.lua
--// Purpose:     Lua interpreter with lide framework integrated
--// Created:     2018/08/22
--// Copyright:   (c) 2018 Hernan Dario Cano [dcanohdev@gmail.com]
--// License:     GNU GENERAL PUBLIC LICENSE
--///////////////////////////////////////////////////////////////////


--file = arg[1]
--print(file)
--package.path = os.getenv 'LIDE_PATH' .. '/libraries/windows/x86/lua/?.lua;' 
--			.. os.getenv 'LIDE_PATH' .. '/libraries/?.lua;' 

--package.cpath = os.getenv 'LIDE_PATH' .. '/libraries/windows/x86/clibs/?.dll;' 
assert( pcall(dofile, 'D:/proyectos/lidesdk/shell/bin/lide51.lua') );

--if file then
--	assert( pcall(dofile, file) )
--end