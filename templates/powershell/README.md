# PowerShell Project Template

Minimal starter template for PowerShell projects.

## Structure

```
project-name/
├── src/
│   ├── Public/           # Exported functions
│   ├── Private/          # Internal functions
│   └── ProjectName.psm1  # Module file
├── tests/
│   └── ProjectName.Tests.ps1
├── ProjectName.psd1      # Module manifest
├── .gitignore
└── README.md
```

## Quick Start

```powershell
# Clone and rename
Copy-Item -Recurse templates/powershell my-project
Set-Location my-project

# Import module for development
Import-Module ./src/ProjectName.psm1 -Force

# Run tests (requires Pester)
Invoke-Pester ./tests/
```

## Files Included

- `src/Public/` - Functions to export (available to users)
- `src/Private/` - Internal helper functions
- `src/ProjectName.psm1` - Main module file
- `tests/` - Pester test files
- `ProjectName.psd1` - Module manifest with metadata

## Installing Pester

```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```
