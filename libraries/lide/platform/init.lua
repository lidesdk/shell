lide.platform = lide.platform
lide.platform.__arch = os.getenv 'PROCESSOR_ARCHITECTURE' 
					   or io.popen 'uname -m' : read '*a' : gsub ('x64_64', 'x64') : gsub ( 'i686', 'x86' )

function lide.platform.getArch ()
	return lide.platform.__arch
end

lide.platform.getOS = lide.platform.getOSName

if lide.platform.getOS() == 'Windows' then
	windows = true 
elseif lide.platform.getOS() == 'Linux' then
	linux = true
end

function lide.platform.getOSVersion( ... )
	if windows then
		local txt = io.popen 'reg query "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" /v "ProductName"' : read '*a': delim '\n' [3]

		return txt:sub(txt:find 'Windows', # txt)
	elseif linux then
		error 'lide.platform.getOSVersion not supported'
	end
end

return lide.platform