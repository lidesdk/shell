Lide Commandline
================

Lide Compiler is a tool that allow you convert lua script files in executables or binary libraries.

The principal goal is have a easy tool for build our self lua scripts.

Usage
*****

============  ======================================================================================
 Option        Description
============  ======================================================================================
  -o   	   	    Output filename
============  ======================================================================================

.. code-block:: bash

	$ lidec <input_file> -o <output_file> 

	$ lidec -o file.exe test_script.lua     >> output is "file.exe"
	$ lidec test_script.lua                 >> output is "output.out"


Installation
============

* Clone this repository:
* Run the build script 'build_linux.sh' or 'build_windows.bat'
* Execute './lidec --help' command

GNU/Linux Installation
**********************

.. code-block:: bash

	$ git clone https://github.com/lidesdk/compiler.git compiler
	$ cd compiler
	$ chmod +x ./build.sh && ./build.sh && ./chmod +x ./lidec
	> Lide compiler builded successfuly.
	$ ./lidec --help


Windows Installation
********************

.. code-block:: bash

	$ git clone https://github.com/lidesdk/compiler.git compiler
	$ cd compiler
	$ build
	> Lide compiler builded successfuly.
	$ lidec --help


Credits and Authors
===================

Lide Compiler is part of (`Lide SDK <https://github.com/lidesdk/framework>`_).

Lide is currently active and developing, today is maintained by (`@dariocanoh <https://github.com/dariocanoh>`_)