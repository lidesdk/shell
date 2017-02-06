lfs = lide.lfs

local function normalizePath ( path )
	if lide.platform.getOSName() == 'Linux' then
		return tostring(path:gsub('\\', '/'))
	elseif lide.platform.getOSName() == 'Windows' then
		return tostring(path:gsub('/', '\\'))
	end
end

local function random_num ( i )
	i = (i or 0) local n = {
		math.round(math.random(os.time()+3)),
		math.round(math.random(os.time()-i))
	} return n [1] + n [2]
end

lide.core.folder = {}

function lide.core.folder.create ( sFolderName )
	return (lfs.mkdir(sFolderName))
end

-- simple test to see if the file exits or not
function lide.core.folder.doesExists( sFolderName )
    sFolderName = tostring(normalizePath(sFolderName))
    --print(sFolderName)
    local attr = lfs.attributes(sFolderName)
    if attr then
    	if attr.mode == 'directory' then
    		return true
    	else
    		print 'Es un archivo.'
    	end
	else
		return false;
	end
end

function lide.core.folder.delete ( folder_path )
	local _shell_command
	
	if lide.platform.getOSName() == 'Linux' then
		_shell_command = 'rm -rf "%s"'
	elseif lide.platform.getOSName() == 'Windows' then
		_shell_command = 'del /F /Q /S "%s"'
	end

	folder_path = normalizePath(folder_path);
	
	if lide.core.folder.doesExists(folder_path) then
		local exc, rst = pcall(
			io.popen, _shell_command:format(folder_path)
		) if not exc then
			print ('error: '.. tostring(rst))
		end
	end
end

return lide.core.folder