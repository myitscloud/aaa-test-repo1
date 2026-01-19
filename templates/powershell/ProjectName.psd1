@{
    # Module manifest for ProjectName

    # Script module file associated with this manifest
    RootModule = 'src/ProjectName.psm1'

    # Version number of this module
    ModuleVersion = '0.1.0'

    # ID used to uniquely identify this module
    GUID = '00000000-0000-0000-0000-000000000000'

    # Author of this module
    Author = 'Your Name'

    # Company or vendor of this module
    CompanyName = 'Your Company'

    # Description of the functionality provided by this module
    Description = 'Project description'

    # Minimum version of PowerShell required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @('Get-Example')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule
    PrivateData = @{
        PSData = @{
            Tags = @('Template')
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = ''
        }
    }
}
