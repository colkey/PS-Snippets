<#
    .SYNOPSIS
    Creates new type accelerator(s)

    .NOTES
    https://devblogs.microsoft.com/scripting/use-powershell-to-find-powershell-type-accelerators/

    .EXAMPLE
    New-TypeAccelerator -Alias 'process' -Type ([System.Diagnostics.Process])
    [process].FullName # System.Diagnostics.Process
#>
function New-TypeAccelerator {
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $alias,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [type]
        $type
    )

    process {
        [pscustomobject].
        Assembly.
        GetType('System.Management.Automation.TypeAccelerators')::
        Add($alias, $type)
    }
}