<#
.SYNOPSIS
    Update (or download) ungoogled-chromium without hassle
.DESCRIPTION
    This script allows you to update (or download) ungoogled-chromium on your Windows systems. This downloads binaries from official GitHub source and no modification is done at the supply chain.

    To give extra peace of mind, I developed this script in a Windows system where Administrator privilege is disabled, so this script doesn't ask the same; in addition that ungoogled-chromium is installed as normal user.
.PARAMETER silent
  Specifies if script will ignore user confirmation. If provided it will not nag you for confirming each step.

.INPUTS
  None. You cannot pipe objects to update-chromium.ps1.

.OUTPUTS
  None. update-chromium.ps1 does not generate any tangible output.
.EXAMPLE
    .\update-chromium.ps1 -silent
    Runs the Script silently without asking user confirmation
.LINK
    GitHub : https://github.com/1bl4z3r/boredhub/blob/master/update-chromium.ps1
    Blog : https://1bl4z3r.cyou/posts/update-ungoogled-chromium/

    Ungoogled-Chromium : https://github.com/ungoogled-software/ungoogled-chromium
.NOTES
    Author: 1BL4Z3R
    Date:   March 30, 2023 
#>

param ([switch] $silent)

$PWD = Get-Location
$DIR = "$PWD\ungoogled-chromium"

function user-confirm{
    if($silent){
        return
    }else{
        Write-Host -NoNewLine "Press any key to continue..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
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
	$chromium = Get-Process chrome -ErrorAction SilentlyContinue
	if ($chromium) {
		Write-Output "Chromium is running. It will be closed"
        user-confirm
		$chromium.CloseMainWindow()
		Sleep 5
		if (!$chromium.HasExited) {
			$chromium | Stop-Process -Force
		}
		Remove-Variable chromium
	}else{
		Write-Output "Chromium is not running. We are good to go"
	}
}

function check-update($cur){
    $Response = Invoke-WebRequest -URI https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/windows/64bit/
    $str = $Response.Links.Href|Select-Object -Index 4
    $ver = $str.Substring(52,$str.length-52-2)
    if ($cur -eq 0){
        Write-Output "Downloading latest version of ungoogled-chromium. Version: $ver"
        #download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }
    elseif ($cur -ne $ver){
		check-if-running
        Remove-Item -LiteralPath $DIR -Force -Recurse
        Write-Output "Current version is $cur, which is outdated, hence downloading Latest Version: $ver"
        user-confirm
        #download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }else{
        Write-Output "No new versions present, you are good to go"
    }
}

function check-install{
    if (Test-Path -Path $DIR){
        $child = Get-ChildItem -Path $DIR | Measure-Object
        if (($child.count -eq 0) -or ($child.count -gt 1)){
            Write-Output "We found that ungoogled-chromium is not installed"
            user-confirm
            check-update 0
        }else{
            Write-Output "We found that ungoogled-chromium is installed"
            $child = Get-ChildItem -Path $DIR -Name
            $cur = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$DIR\$child\chrome.exe").ProductVersion
            Write-Output "Current version of ungoogled-chromium is $cur"
            check-update $cur
        }
    }else{
        Write-Output "We found that ungoogled-chromium is not installed"
        user-confirm
        check-update 0
    }
}

check-install
