<#
.SYNOPSIS
  Show timed pop up using Windows Forms
.DESCRIPTION
  Date: 08/30/2013
  Utilizes Windows Forms, Invokes from Powershell

.EXAMPLE
  Show-TimedPopUp 5

.NOTES
  Demonstrations,
  - Invokes Windows UI Classes (Forms in this case) from Powershell

  [windows.forms.messagebox] Refs
  - https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messagebox.show
  - https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxbuttons
#>


param(
    [parameter(Mandatory=$true)]
    [int] $time
)

# Load the assembly first
# Out-Null suppresses the output
# ref, https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/out-null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

# wait for specified time
for ($i=1; $i -le $time; $i++)
{
    Sleep 1
    Write-Host -NoNewline "`rTime elapsed" $i"s"
}

Write-Host ""

# ref 1: https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messagebox.show
# ref 2: https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxbuttons
[windows.forms.messagebox]::show("Time has expired " + $time + "s","Delay Pop Up","OKCANCEL")

<#
Always returns OK for button sytle OK
However for OKCANCEL it returns cancel on close and on choosing cancel

if ($res -eq "OK" )
{
    Write-Host "You selected" $res
} 
else
{ 
    Write-Host "You selected close."
}
#>