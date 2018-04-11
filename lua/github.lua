--- $ lide install 'lide.http'

local github = {}
local http   = require 'http.init'

--- github.download_file ( 'lidesdk/framework/LICENSE', 'v0.0.01' )
--- github path: [user]/[repo]/[file_path]
function github.download_file ( cloud_file_path, dest_file_path, ref, access_token )
	local x1 = cloud_file_path:find('/')
	local x2 = cloud_file_path:find('/', x1+1)
	local x3 = cloud_file_path:find('/', x2+1)

	local _github_user   = cloud_file_path:sub(0   , x1-1 );
	local _github_repo   = cloud_file_path:sub(x1+1, x2-1 );
	local _github_file   = cloud_file_path:sub(x2+1, #cloud_file_path );
	local _github_branch = 'master'
	
	local github_full_url = tostring(('https://raw.githubusercontent.com/%s/%s/%s/%s'):format(_github_user, _github_repo, _github_branch, _github_file));
	
	http.download(github_full_url, dest_file_path)
end

return github