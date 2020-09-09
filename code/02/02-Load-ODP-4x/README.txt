About
=====
This script loads ODP.NET 4.x, verifies it loaded, enumerates public types in the assembly and creates a connection object.

Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

See chapter 1 for more information on version and options.

Ensure you open the appropriate x86 or x64 version of PowerShell; see Chapter 1 for more information.

If you are using PowerShell 2.0 you must complete additional work to use the 4.x version which uses .NET Framework 4.0.
See Chapter 2 for more information. The recommended approach is editing PowerShell's config files: http://poshcode.org/2045


Location of ODP.NET
===================
The 4.x version of the Oracle.DataAccess.dll assembly is installed to the following location by the ODAC setup:

ORACLE_BASE\ORACLE_HOME\odp.net\bin\4

For example: C:\app\{username}\product\11.2.0\client_1\odp.net\bin\4

The setup installs this DLL into the GAC at %WINDIR%\Microsoft.NET\assembly where it will be loaded from.