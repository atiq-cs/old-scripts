<#
   Date    : 12/31/2012
   Desc    : Append text to item

   valid usage example:
        $ .\Tag-Directories.ps1 -d I:\temp -t " (itunes aac)"
 #>

Param(
    [Parameter(Mandatory=$true)]
    [alias("d")]
    [string]$DirectoryName,
    [Parameter(Mandatory=$true)]
    [alias("t")]
    [string]$Tag)


if ((Test-Path -path $DirectoryName -pathtype leaf) -or !(Test-Path $DirectoryName)) {
    Write-Host "Please provide proper directory name of destination.`n"
    break
}

gci $DirectoryName | %{
    # Check if object is moved
    if (! $_.Exists) {
        Write-Host "Object doesn't exist anymore! Probably moved!"
    }
    # check if it is directory
    elseif ($_.PSIsContainer) {
        $PreviousName=$_.FullName

        # Using dirty names because wildcard cannot be used with literal path option
        $PreviousNameDirty = $PreviousName.Replace('[', '`[')
        $PreviousNameDirty = $PreviousNameDirty.Replace(']', '`]')

        if (Test-Path -Path "$PreviousNameDirty\*") {
            if ($PreviousName.EndsWith($Tag)) {
                Write-Host "Object" $_.BaseName "already tagged."
            }
            else {
                Write-Host "Renaming" $_.BaseName
                $NewName=$PreviousName+" "+$Tag
                Rename-Item -literalPath $PreviousName $NewName
            }
        }
        else {
            Write-Host "Directory" $_.BaseName "is empty. Deleting it"
            Remove-Item -literalPath $PreviousName
        }
    }
}

Write-Host "Objects tagged.`n"
