http = require 'http'


--url = 'https://www.dropbox.com/s/ko063peoh3sn56d/Facebook-20151014-101750.jpg?dl=0'

--url = 'httpxxxxs://www.dropbox.com/s/ko063peoh3sn56d/Facebook-20151014-101750.jpg?dl=0' 
--url = 'https://drive.google.com/file/d/0B3CJNSh_6haSR2IxZV8xWkxyRzg/view?usp=download' 
--url = 'http://readthedocs.org/projects/lide-framework/downloads/pdf/latest/'


--url OK = 'https://github.com/lidesdk/framework/blob/master/readme.rst'

--url = 'https://raw.gitSShubusercontent.com/lidesdk/framework/master/readme.rst' 
url = 'https://raw.githubusercontent.com/lidesdk/framework/master/readme.rst' 

dest= '/datos/Proyectos/lide_updater/readme.xlidd'
--url = 'http://noexisto.com/lol/download.file.xts'
--
http.download(url, dest)