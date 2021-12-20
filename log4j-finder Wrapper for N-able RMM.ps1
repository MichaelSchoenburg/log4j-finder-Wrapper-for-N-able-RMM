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
$PathRmm = [System.IO.FileInfo]"$( $env:ProgramFiles )\Advanced Monitoring Agent\scripts\$( $FolderRmm )"

if (-not (Test-Path $PathRmm.DirectoryName)) {
    New-Item -ItemType Directory -Name $FolderRmm -Path $PathRmm
}

$PathExe = [System.IO.FileInfo]"$( $env:ProgramFiles )\Advanced Monitoring Agent\scripts\Fox-IT_Log4J-Finder_Script\log4j-finder.exe"

$AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
$Client = New-Object System.Net.WebClient
$Client.DownloadFile($DownloadUrl, $PathExe)

$drives = Get-PSDrive -PSProvider FileSystem

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $PathExe
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
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
    Write-Host "log4j-finder: Achtung: betroffene log4j Versionen gefunden! Bitte Log-Dateien pruefen!"
    exit 1001
} else {
    Write-Host "log4j-finder: keine Funde"
    exit 0
}