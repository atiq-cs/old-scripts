<#
.SYNOPSIS
Initializes speech platform
.DESCRIPTION
Uses msbuild and vs environment variables to gradually construct
Date: 2018-08-27
.EXAMPLE
Usage Example,
  Speech-Initialize.ps1

.NOTES
Exclusion list,
 D:\PFiles_x86\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;
 C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;
 and choco,
  D:\PFiles_x64\Chocolatey\bin;
#>

<# reserved for future
# Purpose of this function is to verify arguments
function VERIFY_PARAMETERS() {
}
#>

# Entry Point
function Main() {
  $Env:ROOT = 'D:\Code\speech\Truman\'
  $Env:TEST = $Env:ROOT + 'target\distrib\debug\amd64\test\'

  $VSCustomInstallDir = 'D:\PFiles_x86\MSVS\'
  # gci "$VSCustomInstallDir\2017\Enterprise\VC\Tools\MSVC
  $VCToolsVersion = '14.16.27023'
  $Env:APP = 'D:\Code\speech\Truman\target\distrib\debug\amd64\app\'
  $Env:ASPNETCORE_ENVIRONMENT = 'Development'
  $Env:CommandPromptType = 'Native'
  $Env:VSINSTALLDIR = $VSCustomInstallDir + '2017\Enterprise\'
  $Env:DevEnvDir = $Env:VSINSTALLDIR + 'Common7\IDE\'
  $Env:DotNetRequiredVersion = '2.1.302'
  # updated recently
  $Env:DotNetVersion = '2.1.500'
  $Env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
  $Env:ExtensionSdkDir = 'C:\Program Files (x86)\Microsoft SDKs\Windows Kits\10\ExtensionSDKs'
  $Env:Framework40Version = 'v4.0'
  $Env:FrameworkDir = 'C:\Windows\Microsoft.NET\Framework\'
  $Env:FrameworkDir32 = $Env:FrameworkDir
  $Env:FrameworkVersion = 'v4.0.30319'
  $Env:FrameworkVersion32 = $Env:FrameworkVersion
  $Env:FSHARPINSTALLDIR = $Env:VSINSTALLDIR + 'Common7\IDE\CommonExtensions\Microsoft\FSharp\'
  $Env:installError = 'false'
  $Env:NETFXSDKDir = 'C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\'
  $Env:PACKAGESROOT = 'C:\Users\v-mdra\.nuget\packages'
  $Env:PROJ_FLAG = 'true'
  $Env:UCRTVersion = '10.0.17134.0'
  $Env:UniversalCRTSdkDir = 'D:\Windows Kits\10\'
  $Env:VCIDEInstallDir = $Env:VSINSTALLDIR + 'Common7\IDE\VC\'
  $Env:VCINSTALLDIR = $Env:VSINSTALLDIR + 'VC\'
  # deprecated
  # $Env:VCToolsInstallDir = $Env:VSINSTALLDIR + 'VC\Tools\MSVC\' + $VCToolsVersion + '\'
  # $Env:VCToolsRedistDir = $Env:VSINSTALLDIR + 'VC\Redist\MSVC\14.15.26706\'
  # not used by other vers, cannot find in developer prompt as well
  $Env:VisualStudioRequiredVersion = '15.7.5'
  $Env:VisualStudioVersion = '15.0'
  $Env:VS150COMNTOOLS = $Env:VSINSTALLDIR + 'Common7\Tools\'
  # ATL//MFC dir does not exist
  # $Env:VSINSTALLDIR + 'VC\Tools\MSVC\' + $VCToolsVersion + '\ATLMFC\include;' + 
  # include dir deprecated
  #  $Env:VCINSTALLDIR + 'VC\Tools\MSVC\' + $VCToolsVersion + '\include;
  $Env:INCLUDE = $Env:NETFXSDKDir + 'include\um;D:\Windows Kits\10\include\10.0.17134.0\ucrt;D:\Windows Kits\10\include\10.0.17134.0\shared;D:\Windows Kits\10\include\10.0.17134.0\um;D:\Windows Kits\10\include\10.0.17134.0\winrt;D:\Windows Kits\10\include\10.0.17134.0\cppwinrt'
  # ATL//MFC not available - if not installed: $Env:VSINSTALLDIR + 'VC\Tools\MSVC\' + $VCToolsVersion + '\ATLMFC\lib\x86;
  # first one in onecore seems to be deprecated, but we are keeping it as it exists
  $Env:LIB =  $Env:VCINSTALLDIR + 'Tools\MSVC\' + $VCToolsVersion + '\lib\onecore\x86;' + $Env:NETFXSDKDir + 'lib\um\x86;D:\Windows Kits\10\lib\10.0.17134.0\ucrt\x86;D:\Windows Kits\10\lib\10.0.17134.0\um\x86;'
  # ATL//MFC dir does not exist
  # $Env:VCINSTALLDIR + 'Tools\MSVC\' + $VCToolsVersion + '\ATLMFC\lib\x86;' + 
  # vctools x86 lib exist, keeping though it is deprecated
  # store/references deprecated
  # $Env:VCINSTALLDIR + 'Tools\MSVC\' + $VCToolsVersion + '\lib\x86\store\references;
  $Env:LIBPATH = $Env:VCINSTALLDIR + 'Tools\MSVC\' + $VCToolsVersion + '\lib\onecore\x86;' + 'D:\Windows Kits\10\UnionMetadata\10.0.17134.0;D:\Windows Kits\10\References\10.0.17134.0;C:\Windows\Microsoft.NET\Framework\v4.0.30319;'
  $Env:VSCMD_ARG_app_plat = 'Desktop'
  $Env:VSCMD_ARG_HOST_ARCH = 'x86'
  $Env:VSCMD_ARG_no_logo = '1'
  $Env:VSCMD_ARG_TGT_ARCH = 'x86'
  $Env:VSCMD_VER = '15.9.0'
  $Env:WindowsLibPath = 'D:\Windows Kits\10\UnionMetadata\10.0.17134.0;D:\Windows Kits\10\References\10.0.17134.0'
  $Env:WindowsSdkDir = 'D:\Windows Kits\10\'
  $Env:WindowsSdkBinPath = $Env:WindowsSdkDir + 'bin\'
  $Env:WindowsSDKVersion = '10.0.17134.0\'
  $Env:WindowsSdkVerBinPath = $Env:WindowsSdkBinPath + $Env:WindowsSDKVersion
  $Env:WindowsSDKLibVersion = '10.0.17134.0\'
  $Env:WindowsSDK_ExecutablePath_x86 = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\'
  $Env:WindowsSDK_ExecutablePath_x64 = $Env:WindowsSDK_ExecutablePath_x86 + 'x64\'
  $Env:__DOTNET_ADD_32BIT = '1'
  $Env:__DOTNET_PREFERRED_BITNESS = '32'
  $Env:Path += ';' + $Env:VCINSTALLDIR + `
  'Tools\MSVC\' + $VCToolsVersion + '\bin\HostX86\x86;' + $Env:VCIDEInstallDir +`
  'VCPackages;C:\Program Files (x86)\Microsoft SDKs\TypeScript\3.0;' +`
  $Env:DevEnvDir + 'CommonExtensions\Microsoft\TestWindow;' + $Env:VSINSTALLDIR + `
  'MSBuild\15.0\bin\Roslyn;' + $Env:VSINSTALLDIR + 'Team Tools\Performance Tools;'+`
  'D:\PFiles_x86\Microsoft Visual Studio\Shared\Common\VSPerfCollectionToolss'+`
  ';' + $Env:WindowsSDK_ExecutablePath_x86 + ';' + $Env:FSHARPINSTALLDIR + ';'`
   + $Env:WindowsSdkVerBinPath + 'x86;' + $Env:WindowsSdkBinPath + 'x86;'+`
  $Env:VSINSTALLDIR + 'MSBuild\15.0\bin;C:\'+`
  'Windows\Microsoft.NET\Framework\v4.0.30319;' + $Env:DevEnvDir + ';' +`
  $Env:VS150COMNTOOLS + ';' + $Env:DevEnvDir + 'CommonExtensions\Microsoft\'+`
  'CMake\CMake\bin;' + $Env:DevEnvDir + 'Common7\IDE\CommonExtensions\'+`
  'Microsoft\CMake\Ninja'

  pushd $Env:ROOT
}

Main
