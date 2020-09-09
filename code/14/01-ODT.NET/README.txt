About
=====
This example demonstrates using the Oracle.Management.Omo assembly included with Oracle Developer Tools for .NET.
This assembly is used from within Visual Studio and integrated with the Server Explorer for example. 
Use of this assembly is not documented or supported as it is intended to only be for use from within Visual Studio.
However we can take advantage of its features; just beware that you are on your own. 

This assembly can be found at:
	- ORACLE_BASE\ORACLE_HOME\odt\vs2010
	  i.e. C:\app\[username]\product\11.2.0\client_1\odt\vs2010
	  
	- Global Assembly Cache
	  i.e. C:\Windows\Microsoft.NET\assembly\GAC_32\Oracle.Management.Omo\v4.0_4.112.3.0__89b483f429c47342

Setup To Run
===========================
Ensure your PowerShell environment is configured to run .NET 4.0 assemblies. See the recipe Accessing Oracle 
for an example of configuring PowerShell to load .NET 4.0 assemblies.

Ensure you have a TNS name entry setup for Oracle Express on localhost; LOCALDEV is used in this script. 
Adjust the TNS name and password as needed in the connection code.
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in App.Config, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm






 






