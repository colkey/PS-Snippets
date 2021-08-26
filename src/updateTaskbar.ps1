Param(
    [Parameter(Mandatory=$false)]
    [Alias("tb")]
    [Switch]
    $Taskbar,

    [Parameter(Mandatory=$false)]
    [Alias("u")]
    [Switch]
    $Update
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "stop"

function Main() {
    if ($Taskbar) {
        Write-Host "Checking Taskbar..."
        CheckInTarget "${env:APPDATA}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    }

    Write-Host "Complete!" -ForegroundColor Green
}

function CheckInTarget() {
    param (
        [Parameter()]
        [String]
        $target
    )

    $links = Get-ChildItem -Path $target -Filter *.lnk |
                ForEach-Object { $_.FullName }

    foreach ($link in $links) {
        Task $link
    }
}

function Task() {
    param (
        [Parameter()]
        [String]
        $link
    )

    # ショートカットのリンク先を取得
    $stc = $WSH.createshortcut($link)
    [String]$stcTarget = $stc.targetpath
    if ($stcTarget -eq "") {
        return
    }

    # リンク先がscoopなら、各情報を取得
    $stcMatch = $reScoopAppVersionPath.Match($stcTarget)
    if (!$stcMatch.Success) {
        Write-Host " * Ignored: $(Split-Path -Leaf $link)"
        return
    }
    $appName = $stcMatch.Groups["appName"].Value
    $stcVersion = $stcMatch.Groups["version"].Value
    $stcRestPath = $stcMatch.Groups["restPath"].Value

    # currentへのリンクなら更新不要
    if ($stcVersion -eq "current") {
        Write-Host " * Skipped: ${appname}"
        return
    }

    # current(シンボリックリンク)のリンク先を取得
    $currentPath = "${appsDir}\${appname}\current"
    $currentTarget = (Get-Item $currentPath).Target

    # currentのバージョンを取得
    $currentMatch = $reScoopAppVersion.Match($currentTarget)
    $currentVersion = $currentMatch.Groups["version"].Value

    # ショートカットのリンク先がcurrentと同一か確認する
    if ($stcVersion -eq $currentVersion) {
        Write-Host " * Latest: ${appname}" -ForegroundColor Cyan
        return
    }
    Write-Host " * Outdated: ${appname} ${stcVersion} -> ${currentVersion}" -ForegroundColor Yellow

    # ショートカットのリンク先を更新する
    if ($Update) {
        $stc.TargetPath = "${currentTarget}\${stcRestPath}"
        $stc.WorkingDirectory = Split-Path -Parent $stc.TargetPath
        $stc.save()
        
        Write-Host " * Updated: ${appname}" -ForegroundColor Cyan
    } else {
        Write-Host " if you want to update, option -u(padate)."
    }
}

# ==================================
# rf: scoop\current\lib\core.ps1

function get_config($name, $default) {
    if($null -eq $scoopConfig.$name -and $null -ne $default) {
        return $default
    }
    return $scoopConfig.$name
}

function load_cfg($file) {
    if(!(Test-Path $file)) {
        return $null
    }

    try {
        return (Get-Content $file -Raw | ConvertFrom-Json -ErrorAction Stop)
    } catch {
        Write-Host "ERROR loading $file`: $($_.exception.message)"
    }
}

function appdir($app) { "${scoopdir}\apps\${app}" }

# ==================================
$ErrorActionPreference = "silentlycontinue"

# rf: scoop\current\lib\core.ps1 (no global)
$configHome = $env:XDG_CONFIG_HOME, "$env:USERPROFILE\.config" | Select-Object -First 1
$configFile = "$configHome\scoop\config.json"
$scoopConfig = load_cfg $configFile
$scoopDir = $env:SCOOP, (get_config 'rootPath'), "$env:USERPROFILE\scoop" | Where-Object { -not [String]::IsNullOrEmpty($_) } | Select-Object -First 1
$appsDir = "$scoopDir\apps"

$ErrorActionPreference = "stop"
# ==================================

$WSH = New-Object -ComObject wscript.shell

$reScoopAppVersion = [regex]("$([regex]::escape($appsDir))\\(?<appName>.+?)\\(?<version>.+)")
$reScoopAppVersionPath = [regex]("$([regex]::escape($appsDir))\\(?<appName>.+?)\\(?<version>.+?)\\(?<restPath>.+)")

Main