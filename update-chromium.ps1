<#
.SYNOPSIS
    Update (or download) ungoogled-chromium without hassle
.DESCRIPTION
    This script allows you to update (or download) ungoogled-chromium on your Windows systems. This downloads binaries from official GitHub source and no modification is done at the supply chain.

    To give extra peace of mind, I developed this script in a Windows system where Administrator privilege is disabled, so this script doesn't ask the same; in addition that ungoogled-chromium is installed as normal user.

    Additional Links:
    GitHub : https://github.com/1bl4z3r/boredhub/blob/master/update-chromium.ps1
    Blog : https://1bl4z3r.cyou/posts/update-ungoogled-chromium-v2/

    Ungoogled-Chromium : https://github.com/ungoogled-software/ungoogled-chromium
.PARAMETER silent
  Specifies if script will ignore user confirmation. If provided it will not nag you for confirming each step.

.INPUTS
  None. You cannot pipe objects to update-chromium.ps1.

.OUTPUTS
  None. update-chromium.ps1 does not generate any tangible output.
.EXAMPLE
    .\update-chromium.ps1 -silent
    Runs the Script silently without asking user confirmation
.EXAMPLE
    .\update-chromium.ps1 -help
    Display this Help message
.EXAMPLE
    help .\update-chromium.ps1 -online
    Check out Online help
.LINK
    https://1bl4z3r.cyou/posts/update-ungoogled-chromium-v2/
.NOTES
    Author: 1BL4Z3R
    Date:   March 30, 2023 
#>

param ([switch] $silent, [switch] $help)

$PWD = Get-Location
$DIR = "$PWD\ungoogled-chromium"

if($help){Get-Help -Name $PWD\update-chromium.ps1 -full;exit}

function user-confirm($WarningMessage){
    if($silent){
        return
    }else{
        Write-Warning "$WarningMessage ?" -WarningAction Inquire
    }
}

function set-shortcut($SourceFilePath){
    $ShortcutPath = "$env:USERPROFILE\Desktop\Chromium.lnk"
    if (Test-Path -Path $ShortcutPath -PathType Leaf){
        Remove-Item $ShortcutPath
    }
    $WScriptObj = New-Object -ComObject ("WScript.Shell")
    $shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath = $SourceFilePath
    $shortcut.Save()
}

function download($ver){
    Start-BitsTransfer "https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/download/$ver.1/ungoogled-chromium_$ver.1_windows_x64.zip"
    Expand-Archive "ungoogled-chromium_$ver.1_windows_x64.zip" -DestinationPath $DIR
    Remove-Item -LiteralPath "ungoogled-chromium_$ver.1_windows_x64.zip"
}

function check-if-running{
    if (Get-Process -Name Chrome -ErrorAction SilentlyContinue) {
        user-confirm "We found that Chromium is running. It will be closed. Saved whatever you are doing"
        do {
            $running = try{Get-Process -Name Chrome -ErrorAction Stop} catch {Write-Host "Chromium closed sucessfully" -ForegroundColor 'green'}
            $running | ForEach-Object {$_.CloseMainWindow()|Out-Null}
        }
        until ($running -eq $null)
    }else{
        Write-Host "Chromium is not running. We are good to go" -ForegroundColor 'green'
    }
}

function check-update($cur){
    $Response = Invoke-WebRequest -URI https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/windows/64bit/
    $str = $Response.Links.Href|Select-Object -Index 4
    $ver = $str.Substring(52,$str.length-52-2)
    if ($cur -eq 0){
        Write-Host "Downloading latest version of ungoogled-chromium. Version: $ver" -ForegroundColor 'Magenta'
        download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }
    elseif ($cur -ne $ver){
        check-if-running
        Remove-Item -LiteralPath $DIR -Force -Recurse
        Write-Host "Current version is $cur, which is outdated, hence downloading Latest Version: $ver" -ForegroundColor 'red'
        user-confirm "Do you wish to Update ungoogled-chromium to latest version"
        download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }else{
        Write-Host "No new versions present, you are good to go" -ForegroundColor 'green'
    }
}

function check-install{
    if (Test-Path -Path $DIR){
        $child = Get-ChildItem -Path $DIR | Measure-Object
        if (($child.count -eq 0) -or ($child.count -gt 1)){
            Write-Host "We found that ungoogled-chromium is not installed" -ForegroundColor 'red'
            user-confirm "Do you wish to Install ungoogled-chromium"
            check-update 0
        }else{
            Write-Host "We found that ungoogled-chromium is installed" -ForegroundColor 'cyan'
            $child = Get-ChildItem -Path $DIR -Name
            $cur = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$DIR\$child\chrome.exe").ProductVersion
            Write-Host "Current version of ungoogled-chromium is $cur" -ForegroundColor 'Magenta'
            check-update $cur
        }
    }else{
        Write-Host "We found that ungoogled-chromium is not installed" -ForegroundColor 'red'
        user-confirm "Do you wish to Install ungoogled-chromium"
        check-update 0
    }
}

check-install
