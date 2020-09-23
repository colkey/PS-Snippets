<#
    .SYNOPSIS
    Emulate pause of cmd.exe

    .EXAMPLE
    Pause
    続行するには何かエンターキーを押してください
    
    .EXAMPLE
    Pause -Prompt '待機してます...'
    待機してます...
#>
function Pause {
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $prompt = '続行するには何かエンターキーを押してください'
    )

    Write-Host -Object $prompt
    $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
}