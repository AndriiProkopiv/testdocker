$url = "https://support.lynqmes.com/download2/SilentUtil"
$outputZip = "$PSScriptRoot\SilentUtil.zip"
$outputFolder = "$PSScriptRoot\SilentUtil"
$vcredist_x86 = "$PSScriptRoot\SilentUtil\vcredist_x86.exe"
$vcredist_x64 = "$PSScriptRoot\SilentUtil\vcredist_x64.exe"

$utilExe = "$PSScriptRoot\SilentUtil\Lynq.SilentUtil.exe"
$licenseName = "Lynq syspro"
$product = "LYNQapi"
$installationFolder = "c:\LYNQ\LYNQAPI"
$area = "test"
$environment = "Sandbox"
#$version = "7.0.9"
#$release = "2016 R2 SP1"

$installationConfigExe = $installationFolder + "\Lynq.PG.AfterInstall.exe"
$settingsFile = "$PSScriptRoot\settings.cfg"

$settingsContent = (@{LicenseName=$licenseName;
Environment=$environment;

	IISSettings = @{
		LYNQapiSiteName="LYNQapi"
		LYNQapiPort="80"
		LYNQapiUseLocalhost="False"
	}

	DBSettings = @{
		LYNQapiServer="192.168.1.12"
		LYNQapiDatabase="LYNQapi_Docker"
		LYNQapiDatabaseCreateFlag="True"
		LYNQapiSQLLogin="t1"
		LYNQapiSQLLoginCreateFlag="False"
		LYNQapiSQLPassword="t1"
	}

	AppPoolSettings = @{
		LYNQapiAppPoolShutDownLimit="305"
		LYNQapiAppPoolRegularTimeIntervalFlag="True"
		LYNQapiAppPoolRegularTimeInterval="1740"
		LYNQapiAppPoolSpecificRecycleTimeFlag="False"
		LYNQapiAppPoolSpecificRecycleTime=""
	}

	SiteConfiguration = @{
		LYNQapiSiteLastConnectionCount="1"
		LYNQapiAdministrator="Lynqadmin"
	}
	SQLAuthentication = @{
		LYNQapiAdminAuthWindows="False"
		LYNQapiAdminLogin="t1"
		LYNQapiAdminPassword="t1"
	}

} | ConvertTo-Json -Compress)

$start_time = Get-Date

#Download the install utility
if (-Not (Test-Path $outputFolder))
{
	#Download
	Import-Module BitsTransfer
	Start-BitsTransfer -Source $url -Destination $outputZip

	#Extract
	Expand-Archive $outputZip -DestinationPath $outputFolder

	#Delete archieve
	Remove-Item $outputZip 

	#Check Visual C++ Redistributable 2010
	Start-Process -FilePath $vcredist_x86 -ArgumentList “/passive” -Wait -Passthru;
	if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "64*")
	{
		Start-Process -FilePath $vcredist_x64 -ArgumentList “/passive” -Wait -Passthru;
	}
}

#Start the utility
& $utilExe /l $licenseName /p $product /f $installationFolder /a $area #/e $environment #/v $version #  /r $release

$result = $?
if($result  -eq $false)
{
	throw ("Installation error")
}

if (Test-Path $installationConfigExe)
{
	#Create settings file
	if (Test-Path $settingsFile)
	{
		Remove-Item $settingsFile
	}

	New-Item $settingsFile
	Set-Content $settingsFile $settingsContent 


	#Configure application
	& $installationConfigExe /f $settingsFile

	$result = $?
	Remove-Item $settingsFile

	if($result  -eq $false)
	{
		throw ("Configuration error")
	}
}

Write-Output "Time taken: $((Get-Date).Subtract($start_time))"