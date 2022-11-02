# Native LEMP Tool

This script is a handful tool when you need a php enviroment (development or production) but with all the binaries installed natively in your operative system, no docker no vagrant, this is also a ideal tool to setup php servers on linux

lemptool is a rewrite of the the old dead [xnmp](https://github.com/lemyskaman/xnmp) bash script tool, with more reobust functionalities.

This script is compatible only for debian and ubuntu it uses [sury php repos](https://deb.sury.org/) to allow you install multiple php versions on the same machine. The php installation option on this package also install commons php libraries for laravel development, and is intend for nginx with fpm usage.


### Usage

Just clone the project and go to the project folder.
   
    $ git clone https://github.com/kamansoft/native-lemp-tool.git 
    $ cd native-lemp-tool

Then jsut run the script as sudo with the -i argument  and it will install all you need for a common php enviroment.

    $ sudo ./lemptool -i

A set of things will happen then make sure to read every confirmation message before continuing.

You can also pass the --help argument in order to display some other options bundle in this script

  






