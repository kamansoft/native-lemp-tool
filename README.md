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

    $sudo ./lemptool --help
    Usage:

    lemptool [--option1 --option2 -y ...] [--param1=value1_2 value2_2 --param2=value2_1  ...]

    Option arguments are value less, instead with param arguments you can pass
    string values after the (=) sing.

    Arguments:

     -i,              --install  Proceed to setup repo and install:
                                 nginx + php + mariadb + extra-laravel-development
                                 deb packages. 

                             -y  You can pass this option to skip all the confirmation
                                 messages, is valid for all th below commands/options
     -pki=   --package-install=  Installs os packages.
                                 Usage example:  
                                     $ ./lemptool -pki=htop nodejs git

     -ng        --nginx-install  Installs Nginx server.

     -mdb     --mariadb-install  Installs Mariadb version 10.6.

       --mariadb-user-db-create  Creates a new Mariadb user and a new db with the same
                                 name as user, also grant all rights to that user on
                                 the newly created database.
                                 It needs a user and a password as parameters.
                                 Usage example:
                                  $ ./lemptool --mariadb-user-db-create=user password host

     --mariadb-superuser-create  Creates a new Mariadb superuser. and gran all rights
                                 Usage example:
                                  $ ./lemptool --mariadb-superuser-create=user password host

     -p=         --php-install=  Installs a php version on system together with 
                                 dependencies for laravel development,it also
                                 installs composer.
                                 When used the php version must be passed
                                 as param value.
                                 Usage example:
                                     $ ./lemptool -p=8.0

     -fpm=    --php-fpm-create=  Creates a new php fpm pool, using a template,
                                 it need a valid os user name as a param value.
                                 Usage example:  
                                     $ ./lemptool -fpm=myusername

         --fpm-ng-server-create  Creates a new (laravel in mind), nginx server unit
                                 together with a existing valid fpm pool, a domain
                                 and local public files path to serve  as params.
                                 Usage example:
                                 $ ./lemptool --fpm-ng-server-create="fpm-name" "domain" "/public/path"

     -lemp                       It takes a  OS user create a folder at /var/www/ with the name of 
                                 that user, it solflink it from user home folder and create and
                                 runs  --fpm-ng-server-create and --mariadb-user-db-create
                                 Usage example:
                                 $ ./lemptool lemp="username" "domain" "dbpassword"

           --phpmyadmin-install  Installs phpmyadmin from official source.
                                 It does so using fpm, so it create a php-fpm with
                                 a os 'phpmyadmin' user, also it create an nginx server



