function Write-Log {
    <#
    .SYNOPSIS
        Internal logging function.

    .DESCRIPTION
        This is an example private function for internal use only.

    .PARAMETER Message
        The message to log.

    .PARAMETER Level
        The log level (Info, Warning, Error).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Verbose "[$timestamp] [$Level] $Message"
}
