lide_installfolder    = '/datos/Proyectos/lide_cmd'
lide_libraries_folder = '/datos/Proyectos/lide_cmd/libraries'


-- simple test to see if the file exits or not
function folder_doesExists( sFilename )
    local file = io.open(sFilename , 'rb')
    if (file == nil) then return false end
    io.close(file)
    return true
end


print(folder_doesExists(lide_installfolder))
--package.path = lide_installfolder..'/?.lua'
--
--http = require 'http.init' 
--
--http.download('https://github.com/lidesdk/repos/blob/master/libraries/lide.http.zip', './lide.txt')