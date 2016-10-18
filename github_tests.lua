-- $ lide install 'lide.http'

local github = {}
local http   = require 'requests'

--- github.get_file ( 'lidesdk/framework/LICENSE', 'v0.0.01' )
--- github path: [user]/[repo]/[file_path]
function github.get_file ( cloud_file_path, ref, access_token )
	local query_parameters = { 
		-- ref	string	The name of the commit/branch/tag. Default: the repository’s default branch (usually master)
		ref = ref or nil
	}

	local headers = {
		['Accept'] = 'application/vnd.github.v3.raw'
	}
	if access_token then
		headers['Authorization'] = 'token ' .. access_token
	end

	local x1 = cloud_file_path:find('/')
	local x2 = cloud_file_path:find('/', x1+1)
	local x3 = cloud_file_path:find('/', x2+1)

	local _github_user = cloud_file_path:sub(0   , x1-1 );
	local _github_repo = cloud_file_path:sub(x1+1, x2-1 );
	local _github_file = cloud_file_path:sub(x2+1, #cloud_file_path );
	
	local response = http.get { 
		headers = headers,
		query_parameters = query_parameters ,

		url = tostring(('https://api.github.com/repos/%s/%s/contents/%s'):format(_github_user, _github_repo, _github_file)),
		--{allow_redirects = false}
	}	
	
	-- 200 Codigo 200 significa que todo va bien:
	if (response.status_code == 200) then
		-- Retornamos el archivo completo:
		return response.text
	elseif (response.status_code ~= 200 ) then

		return false, response.status_code, response.status
--		lide.core.error.lperr()
	end
end



--if lide.platform.getOSName() == 'Windows' then
	local function update_database ( access_token )
		local db_content, errcode, errmsg  = github.get_file ( 'lidesdk/repos/libraries.db', nil, access_token)

		if db_content then
			local repos_db = io.open(folders.libraries..'/repos.db', 'w+b')
			if repos_db:write(db_content) then
				repos_db:close()
				-- OK SUccess
			else
				--any error writeing file
			end
		else
			print('[lide.github]: ', errmsg)
		end
	end
--end
folders = { 
	install   = 'c:\\lidesdk',
	libraries = 'c:\\lidesdk\\libraries',
}

update_database()