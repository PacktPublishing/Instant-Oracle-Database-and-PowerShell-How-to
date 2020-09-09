About
=====
This script loads ODP.NET 2.x, verifies it loaded, enumerates public types in the assembly and creates a connection object.

Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

See chapter 1 for more information on version and options.

Ensure you open the appropriate x86 or x64 version of PowerShell; see Chapter 1 for more information.


Location of ODP.NET
===================
The 2.x version of the Oracle.DataAccess.dll assembly is installed to the following location by the ODAC setup:

ORACLE_BASE\ORACLE_HOME\odp.net\bin\2.x

For example: C:\app\{username}\product\11.2.0\client_1\odp.net\bin\2.x

The setup installs this DLL into the GAC at %WINDIR%\assembly\ where it will be loaded from.