About
=====
This script performs a bulk insert of country data from the countries.xml file into the COUNTRIES table of 
Oracle's sample HR database using OracleBulkCopy.

Before Running
==============
If running the script multiple times, run Delete_Inserted_Data.sql as script in a DBMS tool first to remove previously inserted records.
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in Get-ConnectionString, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm

* Change the password in Get-ConnectionString to match what you used when setting up Oracle Express (Getting Started).
