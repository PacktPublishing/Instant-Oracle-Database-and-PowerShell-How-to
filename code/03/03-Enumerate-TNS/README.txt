About
=====
This script enumerates TNS entries on your system.

Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To get results you will need one or more TNS entries in your ORACLE_BASE\ORACLE_HOME\Network\Admin\tnsnames.ora file (create if not there from Sample dir). 
For example: C:\app\username\product\11.2.0\client_1\Network\Admin\tnsnames.ora

If you need a sample, add the below entry and save:

LOCALDEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = xe)
    )
  )
