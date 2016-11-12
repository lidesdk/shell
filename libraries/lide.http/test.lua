local http = require 'http'

url = 'https://raw.githubusercontent.com/lidesdk/framework/master/readme.rst'

dest= './__readme.rst'
http.download(url, dest)

if io.open('./__readme.rst') then
	--test_ok)
else
	assert(false)
end

--https://travis-ci.org/lidesdk/framework
url = 'https://travis-ci.org'

if http.test_connection ( url ) then
	-- test ok
else
	assert('nos e puede connectar a travis-ci.org')
end