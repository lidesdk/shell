Lide Commandline
================

Lide Commandline is a tool that allow you to execute lua scripts and manage lua modules, you can search install and remove modules from lide repository.

================  ===================  ============================================================  ====================
  platform          arch                 build log                                                     build status
================  ===================  ============================================================  ====================
  ``Windows``      ``x86``               https://ci.appveyor.com/project/dcanoh/commandline            .. image:: https://ci.appveyor.com/api/projects/status/uvkh9w4e474v5p23?svg=true
  ``GNU/Linux``    ``x64``               https://circleci.com/gh/lidesdk/commandline/tree/testing      .. image:: https://circleci.com/gh/lidesdk/commandline/tree/testing.svg?style=svg
================  ===================  ============================================================  ====================

.. image:: https://github.com/lidesdk/commandline/raw/master/screenshot.png
   :height: 393px
   :width: 677px
   :scale: 90 %
   :alt: alternate text
   :align: center

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
* Create environment variables named ``LIDE_PATH`` and ``LIDE_FRAMEWORK``
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
        export LIDE_FRAMEWORK=~/.lide/commandline/libraries/lide


Windows Installation
********************

.. code-block:: bash
	
	# Create lide install directory and go to it (C:\.lide):
	$ mkdir C:\lide && cd C:\lide

	# Clone git repository and submodules:
	$ git clone https://github.com/lidesdk/commandline.git --recursive commandline

	# Create environment variable named LIDE_PATH:
	
	set LIDE_PATH=C:\lide\commandline
	set LIDE_FRAMEWORK=C:\lide\commandline\libraries\lide

You must declare the ``LIDE_PATH`` and ``LIDE_FRAMEWORK`` environment variable permanently, please check this article:
`https://kb.wisc.edu/cae/page.php?id=24500 <https://kb.wisc.edu/cae/page.php?id=24500>`_


Credits and Authors
===================

Lide Commandline is part of (`Lide SDK <https://github.com/lidesdk/framework#lide-framework>`_) is currently active and developing, today is maintained by (`@dcanoh <https://github.com/dcanoh>`_)


License
=======

Lide is licensed under (`The GNU General Public License <https://github.com/lidesdk/commandline/blob/master/LICENSE>`_). Copyright © 2016 Hernán Dario Cano.