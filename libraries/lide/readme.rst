Lide Framework
==============

Lide Framework is a library that allows you to create multiplatform graphical interfaces from Lua language.
Lide uses wxWidgets to build controls and windows, this ensures the integration of your applications 
with GTK+ on Linux and really native controls in Windows.

.. image:: https://travis-ci.org/lidesdk/framework.svg?branch=master 
    :target: https://travis-ci.org/lidesdk/framework 


Installation
============

* Make sure you have the lua5.1 interpreter and dependencies installed on your machine.

============  ======================================================================================
 Platform      Installation
============  ======================================================================================
 Windows   	   Download `LuaForWindows_v5.1.4-33.exe <http://files.luaforge.net/releases/luaforwindows/luaforwindows/5.1.4-33/LuaForWindows_v5.1.4-33.exe>`_.
 Ubuntu        ``$ sudo apt-get install lua5.1 libwxgtk2.8``
 Archlinux	   ``# pacman -S lua5.1 wxgtk2.8``
============  ======================================================================================


Windows Installation
********************

.. code-block:: bash

	$ mkdir lide_app
	$ cd lide_app
	$ git clone https://github.com/LideSDK/framework.git lide


Luarocks Installation
*********************

If you have luarocks installed in your machine:

.. code-block:: bash
	
	$ luarocks install https://raw.githubusercontent.com/LideSDK/framework/master/lide-0.0-0.rockspec --local


GNU/Linux Installation
**********************

.. code-block:: bash

	$ mkdir lide_app
	$ cd lide_app
	$ git clone https://github.com/LideSDK/framework.git lide
	$ sudo cp ./lide/bin/x86/libwxlua_lua51-wx28gtk2u-2.8.12.3.so /usr/lib/libwxlua_lua51-wx28gtk2u-2.8.12.3.so
	$ sudo cp ./lide/bin/x86/wx.so /usr/lib/lua/5.1/wx.so
 

How to use it
=============

* Create a file ``main.lua`` into the folder lide_app.

.. code-block:: bash
	
	$ nano main.lua

.. code-block:: lua

	local Form   = lide.classes.widgets.form
	local Button = lide.classes.widgets.button

	local MessageBox = lide.core.base.messagebox

	form1 = Form:new { Name = 'form1',
		Title = 'Window Caption'
	};

	button1 = Button:new { Name = 'button1', Parent = form1,
		PosX = 10, PosY = 30,
		Text = 'Click me!',
	};

	button1.onClick : setHandler ( function ( ... )
		MessageBox 'Hello world!'
	end );

	form1:show(true)


With the above code we are creating a new form and putting a button inside it
at position (10, 30), clicking inside the button a message "Hello World" is displayed.

* Run the file ``main.lua`` with the following command:

.. code-block:: bash
	
	$ lua5.1 -l lide.init main.lua

This is all you need to start building applications, **should be noted that these instructions work** 
similarly to Windows or GNU/Linux.

Help & Documentation
====================

If you want to know more please read our official framework's documentation:


`- Lide Framework readthedocs <http://lide-framework.rtfd.io>`_

Credits and Authors
===================

Lide was founded in 2014 by Hernán D. Cano (`@dariocanoh <https://github.com/dariocanoh>`_) and Jesús H. Cano (`@jhernancanom <https://github.com/jhernancanom>`_ ) for private purposes, today is accessible to the public.

Lide is currently active and developing, today is maintained by (`@dariocanoh <https://github.com/dariocanoh>`_)