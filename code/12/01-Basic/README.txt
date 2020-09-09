About
=====
This example demonstrates creating a reusable script module for Oracle.

Setup To Run
===========================
First copy the Oracle.DataAccess folder to %USERPROFILE%\Documents\WindowsPowerShell\Modules\

Alternatively run the below and place in a folder that appears in the results (or alter PSModulePath):
$env:PSModulePath.Split(";")
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in App.Config, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm

* Change the password in the connection string of App.Config to match what you used when setting up Oracle Express (Getting Started).




 






