<#
.SYNOPSIS
    Authenticode-sign the TrackOlap Connector MSI and executable on Windows.

.DESCRIPTION
    build-msi.sh signs inline when signing material is configured. This script is the
    Windows-native equivalent for the two cases the shell script cannot cover well:

      * signing with a certificate held in the Windows certificate store or on a hardware
        token / HSM (an EV code-signing certificate is ALWAYS on a token - its private key
        cannot be exported to a .pfx, so -Thumbprint is the only way to use it), and
      * signing artefacts after the fact, on a release box, without rebuilding.

    It is guarded: with no signing material it prints a loud warning and exits 0, so an
    unsigned local build still completes. It never silently pretends to have signed.

.PARAMETER Path
    Files to sign. Accepts wildcards. Defaults to dist\*.msi.

.PARAMETER Thumbprint
    SHA1 thumbprint of a certificate in the current user's or machine's store. Use this for
    EV certificates and Azure Trusted Signing.

.PARAMETER PfxPath
    Path to a .pfx file (OV certificates only - an EV key cannot be exported).

.PARAMETER PfxPassword
    Password for the .pfx. Prefer piping it in from a secret store over typing it.

.PARAMETER TimestampUrl
    RFC3161 timestamp server. Timestamping is not optional for a release: without it every
    signature stops validating the day the certificate expires, including on machines that
    installed the software years earlier.

.EXAMPLE
    .\sign.ps1 -Thumbprint A1B2C3... -Path ..\..\dist\*.msi

.EXAMPLE
    $env:SIGN_PFX_PASSWORD | .\sign.ps1 -PfxPath C:\secrets\trackolap.pfx
#>
[CmdletBinding()]
param(
    [string[]] $Path = @("$PSScriptRoot\..\..\dist\*.msi"),
    [string]   $Thumbprint   = $env:SIGN_SHA1,
    [string]   $PfxPath      = $env:SIGN_PFX,
    [string]   $PfxPassword  = $env:SIGN_PFX_PASSWORD,
    [string]   $TimestampUrl = $(if ($env:SIGN_TIMESTAMP_URL) { $env:SIGN_TIMESTAMP_URL } else { 'http://timestamp.digicert.com' }),
    [string]   $SignTool     = $env:SIGNTOOL
)

$ErrorActionPreference = 'Stop'

function Find-SignTool {
    if ($SignTool -and (Test-Path $SignTool)) { return $SignTool }
    $cmd = Get-Command signtool.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    # Newest Windows SDK wins; x64 build tools first.
    $roots = @("${env:ProgramFiles(x86)}\Windows Kits\10\bin", "${env:ProgramFiles}\Windows Kits\10\bin")
    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { continue }
        $found = Get-ChildItem -Path $root -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
                 Where-Object { $_.FullName -match '\\x64\\' } |
                 Sort-Object FullName -Descending |
                 Select-Object -First 1
        if ($found) { return $found.FullName }
    }
    return $null
}

$targets = @()
foreach ($p in $Path) { $targets += Get-ChildItem -Path $p -ErrorAction SilentlyContinue }
if ($targets.Count -eq 0) {
    Write-Error "sign.ps1: nothing to sign matched: $($Path -join ', ')"
    exit 1
}

if (-not $Thumbprint -and -not $PfxPath) {
    Write-Warning @"

  ############################################################################
  #  NOT SIGNED - no certificate was supplied.
  #
  #  $($targets.Count) artefact(s) were left unsigned:
  #    $($targets.Name -join "`n#    ")
  #
  #  Unsigned installers hit the SmartScreen "unrecognised app" wall on every
  #  customer machine. Fine for a local build; never ship this.
  #
  #  Supply one of:
  #    -Thumbprint <sha1>   certificate in the Windows store / on an EV token
  #    -PfxPath <file>      OV certificate exported to a .pfx
  #  See build/README.md.
  ############################################################################
"@
    exit 0
}

$signtoolPath = Find-SignTool
if (-not $signtoolPath) {
    Write-Error "sign.ps1: signtool.exe not found. Install the Windows SDK 'Signing Tools' component, or set `$env:SIGNTOOL."
    exit 1
}
Write-Host "==> signtool: $signtoolPath"

$common = @('sign', '/fd', 'SHA256', '/td', 'SHA256', '/tr', $TimestampUrl, '/v')
if ($Thumbprint) {
    $common += @('/sha1', $Thumbprint)
} else {
    if (-not (Test-Path $PfxPath)) { Write-Error "sign.ps1: $PfxPath not found"; exit 1 }
    $common += @('/f', $PfxPath)
    if ($PfxPassword) { $common += @('/p', $PfxPassword) }
}

foreach ($t in $targets) {
    Write-Host "==> signing $($t.FullName)"
    & $signtoolPath @common $t.FullName
    if ($LASTEXITCODE -ne 0) { Write-Error "sign.ps1: signing failed for $($t.Name)"; exit $LASTEXITCODE }

    # Verify what we just produced. /pa uses the Authenticode policy, which is what
    # Windows itself applies when the user double-clicks the installer - a signature that
    # only passes the default policy can still be rejected in the field.
    & $signtoolPath verify /pa /v $t.FullName
    if ($LASTEXITCODE -ne 0) { Write-Error "sign.ps1: signature verification failed for $($t.Name)"; exit $LASTEXITCODE }
}

Write-Host "==> signed and verified $($targets.Count) artefact(s)"
