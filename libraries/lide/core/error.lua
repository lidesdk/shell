-- ///////////////////////////////////////////////////////////////////////////////
-- // Name:        core/error.lua
-- // Purpose:     
-- // Created:     2016/01/04
-- // Copyright:   (c) 2016 Dario Cano
-- // License:     lide license
-- ///////////////////////////////////////////////////////////////////////////////

local error = {

--[[	lperr = function ( str_err, level )

		local debug_levels, secure_level, traceback, message
		
		-- Get total debug levels of this call:
		repeat 
			debug_levels = (debug_levels or 0) +1
			local dgi = debug.getinfo(debug_levels)
		until not dgi
		
		-- Explicacion de debug_levels:
		--	1 : lpterr > Esta funcion
		--  2 : level2 > La funcion que hizo la llamada hacia (lpterr)
		--  3 : level3 > La funcion que hizo la llamada a (level2)
		-- ... etc
		
		level = lide.errorf.current_level or level or 1 ; level = level + 1

		traceback = 'Lide: %s\n'; traceback = traceback:format(str_err)
		
		-- "debug_levels -3" es para que no se muestren los primeros 3 niveles que corresponden a la propia funcion lpterr
		-- for nlevel = debug_levels -3, level, -1 do
		for nlevel = level, debug_levels -1 do
			
			local short_src   = debug.getinfo(nlevel).short_src	  or 'none'
			local currentline = debug.getinfo(nlevel).currentline or 'none'
			local namewhat    = debug.getinfo(nlevel).namewhat	  or 'none'
			local func        = debug.getinfo(nlevel).func 	      or 'none'
			local name  	  = debug.getinfo(nlevel).name        or 'none'

			if (type(func) == 'function') and namewhat ~= 'method' then
				namewhat = namewhat .. ' function'
			end
				
			-- Si el error se propaga desde el constructor de una clase:
			if name == '__constINIT__' or name == 'init' then
				local _, self = debug.getlocal(nlevel, 1) -- get 'self'
				traceback = traceback .. '[%s]\n[line:%d] in \'%s class\' constructor.\n'
				traceback = traceback:format(short_src, currentline, self:class():name())			
			else -- Un error normal:	
				-- Eliminamos la linea que corresponde a la llamada que se hace desde core/oop/yaci.lua
				-- Si el nlevel anterior (-1) tiene como llamada la funcion (metodo) privada '__constINIT__'
				
				local _, class = debug.getlocal(nlevel, 1) -- get 'self'
				
				if debug.getinfo(nlevel).what == 'main' then
					traceback = traceback .. '[%s]\n[line:%d] in main chunk.\n'		
					traceback = traceback:format(short_src, currentline)
				elseif debug.getinfo(nlevel).name == '__constINIT__' 
				or debug.getinfo(nlevel).name == 'new' 
					-- la linea de abajo la podria eliminar
					and short_src:sub(#short_src -7, #short_src)  == 'yaci.lua' 
					then
					
					-- No imprimir esta linea en el traceback
								
				elseif class and getmetatable(class).__type == 'class' and type(debug.getinfo(nlevel).func) == 'function' 
				and class:name() == debug.getinfo(nlevel).name then
					
					--- No imprimir esta linea en el traceback

				-- Verificamos si el metodo existe en la clase
				elseif (namewhat == 'method') then
					local _, self = debug.getlocal(nlevel, 1) -- get 'self'
					if getmetatable(self).__lideobj then
						traceback = traceback .. '[%s]\n[line:%d] in %s \'%s\' of \'class %s\'\n'		
						traceback = traceback:format(short_src, currentline, namewhat, name, self:class():name())
					end
				else
					traceback = traceback .. '[%s]\n[line:%d] in %s \'%s\'.\n'		
					traceback = traceback:format(short_src, currentline, namewhat, name)				
				end
			end		
		end

		io.stderr:write(traceback)
		io.stderr:write('\n')
		io.stderr:flush()
		error(nil, 1)
	end,]]

	lperr = function ( sErrMsg, nlevel )
		lide.core.base.isstring(sErrMsg)
		nlevel = nlevel or 1
		-- levels { 
		--	 1 = the function itself
		-- 	 2 = error dispatcher
		--   3 = caller of error_dispacher()
		--   4 = caller of 3
		--	 ..= main()
		-- }	
		local print_ok = true
		local function print( ... )
			io.stderr:write( tostring(unpack{...} or '') .. '\n')
		end
		
		local err_msg = ('Lide, Error: %s\n\n'):format(sErrMsg)
		
		local tmp_file_src = '' -- Esto es para que todos los levels continuos se junten:
		-- [/fs/ss/loo.lua]
		-- [line:1] dadasdsada
		-- [line:104] dadasdsada
		--
		-- Comienza desde 2: "la funcion que genera el error":
		-- repeat nlevel  = nlevel +1 (...)
		local traceback = ''
		

		--if debug.getinfo(nlevel+1) then
		local i = nlevel repeat i = i +1
			local level = debug.getinfo(i) 

			if debug.getinfo(i) then
			if not level then io.stderr : write (sErrMsg .. '\n') end

			local short_src   = tostring(level.short_src or 'NULL_FILE')
			local currentline = tonumber(level.currentline or -3) --> -3 simplemnte es para identificar que es un error, este numero no tiene nada que ver con nada.
			local namewhat    = tostring(level.namewhat or 'NULL_NAMEWHAT')
			local name        = tostring(level.name or 'NULL_NAME')
			local print_line  = true

			if level.what == 'main' then
				name     = 'main'
				namewhat = 'chunk'
			end
			
			if name == 'NULL_NAME' and level.what == 'main' then
				name = '..main chunk..'
			end

			if (namewhat == 'global') and (type(level.func) == 'function') then
				namewhat = 'global function definition'
			elseif (namewhat == 'upvalue') or (namewhat == 'local') and (type(level.func) == 'function') then
				namewhat = 'local function definition'
			elseif (namewhat == 'method') and ( name == 'init' ) and (type(level.func) == 'function') then
				local _, self = debug.getlocal(i, 1) -- get 'self'
				name = 'constructor '
				namewhat = ('definition of "%s"'):format(tostring(self:class() or ''))
			elseif (namewhat == 'method') and (type(level.func) == 'function') then
				local _, self, class_name = debug.getlocal(i, 1) -- get 'self'
				
				if self and getmetatable(self) and getmetatable(self).__lideobj and not self.getName 
					and type(getmetatable(self).__index) == 'table' then 
					local class_name = getmetatable(self).__index.name()
					if  getmetatable(self).__lideobj and getmetatable(self).__type == 'class' then						
						print_line = false --> no imprimir estalinea en el traceback --[./lide/core/oop/yaci.lua]
					end
				else
					if self and getmetatable(self) and getmetatable(self).__lideobj and getmetatable(self).__type ~= 'class' then
						-- Obtenemos el nombre de la clase desde yaci:
						class_name = self:class():name()
					end
				end
				namewhat = ('method of "%s" object'):format(class_name or '')
			end

			if print_line then
				if (tmp_file_src ~= short_src) then 
					traceback = (traceback .. '[%s]\n' ):format(short_src)
				end
				traceback = traceback.. ('[line:%d] in %s %s.\n'):format(currentline, name, namewhat)
			end
			
			tmp_file_src = short_src ;
		end
		until not debug.getinfo(i)

		print(err_msg .. traceback) os.exit()
	end,
	--[[
	lperr = function ( sErrMsg, nlevel )
		local level--, level_currentline
		local i = nlevel or 0 repeat i = i +1
			
			if debug.getinfo(i) then
			level = debug.getinfo(i)
			local short_src   = tostring(level.short_src or 'NULL_FILE')
			local currentline = tonumber(level.currentline or -3) --> -3 simplemnte es para identificar que es un error, este numero no tiene nada que ver con nada.
			local namewhat    = tostring(level.namewhat or 'NULL_NAMEWHAT')
			local name        = tostring(level.name or 'NULL_NAME')
			local print_line  = true

			if level.what == 'main' then
				name     = 'main'
				namewhat = 'chunk'
			end
			end

		until debug.getinfo(i) == nil --debug.getinfo(i).what == 'main'
		
		io.stderr : write ('line:'.. level.currentline..'\n\n'..sErrMsg .. '\n')--:flush()
	end]]
}

return error