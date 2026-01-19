function Get-Example {
    <#
    .SYNOPSIS
        Example public function.

    .DESCRIPTION
        This is an example public function that will be exported from the module.

    .PARAMETER Name
        The name to greet.

    .EXAMPLE
        Get-Example -Name "World"
        Returns "Hello, World!"

    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return "Hello, $Name!"
}
