Lide Shell 
==========

Lide Shell is a project that allow us to install libraries, 
execute scripts and create or search repositories of lua libraries.


========================================================= ====================================================================================
   git branch: ``master``                                  build status ``0.2.0``
========================================================= ====================================================================================
 Tests executed with **Windows 10** x86 binaries		    .. image:: https://ci.appveyor.com/api/projects/status/tg8aq749c25jewg0/branch/master?svg=true
                                                                     :target: https://ci.appveyor.com/project/dcanoh/shell/master
 Tests executed with **Ubuntu 14.04** x64 binaries     	    .. image:: https://circleci.com/gh/lidesdk/shell.svg?style=svg
                                                                     :target: https://circleci.com/gh/lidesdk/shell/tree/master
========================================================= ====================================================================================

.. image:: https://github.com/lidesdk/shell/raw/master/screenshot.png
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

	local MessageBox = lide.widgets.messagebox

	form1 = Form:new { Name = 'form1',
		Title = 'Window Caption'
	};

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

* Run the file ``main.lua`` with the following command:

.. code-block:: bash
	
	$ lide main.lua

This is all you need to start building applications, **should be noted
that these instructions work** similarly to Windows or GNU/Linux.



Help & Documentation
====================

If you want to know more please read our official framework's 
documentation:

`- Lide Framework 0.2 on Read the docs <http://lide-framework.readthedocs.io/en/0.2>`_


Credits and Authors
===================

Lide Shell is a project founded in 2016 by Hernán Darío Cano (`@dcanoh <https://github.com/dcanoh>`_) 
for private purposes, today is accessible to the public.

Lide Shell is currently active and developing, today is maintained by (`@dcanoh <https://github.com/dcanoh>`_).


License
=======

Lide is licensed under (`The GNU General Public License <https://github.com/lidesdk/commandline/blob/master/LICENSE>`_). 

Copyright © 2018 Hernán Dario Cano.