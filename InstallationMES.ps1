$url = "https://support.lynqmes.com/download2/SilentUtil"
$outputZip = "$PSScriptRoot\SilentUtil.zip"
$outputFolder = "$PSScriptRoot\SilentUtil"
$vcredist_x86 = "$PSScriptRoot\SilentUtil\vcredist_x86.exe"
$vcredist_x64 = "$PSScriptRoot\SilentUtil\vcredist_x64.exe"

$utilExe = "$PSScriptRoot\SilentUtil\Lynq.SilentUtil.exe"
$licenseName = "Lynq syspro"
$product = "LYNQmes"
$installationFolder = "c:\LYNQ\LYNQMES"
$webconfig=$installationFolder + "\site\web.config"

$area = "test"
$environment = "Sandbox"
#$version = "5.1.2"
#$release = "2016 R2 SP1"

$installationUpdateExe = $installationFolder + "\BeforeUpdate.exe"
$installationConfigExe = $installationFolder + "\Configurator.exe"
$settingsFile = "$PSScriptRoot\settings.cfg"

$settingsContent = (@{LicenseName=$licenseName;
Environment=$environment;

UseWindowsAuthentification="False"
SQLServerLogin="t1"
SQLServerPassword="t1"

DisplayName="Manufacturing Operations Management"
SiteName="LYNQMES"
SelectedPortNo="80"
Datasource="SYSPRO_APS"
Administrators="lynqadmin"

ErpServer="192.168.1.12"
ErpDatabase="SysproCompanyDMOM"
ErpUser="t1"
ErpPassword="t1"
ErpCreateDB="False"
ErpCreateUser="False"

DataServer="192.168.1.12"
DataDatabase="SysproCompanyDMOM_Data"
DataUser="t1"
DataPassword="t1"
DataCreateDB="False"
DataCreateUser="False"

ConfigServer="192.168.1.12"
ConfigDatabase="SysproCompanyDMOM_Config"
ConfigUser="t1"
ConfigPassword="t1"
ConfigCreateDB="False"
ConfigCreateUser="False"

LogicServer="192.168.1.12"
LogicDatabase="SysproCompanyDMOM_Logic"
LogicUser="t1"
LogicPassword="t1"
LogicCreateDB="False"
LogicCreateUser="False"

FactoryServer="192.168.1.12"
FactoryDatabase="SysproCompanyDMOM_FA"
FactoryUser="t1"
FactoryPassword="t1"
FactoryCreateDB="False"
FactoryCreateUser="False"

UseStatisticsDB="true"
StatisticsDays="33"
StatisticsServer="192.168.1.12"
StatisticsDatabase="SysproCompanyDMOM_Live"
StatisticsUser="t1"
StatisticsPassword="t1"
StatisticsCreateDB="False"
StatisticsCreateUser="False"} | ConvertTo-Json -Compress)

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

if (Test-Path $webconfig)
{
	& $installationUpdateExe
}


#Start the utility
& $utilExe /l $licenseName /p $product /f $installationFolder /a $area /e $environment #/v $version #  /r $release

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