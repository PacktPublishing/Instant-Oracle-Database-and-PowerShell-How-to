About
=====
This script connects to the sample HR database (included with Oracle Express) using a connection string that specifies a TNS entry.

Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in Get-ConnectionString, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm

* Change the password in Get-ConnectionString to match what you used when setting up Oracle Express (Getting Started).

* Open your ORACLE_BASE\ORACLE_HOME\Network\Admin\tnsnames.ora file (create if not there from Sample dir). For example:
  C:\app\username\product\11.2.0\client_1\Network\Admin\tnsnames.ora

  Add the below entry and save:

LOCALDEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = xe)
    )
  )
