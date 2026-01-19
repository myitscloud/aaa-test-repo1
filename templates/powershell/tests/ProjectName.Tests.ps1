# Pester tests for ProjectName module

BeforeAll {
    # Import the module
    $ModulePath = Join-Path $PSScriptRoot '..' 'src' 'ProjectName.psm1'
    Import-Module $ModulePath -Force
}

Describe 'Get-Example' {
    It 'Returns greeting with provided name' {
        $result = Get-Example -Name 'World'
        $result | Should -Be 'Hello, World!'
    }

    It 'Requires Name parameter' {
        { Get-Example } | Should -Throw
    }
}

AfterAll {
    # Clean up
    Remove-Module ProjectName -ErrorAction SilentlyContinue
}
