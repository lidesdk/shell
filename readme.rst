Lide Commandline
================

Lide Commandline is a tool that allow you to execute lua scripts and manage lua modules, you can search install and remove modules from lide repository.

![Alt text](https://github.com/lidesdk/commandline/screenshot.png)

Usage
*****

Execute lua script:

.. code-block:: bash

	$ lide <input_file>

Manage modules
**************

Search a package:

.. code-block:: bash

	$ lide search <package_name>

Install a package:

.. code-block:: bash

	$ lide install <package_name>

Remove a package:

.. code-block:: bash

	$ lide remove <package_name>


Installation
============

* Clone or `download <https://github.com/lidesdk/commandline/archive/master.zip>`_ this repository: ``https://github.com/lidesdk/commandline.git``
* Create environment variable named ``LIDE_PATH`` containing the path of your repository copy
* Execute ``lide --help'`` command

GNU/Linux Installation
**********************

.. code-block:: bash

	# Create lide install directory and go to it (~/.lide):
	$ mkdir ~/.lide && cd ~/.lide

	# Clone git repository and submodules:
	$ git clone https://github.com/lidesdk/commandline.git --recursive commandline
	
	# Add exec perms:
	$ cd commandline
	$ chmod +x ./lide.sh

	# Create environment variable named LIDE_PATH
	$ nano ~/.bashrc
	    # add this line at the bottom of the file:
        export LIDE_PATH=~/.lide/commandline


Windows Installation
********************

.. code-block:: bash
	
	# Create lide install directory and go to it (C:\.lide):
	$ mkdir C:\lide && cd C:\lide

	# Clone git repository and submodules:
	$ git clone https://github.com/lidesdk/commandline.git --recursive commandline

	# Create environment variable named LIDE_PATH:
	
	set LIDE_PATH=C:\lide\commandline

You must declare the ``LIDE_PATH`` environment variable permanently, please check this article:
`https://kb.wisc.edu/cae/page.php?id=24500 <https://kb.wisc.edu/cae/page.php?id=24500>`_

Credits and Authors
===================

Lide Commandline is part of (`Lide SDK <https://github.com/lidesdk/framework>`_).

Lide is currently active and developing, today is maintained by (`@dariocanoh <https://github.com/dariocanoh>`_)