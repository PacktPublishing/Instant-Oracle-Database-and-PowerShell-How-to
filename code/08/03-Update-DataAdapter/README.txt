About
=====
This example illustrates selecting data into a DataTable using a data adapter, 
making modifications to the DataTable, and then using the adapter to update the Oracle table with the changes.

Before Running
==============
You may have to first disable the trigger SECURE_DML in the HR schema if running this outside of M-F 8a-8p
	ALTER TRIGGER SECURE_EMPLOYEES DISABLE;
then optionally enable it later:
	ALTER TRIGGER SECURE_EMPLOYEES ENABLE;
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in Get-ConnectionString, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm

* Change the password in Get-ConnectionString to match what you used when setting up Oracle Express (Getting Started).






	
