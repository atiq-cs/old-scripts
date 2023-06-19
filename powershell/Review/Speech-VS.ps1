<#
.SYNOPSIS
Opens Visual Studio Solution for Speech Projects and Update Repository
.DESCRIPTION
Speech-VS.ps1 both update
 updates both truman host project and testhost project
Speech-VS.ps1 sr
 Opens SR project, equivalent is 'Speech-VS.ps1 sr open'

.PARAMETER ProjectName
sr, all
.PARAMETER Action
open or build or update
.PARAMETER IsElevated
Should we run build as admin or open in Visual Studio
.EXAMPLE
  Speech-VS.ps1 sr
  Speech-VS.ps1 sr open
  Speech-VS.ps1 TestClient -IsElevated $true
  Speech-VS.ps1 both update
  Speech-VS.ps1 both build
  Speech-VS.ps1 sr build

.NOTES
More params can be added later if required

Date: 2018-09-05
#>

[CmdletBinding()] Param (
  [ValidateSet('sr', 'tts', 'ggs', 'shared', 'testhost', 'classicprobes', 'testclient', 'e2etests', `
  'all', 'both')] [string] $ProjectName,
  [ValidateSet('update', 'build', 'open')] [string] $Action = 'open',
  [bool] $IsElevated = $False)

<# reserved for future
# Purpose of this function is to verify arguments
function VERIFY_PARAMETERS() {
}
#>

function LaunchSolution([string] $ProjectPath, [string] $ProjetTitle) {
  if ($ProjectName -like "all") {
      $SlnPath = $Env:Root + "private\All.sln"
  }
  else {
      $SlnPath = $ProjectPath + ".sln"
      $ProjectPath = $ProjectPath + ".csproj"
  }
  # better order of output,
  if (! (Test-Path $SlnPath)) {
    Write-Host "Generating solution file"
  }
  Write-Host -NoNewline "Opening project`: $ProjetTitle in Visual Studio"
  if ($IsElevated) {
    Write-Host " (elevated)..."
      if (Test-Path $SlnPath) {
    # Solves,
    # Start-Process : This command cannot be run due to the error: No application is associated with the specified file for this operation.
    # devenv doesn't work
    Start-Process devenv.exe -Verb Runas -ErrorAction 'stop' -ArgumentList $SlnPath
    }
    else {
      $arguments = '/NoLogo', '/Verbosity:Minimal', '/Target:SlnGen', `
        '/Property:ExcludeRestorePackageImports=true', '/Property:DesignTimeBuild=true', $ProjectPath
      Start-Process $Env:VSINSTALLDIR\MSBuild\15.0\bin\MSBuild.exe -Verb runAs -ArgumentList $arguments
    }
  }
  else {
    Write-Host " (normal user)..."
    if (Test-Path $SlnPath) { Start-Process $SlnPath }
    else {
      MSBuild /NoLogo /Verbosity:Minimal /Target:SlnGen `
      /Property:ExcludeRestorePackageImports=true /Property:DesignTimeBuild=true $ProjectPath
    }
  }
}

# Update Local Git Branch
function UpdateGitBranch() {
  if (! $Env:Root) {
    throw [InvalidOperationException] 'Initialize speech env first please.'
  }

  if (! (Test-Path "$Env:PFilesX64\git")) {
    throw [InvalidOperationException] 'Please install git.'
  }

  # Ensure git branch to be master

  $oldLocation = Get-Location
  # Take care of CU dir
  $PDir = $Env:Root + '\private\Truman\Bing.Platform.Truman.Host\CU'
  Write-Host 'Cleaning' $PDir
  Set-Location $PDir
  # Minimal Verbosity
  msbuild /t:Clean /m /v:m
  if (Test-Path Bing.Platform.Truman.Host.sln) {
    Remove-Item Bing.Platform.Truman.Host.sln
  }

  # Take care of Test dir
  $PDir = $Env:Root + '\private\Hosts\Test'
  Write-Host 'Cleaning' $PDir
  Set-Location $PDir
  msbuild /t:Clean /m /v:m
  if (Test-Path Test.Host.sln) {
    Remove-Item Test.Host.sln
  }

  Set-Location $Env:Root
  git pull origin master
  Set-Location $oldLocation
}

# Start of Main function
function Main() {
  if (! $Env:ROOT) {
    "Speech Env is initialized not yet."
    return
  }
  switch( $Action ) {
    'update' {
      'Running clean and update..'
      UpdateGitBranch
      return
    }
    'build' {
      if ($ProjectName -eq 'both' -Or $ProjectName -eq 'TestHost') {
          # build test Host first
          $ProjName = 'Test Host'
          pushd $Env:ROOT\private\Hosts\Test
          'Building ' + $ProjName + '..'
          msbuild /m /v:m

          # https://stackoverflow.com/questions/4010763/msbuild-in-a-powershell-script-how-do-i-know-if-the-build-succeeded
          if ($LastExitCode -ne 0) {
            $ProjName + ' build failed!'
            popd
            return
          }
          'Running ' + $ProjName + '..'
          $cmdArg = 'dotnet ' + $Env:App + '\TestHost\Test.Host.dll'
          Start-Process cmd /c, $cmdArg
          popd
      }
      if ($ProjectName -eq 'both' -Or $ProjectName -eq 'SR') {
          # Build CU
          $ProjName = 'Truman Service'
          pushd $Env:ROOT\private\Truman\Bing.Platform.Truman.Host\CU
          "`r`nBuilding " + $ProjName + '..'
          msbuild /m /v:m
          if ($LastExitCode -ne 0) {
            $ProjName + ' build failed!'
            popd
            return
          }

          'Running ' + $ProjName + '..'
          . $Env:App\TrumanHost\start.bat
          $ProjName + ' is shut down'
          popd
      }
      return
    }
    'Open' {
      'Running legacy open solution..'
    }
    default {
      'Unknown command line argument: ' + $Action + ' provided!'
      return
    }
  }

  # check if speech initialization is done yet
  if ($ProjectName -like "sr") {
    $PPath = $Env:Root + "private\Truman\Bing.Platform.Truman.Host\CU\Bing.Platform.Truman.Host"
    $ProjetTitle = "Speech Recognition`: Truman Host"
  }
  elseif($ProjectName -like "tts") {
    $PPath = $Env:Root + "private\Truman\Bing.Platform.Truman.Host\Tts\Bing.Platform.Truman.Host.Tts"
  }
  elseif($ProjectName -like "ggs") {
    $PPath = $Env:Root + "private\Truman\Bing.Platform.Truman.Host\GrammarGeneration\src\Bing.Platform.Truman.Host.GrammarGeneration"
  }
  elseif($ProjectName -like "shared") {
    # REM always rebuild $Env:Root + "private\shared\dirs.proj"
    # msbuild /m /v:q /nologo /t:SlnGen $Env:Root + "private\shared\dirs.proj"
  }
  elseif($ProjectName -like "TestHost" -Or $ProjectName -like "E2ETests") {
    $PPath = $Env:Root + "private\Hosts\Test\Test.Host"
    $ProjetTitle = "Truman Test Host"
  }
  elseif($ProjectName -like "classicprobes") {
    # REM always rebuild $Env:Root + "private\EndToEndTest\dirs.proj"
    # call:slnGen $Env:Root + "private\EndToEndTest\dirs.proj"
  }
  elseif($ProjectName -like "testclient") {
    $PPath = $Env:Root + "private\Platform\Platform.Test.Client\Platform.Test.Client"
    $ProjetTitle = "Platform Test CLient"
  }
  elseif($ProjectName -like "all") {
    # REM always rebuild dirs.proj
    # call:slnGen $Env:Root + "private\dirs.proj"
    $PPath = $Env:Root + "private\dirs.proj"
    $ProjetTitle = "All"
  }
  else {
     # not required since it is taken care of by ValidateSet
    throw [ArgumentException] 'Invalid project name specified!'
  }

  LaunchSolution $PPath $ProjetTitle
}

Main
