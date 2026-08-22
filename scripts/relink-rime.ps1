[CmdletBinding()]
param(
    [string]$RimeDir,
    [switch]$CheckOnly,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$manifestPath = Join-Path $repoDir 'rime-links.txt'

if ([string]::IsNullOrWhiteSpace($RimeDir)) {
    $RimeDir = Join-Path (Split-Path $repoDir -Parent) 'Rime'
}

if (-not (Test-Path -LiteralPath $RimeDir -PathType Container)) {
    throw "Rime directory does not exist: $RimeDir"
}
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Link manifest does not exist: $manifestPath"
}

$rimeRoot = (Resolve-Path -LiteralPath $RimeDir).Path
if ([System.IO.Path]::GetPathRoot($repoDir) -ne [System.IO.Path]::GetPathRoot($rimeRoot)) {
    throw 'The repository and Rime directory must be on the same volume for NTFS hard links.'
}

function Resolve-ChildPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Manifest path must be relative: $RelativePath"
    }

    $nativeRelativePath = $RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $nativeRelativePath))
    $rootPrefix = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Manifest path escapes its root: $RelativePath"
    }
    return $fullPath
}

function Get-FileId {
    param([Parameter(Mandatory = $true)][string]$Path)

    $output = & fsutil.exe file queryfileid $Path 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to query file ID: $Path`n$($output -join [Environment]::NewLine)"
    }

    $match = [regex]::Match(($output -join ' '), '0x[0-9A-Fa-f]+')
    if (-not $match.Success) {
        throw "Unable to parse file ID: $Path"
    }
    return $match.Value.ToLowerInvariant()
}

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-', '')
    }
    finally {
        $stream.Dispose()
        $algorithm.Dispose()
    }
}

$entries = Get-Content -LiteralPath $manifestPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

$linked = 0
$repaired = 0
$problems = New-Object System.Collections.Generic.List[string]

foreach ($entry in $entries) {
    $source = Resolve-ChildPath -Root $repoDir -RelativePath $entry
    $target = Resolve-ChildPath -Root $rimeRoot -RelativePath $entry

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        $problems.Add("Missing source: $entry")
        continue
    }

    if (Test-Path -LiteralPath $target) {
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            $problems.Add("Target is not a file: $entry")
            continue
        }

        if ((Get-FileId -Path $source) -eq (Get-FileId -Path $target)) {
            Write-Host "OK       $entry"
            $linked++
            continue
        }

        if ($CheckOnly) {
            $problems.Add("Not linked: $entry")
            continue
        }

        $sameContent = (Get-Sha256 -Path $source) -eq (Get-Sha256 -Path $target)
        if (-not $sameContent -and -not $Force) {
            $problems.Add("Different target content (rerun with -Force to replace it): $entry")
            continue
        }

        Remove-Item -LiteralPath $target -Force
    }
    elseif ($CheckOnly) {
        $problems.Add("Missing target: $entry")
        continue
    }

    $targetDir = Split-Path $target -Parent
    if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $linkOutput = & fsutil.exe hardlink create $target $source 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to create hard link: $entry`n$($linkOutput -join [Environment]::NewLine)"
    }
    if ((Get-FileId -Path $source) -ne (Get-FileId -Path $target)) {
        throw "Hard-link verification failed: $entry"
    }

    Write-Host "REPAIRED $entry"
    $repaired++
}

Write-Host ""
Write-Host "Linked: $linked; repaired: $repaired; problems: $($problems.Count)"

if ($problems.Count -gt 0) {
    foreach ($problem in $problems) {
        Write-Error $problem
    }
    throw 'Rime hard-link check failed.'
}
