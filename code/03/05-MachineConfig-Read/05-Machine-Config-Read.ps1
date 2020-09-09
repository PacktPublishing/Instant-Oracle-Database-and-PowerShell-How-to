# %WINDIR%\Microsoft.NET\Framework\v2.0.50727\Config
$config = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()  
$connectString = $config.ConnectionStrings.ConnectionStrings["AppConnect"]
Write-Output "Connect string is $connectString"