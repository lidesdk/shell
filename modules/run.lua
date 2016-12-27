function table.print( ... )
	for k,v in pairs(...) do
		print(k,v)
	end
end

print (io.popen ( 
	os.getenv('LIDE_PATH') .. '\\gui.exe ' .. arg [2] .. ' '.. ( arg[3] or '' )
):read '*a' )
