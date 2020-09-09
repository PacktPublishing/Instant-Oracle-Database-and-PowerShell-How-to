About
=====
This script reads a connection string from machine.config.

Prerequisities
===============
This example assumes a connection string named "AppConnect" exists in machine.config. To add it, complete the below.

Open the folder %WINDIR%\Microsoft.NET\Framework\[Version]\Config\ where [Version] is the .Net framework version you are using in your PowerShell script.
For example: C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\

Open machine.config in a text editor. Location the <connectionStrings> tag under <configuration> and add:

<add name="AppConnect" connectionString="Data Source=LOCALDEV;User Id=HR;Password=pass;Connection Timeout=10"/>
