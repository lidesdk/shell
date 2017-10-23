require(  'zip' )

lide.zip = {}

local function mktree ( src_file ) -- make only tree of dirs of this file
	local _path = '' for path in (src_file) : gsub('\\', '/') : delimi '/' do
		if not path:find '%.' then
			_path = (_path or '/') .. path .. '/'
			
			if _path:find '/' then
				__pth = _path:sub(1, #_path )
				
				if __pth:sub(#__pth-1, #__pth) == ':/' then
					-- print(__pth) >>> D:/
				else
					__pth = normalize_path(__pth:sub(1, #__pth -1))
				end

				if not lide.folder.doesExists(__pth) then
					print('create', __pth)
					lide.folder.create (__pth)
				end
			end
		end
	end	
end

function lide.zip.extract ( source, dest )
	local zfile, err = zip.open(source)
	
	mktree (dest)

	if zfile then
		dest_folder = dest
		
		if not lide.folder.doesExists(dest_folder) then
			-- print('mkdir', dest_folder)
			lide.folder.create(dest_folder)
			--wx.wxSleep(0.01)
		else
			print 'eeror carpeta eiste'
			return false
		end

		for file in zfile:files() do
			if file.filename:sub(#file.filename, #file.filename) == '/' then
				local internal_folder = file.filename:sub(0, #file.filename-1)
				local tocreate_folder = dest_folder .. '/'..internal_folder
				
				if not lide.folder.doesExists(tocreate_folder) then
					lide.folder.create(tocreate_folder)
				end
			else
				local onzip_content = zfile:open(file.filename, 'rb');
				local dest_file
				
				repeat dest_file = io.open(dest_folder .. '/' .. file.filename, 'w+b');
				until dest_file

				if dest_file then				
					dest_file:write(onzip_content:read('*a'));
					onzip_content:close()
					dest_file:flush();
					dest_file:close()
				else
					print ('Error opening: ', dest_folder .. '/' .. file.filename)
				end
			end
			--wx.wxSleep(0.1)
		end
	else
		print 'dont zfile'
	end
end

return lide.zip