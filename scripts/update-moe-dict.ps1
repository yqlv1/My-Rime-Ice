[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DownloadedFile,
    [string]$RimeDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$target = Join-Path $repoDir 'cn_dicts\moe.dict.yaml'
$source = (Resolve-Path -LiteralPath $DownloadedFile).Path

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

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Downloaded dictionary does not exist: $DownloadedFile"
}
if ($source -eq [System.IO.Path]::GetFullPath($target)) {
    throw 'The downloaded file is already the repository dictionary.'
}

$header = Get-Content -LiteralPath $source -Encoding UTF8 -TotalCount 30
if (-not ($header -match '^name:\s*(moe|toneless_moe)\s*$')) {
    throw 'The selected file does not look like a Moe Rime dictionary (expected name: moe or name: toneless_moe).'
}

$sourceHash = Get-Sha256 -Path $source
if ($PSCmdlet.ShouldProcess($target, 'Overwrite dictionary content without replacing the file')) {
    $bytes = [System.IO.File]::ReadAllBytes($source)

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $stream = [System.IO.File]::Open(
            $target,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::Read
        )
        try {
            $stream.SetLength(0)
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
        }
        finally {
            $stream.Dispose()
        }
    }
    else {
        $targetDir = Split-Path $target -Parent
        if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        [System.IO.File]::WriteAllBytes($target, $bytes)
    }

    $targetHash = Get-Sha256 -Path $target
    if ($targetHash -ne $sourceHash) {
        throw 'Dictionary hash verification failed after writing.'
    }

    & (Join-Path $PSScriptRoot 'relink-rime.ps1') -RimeDir $RimeDir -Force
    Write-Host ""
    Write-Host "Updated: $target"
    Write-Host 'Run Rime deployment to compile and activate the new dictionary.'
}
