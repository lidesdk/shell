Lide Framework
==============

Lide Framework is a library that allows you to create multiplatform 
graphical interfaces from Lua language.
Lide uses wxWidgets to build controls and windows, this ensures the 
integration of your applications with GTK+ on Linux and really native 
controls in Windows.

========================================================= ====================================================================================
   git branch: ``master``                                  build status ``0.1``
========================================================= ====================================================================================
 Tests executed with **Windows 10** x86 binaries		    .. image:: https://ci.appveyor.com/api/projects/status/uvkh9w4e474v5p23?svg=true
                                                                     :target: https://ci.appveyor.com/project/lidesdk/shell/branch/master
 Tests executed with **Ubuntu 14.04** x64 binaries     	    .. image:: https://circleci.com/gh/lidesdk/shell/tree/master.svg?style=svg
                                                                     :target: https://circleci.com/gh/lidesdk/shell/tree/master
========================================================= ====================================================================================

.. image:: https://github.com/lidesdk/commandline/raw/develop/screenshot.png
   :scale: 90 %
   :align: center



Installation
============

First install lide shell from github:

**Note:**
Lide shell is a command line interpreter that makes sure that you 
have installed the correct versions of each library.

.. code-block:: bash

	$ mkdir lide && cd lide
	$ git clone https://github.com/lidesdk/shell.git --recursive
	$ export LIDE_PATH=$PWD

Manual installation
-------------------
- `Please follow the instructions for Windows. <https://github.com/lidesdk/shell/tree/master#windows-installation>`_
- `Or follow the instructions for GNU/Linux... <https://github.com/lidesdk/shell/tree/master#gnulinux-installation>`_

Auto Installer
--------------
* If you prefer automatic install on your system you can download the
  last stable version of lide shell installer: `from here <https://github.com/lidesdk/shell/releases>`_.


How to use it
=============

* Create a file ``main.lua``.

.. code-block:: lua
	
	lide = require 'lide.widgets.init'

	local Form   = lide.classes.widgets.form
	local Button = lide.classes.widgets.button

	local MessageBox = lide.core.base.messagebox

<<<<<<< HEAD
	form1 = Form:new { Name = 'form1',
		Title = 'Window Caption'
	};
=======
* Clone or `download <https://github.com/lidesdk/commandline/archive/develop.zip>`_ this repository: ``https://github.com/lidesdk/commandline.git``
* Create environment variables named ``LIDE_PATH``
* Execute ``lide --help`` command
>>>>>>> develop

	button1 = Button:new { Name = 'button1', Parent = form1,
		PosX = 10, PosY = 30, Text = 'Click me!',
	};

	button1.onClick : setHandler ( function ( event )
		lide.widgets.messagebox 'Hello world!'
	end );

	form1:show(true);


With the above code we are creating a new form and putting a button 
inside it at position (10, 30), clicking inside the button a message 
"Hello World" is displayed.

<<<<<<< HEAD
* Run the file ``main.lua`` with the following command:
=======
	# Create lidesdk install directory and go to it (~/.lidesdk):
	$ mkdir ~/.lidesdk && cd ~/.lidesdk 
>>>>>>> develop

.. code-block:: bash
	
<<<<<<< HEAD
	$ lide main.lua
=======
	# Add execution permissions:
	$ cd shell
	$ chmod +x ./lide.sh

	# Create environment variable named LIDE_PATH
	$ nano ~/.bashrc
	    # add this line at the bottom of the file:
        export LIDE_PATH=~/.lidesdk/shell
>>>>>>> develop

This is all you need to start building applications, **should be noted
that these instructions work** similarly to Windows or GNU/Linux.


<<<<<<< HEAD

Help & Documentation
====================

If you want to know more please read our official framework's 
documentation:

`- Lide Framework 0.1 on Read the docs <http://lide-framework.readthedocs.io/en/0.1>`_
=======
.. code-block:: bash
	
	# Create lide install directory and go to it (C:\lide):
	$ mkdir C:\lide && cd C:\lide

	# Clone git repository and submodules:
	$ git clone https://github.com/lidesdk/commandline.git --recursive shell

	# Create environment variable named LIDE_PATH:
	
	set LIDE_PATH=C:\lide\shell

You must declare the ``LIDE_PATH`` environment variable permanently, please check this article:
`https://kb.wisc.edu/cae/page.php?id=24500 <https://kb.wisc.edu/cae/page.php?id=24500>`_
>>>>>>> develop

 
Credits and Authors
===================

Lide was founded in 2014 by Hernán Darío Cano (`@dcanoh <https://github.com/dcanoh>`_) 
and Jesús H. Cano (`@jhernancanom <https://github.com/jhernancanom>`_ ) 
for private purposes, today is accessible to the public.

Lide is currently active and mastering, today is maintained by (`@dcanoh <https://github.com/dcanoh>`_).


License
=======

<<<<<<< HEAD
Lide is licensed under (`The GNU General Public License <https://github.com/lidesdk/commandline/blob/master/LICENSE>`_). Copyright © 2018 Hernán Dario Cano.
=======
Lide is licensed under (`The GNU General Public License <https://github.com/lidesdk/commandline/blob/develop/LICENSE>`_). 

Copyright © 2018 Hernán Dario Cano.
>>>>>>> develop
