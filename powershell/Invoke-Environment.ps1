<#
.SYNOPSIS
    Invokes a command and imports its environment variables.

.DESCRIPTION
    Date: 06/19/2011
    TODO: check later if this script came as part of the old VS Installation.

    It invokes any cmd shell command (normally a configuration batch file) and
    imports its environment variables to the calling process. Command output is
    discarded completely. It fails if the command exit code is not 0. To ignore
    the exit code use the 'call' command.

.EXAMPLE
    1. Invokes Config.bat in the current directory or the system path
    Invoke-Environment Config.bat

    2. Visual Studio environment: works even if exit code is not 0
    Invoke-Environment 'call "%VS100COMNTOOLS%\vsvars32.bat"'

    3. This command fails if vsvars32.bat exit code is not 0
    Invoke-Environment '"%VS100COMNTOOLS%\vsvars32.bat"'
#>

param
(
    [Parameter(Mandatory=$true)] [string]
    # Any cmd shell command, normally a configuration batch file.
    $Command
)

cmd /c "$Command > nul 2>&1 && set" | .{
    process{
        if ($_ -match '^([^=]+)=(.*)') {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
}

if ($LASTEXITCODE) {
    throw "Command '$Command': exit code: $LASTEXITCODE"
}
