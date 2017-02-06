-- thlua.lua (thedary's Lua functions)
-- Dario Cano - thedary.tumblr.com
-- License? Bitch Please...

--------------------------------------
--	 			TABLE 				--
--------------------------------------

-- table.count
-- 	Funciona exactamente igual que el operador '#' tuvimos que crear esta funcion porque necesitabamos 
-- 	que funcionara con tablas del tipo:
--		t = { CODIGO = "A" }
--  Pero al utilizar el operador '#', devolvìa cero.

function table:getcount(  )
	local n = 0; for k,v in pairs(self) do
		n = n+1
	end
	return n
end

function table.count( t )
	local nCount = 0
	for i,v in pairs(t) do
		nCount = nCount +1
	end

	return nCount
end

-- Copiar el contenido de una tabla a otra:
function table.copy( tSource )
	local r = {}
	for k,v in pairs(tSource) do
		r[k] = v
	end

	setmetatable(r, getmetatable(tSource))
	return r
	----------------------------------------------
	-- usage: tCopyOfMyTable = table.copy(tMyTable)
	----------------------------------------------
end

-- Unir dos tablas:
function table.join( t1, t2 )
	local r = {}
	
	for k,v in pairs(t1 or {}) do
		r[k] = v
	end
	
	for k,v in pairs(t2 or {}) do
		r[k] = v
	end

	setmetatable(r, table.copy(getmetatable(t1) or {}, getmetatable(t2) or {}))
	return r
	----------------------------------------------------------
	-- usage: tFusionOfTables = table.join(tMyTable, tMyTable2)
	----------------------------------------------------------
end

-- Verificar si dos tablas son difentes
function table.diff (t1, t2)
         local value = false
         if(#t1 ~= #t2)then
            value = true
         else
            for a,b in pairs(t1) do
            	for c,d in pairs(t2) do
            		if t1[c] ~= t2[c] then
            			value = true
            		end
            	end
            end
         end

	return value
   	----------------------------------------------------------
	-- usage: bAreDifferent = table.diff(tMyTable, tMyTable2)
	----------------------------------------------------------
end

function table.tostring ( t, delimiter )
         local ret_st
         for key, value in pairs(t) do
         	if tonumber(key) then
         		if not ret_st then
         			ret_st = value
         		else	
         			ret_st = ret_st .. delimiter .. value
         		end
         	end
         end

	return ret_st or ''
   	----------------------------------------------------------
	-- usage: sValues = table.tostring(tClients, ', ')
	----------------------------------------------------------
end


--------------------------------------
--	 			STRING 				--
--------------------------------------

-- Convertir un string a booleano
function string.bool(self)
    if self == "true" or self == "1" then
    	return true
    elseif self == "false" or self == "0" then
    	return false
    end
end
function string.tobool( str )
    if str == "true" then
        return true
    else
        return false
    end
end
function string.url (texturl)
	local protocol = string.find(texturl, ":/", 1)
	if(protocol==nil)then
		texturl = "http://"..texturl
	elseif(protocol==1)then
		texturl = "http"..texturl
	end

	texturl = string.gsub(texturl, " ", "")
	
	repeat 
		texturl = string.gsub(texturl, "//", "/")
   	   	found = string.find(texturl, "//", 1)
	until  found == nil
	
	texturl = string.gsub(texturl, ":/", "://")

return texturl
end

-- Delimit string to table: 
function string.delim(str, d)
   local a,t,c,b = 0, {}
   
   repeat
      b = str:find(d or '|', a)
      if b then
         c = str:sub(a, b-1)
         a = b +1
      else
         c = str:sub(a, #str)
      end
      t[#t+1] = c
   until b == nil 
   return t
   ---------------------------------------
   -- usage: 
   -- t = string.delim "thedary|thd" 
   -- t = string.delim("thedary, dario, cano",',')
   ---------------------------------------
end

-- Delim iterator: 
function string.delimi ( str, d )
  t = string.delim(str, d)
  local i = 0 
  return function() 
    i = i +1;     
    return t[i] 
  end 
	----------------------------------------
	-- usage:
	-- for value in string.delimi "thedary|thd" do 
	-- 	  print(value)
	-- end
	----------------------------------------
	-- str = "Hernan,Dario,Cano"
	-- for value in str:delimi(',') do 
	--	  print(value)
	-- end
	----------------------------------------
end


--------------------------------------
--	 			FUNCTIONS			--
--------------------------------------

-- Obtener el nombre de una variable: (retorna un string)
function getvname(obj)
	for i,v in pairs (_G)do
		
		if v == obj then
			return i
		elseif type(v) == "table" then
			for a,b in pairs(v) do
				if b == obj then
					return (i..'.'..a)
				elseif type(b) == "table" then
					for c,d in pairs(b) do
						if d == obj then
							return (i..'.'..a..'.'..c):gsub("_G.", '')
						end
					end
				end
			end
	 	end

	end
	return nil
	--------------------------------
	-- usage: VarName = getvname(Var)
	--------------------------------
end

function notlua (val)
	--co =  ' t = { '	it = ' "%s",' for k,v in pairs(_G) do co = co .. it:format(k) end co = co .. "}"
	if not val or tostring(val) == "nil" or tonumber(val) then
		error("notlua(): please give me a string", 3)
	end
	local t = {"string", "xpcall", "co", "package", "tostring", "print", "os", "unpack", "require", "getfenv", "setmetatable", "next", "assert", "tonumber", "io", "rawequal", "collectgarbage", "arg", "getmetatable", "module", "rawset", "notlua", "it", "math", "debug", "pcall", "table", "newproxy", "type", "coroutine", "_G", "select", "gcinfo", "pairs", "rawget", "loadstring", "ipairs", "_VERSION", "dofile", "setfenv", "load", "error", "loadfile"}

	for _, mival in pairs(t) do
		if val == mival then
			return false
		end
	end
	return true
end

-- redondear
function math.round (num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end