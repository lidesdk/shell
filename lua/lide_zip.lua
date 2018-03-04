zip = require(  'zip' )

lide.zip = { lzip = zip }

local normalize_path = lide.platform.normalize_path

local function mktree ( src_file ) -- make only tree of dirs of this file
	if not lfs.attributes(src_file) then
		local _path = '' for path in src_file:delimi '\\' do
			if _path == '' then
				_path = _path .. path
			else
				_path = _path .. '/' .. path
				if not lfs.attributes(_path) then
					lfs.mkdir(_path)
				end
			end
		end
	end
end

function lide.zip.extract ( source, dest )	
	if not lide.file.doesExists(source) then
		print ('! Error: el archivo no existe: ' .. source)
	else
		local zfile, err = zip.open(normalize_path(source))

		if zfile then
			dest_folder = dest

			for file in zfile:files() do
				if file.filename:sub(#file.filename, #file.filename) == '/' then
					local internal_folder = file.filename:sub(0, #file.filename-1)
					local tocreate_folder = dest_folder .. '/'..internal_folder
					--print(normalize_path(tocreate_folder))
					if not lide.folder.doesExists(tocreate_folder) then
						mktree(tocreate_folder)
					end
				else

					local zip_stored_file = zfile:open(file.filename, 'rb');
					local dest_file_path = normalize_path(dest_folder .. '/' .. file.filename)
					local dest_file      = io.open(dest_file_path, 'w+b')
					
					--mktree(dest_file_path)
					
					if dest_file then
						dest_file:write( zip_stored_file:read '*a' )
						dest_file:flush()
						dest_file:close()
					end
					zip_stored_file:close()
				end
			end
			zfile:close()
		else
			print 'dont zfile'
		end
	end

end

function lide.zip.extractFile ( zipFilePath, internalPath, destinationPath)
    local zfile, err
    
    if lide.file.doesExists(zipFilePath) then
    	zfile, err = zip.open(zipFilePath)
    else
    	return false
    end
	
    -- iterate through each file insize the zip file
    mktree(destinationPath:sub(1, #destinationPath - #internalPath -1))
        
    if internalPath:gsub(' ', '') ~= '' then
    	local currFile, err = zfile:open(internalPath)
    	--if not currFile then error 'internalPath file does not exists.' end
    	if not currFile then return false, 'internalPath file does not exists.' end
    	local currFileContents = currFile:read("*a") -- read entire contents of current file
    	local hBinaryOutput = io.open(destinationPath, "w+b")

    	-- write current file inside zip to a file outside zip
    	if(hBinaryOutput)then
    	    hBinaryOutput:write(currFileContents)
    	    hBinaryOutput:close()
    	end
    	currFile:close()
    end
    zfile:close();
    return true
end

return lide.zip