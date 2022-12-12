<#
.SYNOPSIS
  List 32 bit and 64 bit processes
.DESCRIPTION
  Date: 03/01/2015
  Utilize `System.Diagnostics.Process` to list processes
.EXAMPLE
  List-Process

.NOTES
  Refs
  - https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process

tag: windows-only
#>

[System.Diagnostics.Process[]] $processes64bit = @()
[System.Diagnostics.Process[]] $processes32bit = @()

foreach($process in get-process) {
    $modules = $process.modules
    foreach($module in $modules) {
        $file = [System.IO.Path]::GetFileName($module.FileName).ToLower()
        if($file -eq "wow64.dll") {
            $processes32bit += $process
            break
        }
    }

    if(!($processes32bit -contains $process)) {
        $processes64bit += $process
    }
}

'32-bit Processes:'
$processes32bit | sort-object Name | format-table Name, Id -auto

Write-host # New Line
'64-bit Processes:'
$processes64bit | sort-object Name | format-table Name, Id -auto
