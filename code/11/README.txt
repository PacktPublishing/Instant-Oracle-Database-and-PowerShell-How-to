About
=====
This example provides a script written with the intention of being run from a scheduled task. 
It demonstrates error handling and transcription. 

Creating the Scheduled Task
===========================
Quickly launch scheduled tasks:
Windows Key + R -> Taskschd.msc
 
Create a scheduled task with the following as the command, changing the path if you need the 64 bit or another ver:
%SystemRoot%\syswow64\WindowsPowerShell\v1.0\powershell.exe

Use the below for the Arguments, changing the paths as needed:
 -NonInteractive -Command "& c:\Scripts\HighCommission.ps1 -outputPath 'C:\Dropbox\Report Outbox\' -commissionThreshold .3; exit $LASTEXITCODE"
	
Prerequisities
===============
ODAC installation - http://www.oracle.com/technetwork/developer-tools/visual-studio/downloads/index.html

To connect using the specific connection string used in App.Config, you will need to:
* Install Oracle Express: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

* Complete the steps in the Oracle Express Getting Started guide such as unlocking the HR account and setting the password:
  http://docs.oracle.com/cd/E17781_01/admin.112/e18585/toc.htm

* Change the password in the connection string of App.Config to match what you used when setting up Oracle Express (Getting Started).




 
