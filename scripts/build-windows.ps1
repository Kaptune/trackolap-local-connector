param(
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version = '1.0.0'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'dist'
$spec = Join-Path $root 'build/windows/tlp-connector.wxs'
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($target in @(@{Msi='x64';Go='amd64'}, @{Msi='x86';Go='386'}, @{Msi='arm64';Go='arm64'})) {
    $binary = Join-Path $out "tlp-connector_windows_$($target.Go).exe"
    if (!(Test-Path $binary)) { throw "Missing binary: $binary" }
    $msi = Join-Path $out "tlp-connector-$Version-$($target.Msi).msi"
    & wix build -arch $target.Msi -ext WixToolset.Util.wixext -ext WixToolset.UI.wixext `
        -d "ProductVersion=$Version" -d "BinarySource=$binary" `
        -d "IconFile=$root/build/windows/tlp-connector.ico" `
        -d "LicenseFile=$root/build/windows/license.rtf" -o $msi $spec
    if ($LASTEXITCODE -ne 0) { throw "WiX failed for $($target.Msi)" }
    if (!(Test-Path $msi)) { throw "WiX did not produce $msi" }
    # Inspect the MSI database without installing the service on the runner.
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $installer.OpenDatabase($msi, 0)
    $view = $database.OpenView("SELECT ``Value`` FROM ``Property`` WHERE ``Property``='ProductVersion'")
    $view.Execute()
    $record = $view.Fetch()
    if ($record.StringData(1) -ne $Version) { throw "Incorrect MSI ProductVersion: $msi" }
    $template = $database.SummaryInformation(0).Property(7)
    $expected = @{x64='x64';x86='Intel';arm64='Arm64'}[$target.Msi]
    if (!$template.StartsWith("$expected;", [StringComparison]::OrdinalIgnoreCase)) {
        throw "Incorrect MSI architecture: $template"
    }
    Write-Host "Verified $msi ($template), version $Version; unsigned."
}
