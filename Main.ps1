# Set-ExecutionPolicy RemoteSigned -Scope Process
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Get-ChildItem -Path 'src' -Filter '*.ps1' -File | 
    ForEach-Object { . (Resolve-Path $_.FullName -Relative) }
function Main {
    New-TypeAccelerator -Alias 'process' -Type ([System.Diagnostics.Process])
    
    # [process].FullName # System.Diagnostics.Process
    Get-Help Pause
}

Main