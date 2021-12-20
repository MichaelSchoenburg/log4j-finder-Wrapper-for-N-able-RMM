<#
    .SYNOPSIS
        log4j-finder Wrapper for N-able RMM

    .DESCRIPTION
        A wrapper for log4j-finder from fox-it to work with N-able RMM.

    .INPUTS
        None.

    .OUTPUTS
        Gives stdout and stderr from log4j-finder and exists with proper exit codes for N-able RMM.

    .NOTES
        Author: Michael Schönburg
        Script version: 1.0
        Script version date: 12/20/2021
        Using log4j-finder from fox-it.

    .LINK
        https://github.com/fox-it/log4j-finder

#>

$DownloadUrl = "https://github.com/fox-it/log4j-finder/releases/latest/download/log4j-finder.exe"
$FolderRmm = "Fox-IT_Log4J-Finder_Script"
$PathRmm = [System.IO.FileInfo]"C:\TSD.CenterVision\Software\_Scripts\$( $FolderRmm )"
if (-not (Test-Path $PathRmm.FullPath)) {
    New-Item -ItemType Directory -Path $PathRmm
}
$PathExe = "$( $PathRmm )\log4j-finder.exe"
if (-not (Test-Path $PathExe)) {
    $AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    $Client = New-Object System.Net.WebClient
    $Client.DownloadFile($DownloadUrl, $PathExe)
}

$Drives = (Get-PSDrive -PSProvider FileSystem).where({$_.DisplayRoot -notlike "\\*"})

$Arguments = ""
foreach ($drive in $Drives) {
    $Arguments = "$( $Arguments ) $( $drive ):\ "
}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $PathExe
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = $Arguments
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host "stdout start ---------------------------------"
Write-Host $stdout
Write-Host "stdout end -----------------------------------"
Write-Host "stderr start ---------------------------------"
Write-Host $stderr
Write-Host "stderr end -----------------------------------"
Write-Host
Write-Host "exit code: $( $p.ExitCode )"

if ($stdout.Contains("vulnerable") -or $stderr.Contains("vulnerable")) {
    Write-Host "Result: vulnerabilities have been found!"
    exit 1001
} else {
    Write-Host "Result: no vulnerabilities found."
    exit 0
}
