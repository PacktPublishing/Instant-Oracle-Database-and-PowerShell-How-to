About
=====
This script shows an example of using ms charting with Oracle Data Access.

Setup To Run
===========================
Microsoft Charting is included with the .NET Framework 4.0; ensure your PowerShell environment is configured to run .NET 4.0 assemblies to use it. See the recipe Accessing Oracle 
for an example of configuring PowerShell to load .NET 4.0 assemblies. 

Alternatively you can separately download Microsoft Charting for the .NET Framework 3.5 and use that directly from PowerShell v2 without any additional changes:
	http://www.microsoft.com/en-us/download/details.aspx?id=14422

Ensure you have a TNS name entry setup for Oracle Express on localhost; LOCALDEV is used in this script. 
Adjust the TNS name and password as needed in the connection code.
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the connection and database in this example, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm






 






