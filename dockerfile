FROM mcr.microsoft.com/windows/servercore/iis:latest

#enabling IIS related windows features
RUN dism.exe /online /enable-feature /all /featurename:IIS-WebServerRole /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-WebServer /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-CommonHttpFeatures /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-HttpErrors /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-HttpRedirect /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:NetFx4Extended-ASPNET45 /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-NetFxExtensibility45 /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-HealthAndDiagnostics /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-HttpLogging /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-LoggingLibraries /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-RequestMonitor /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-HttpTracing /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-Security /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-RequestFiltering /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-Performance /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-WebServerManagementTools /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-IIS6ManagementCompatibility /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-Metabase /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-ManagementConsole /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-BasicAuthentication /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-WindowsAuthentication /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-StaticContent /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-DefaultDocument /NoRestart
#RUN dism.exe /online /enable-feature /all /featurename:IIS-WebSockets /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-ApplicationInit /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-ISAPIExtensions /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-ISAPIFilter /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-HttpCompressionStatic /NoRestart
RUN dism.exe /online /enable-feature /all /featurename:IIS-ASPNET45 /NoRestart

SHELL [ "powershell" ]

RUN Install-WindowsFeature NET-WCF-HTTP-Activation45

#local user creation
RUN net user lynqadmin Atc12345 /ADD; \
net localgroup administrators lynqadmin /add;

COPY \\InstallationMES.ps1 C:/install/installationMES.ps1
COPY \\InstallationAPI.ps1 C:/install/installationAPI.ps1

WORKDIR /Install


#running installation scripts

RUN C:/install/installationMES.ps1

#RUN C:/install/installationAPI.ps1