$PWD = Get-Location
$DIR = "$PWD\ungoogled-chromium"

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

function check-update($cur){
    $Response = Invoke-WebRequest -URI https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/windows/64bit/
    $str = $Response.Links.Href|Select-Object -Index 4
    $ver = $str.Substring(52,$str.length-52-2)
    if ($cur -eq 0){
        Write-Output "Downloading latest version : $ver"
        download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }
    elseif ($cur -ne $ver){
        Remove-Item -LiteralPath $DIR -Force -Recurse
        Write-Output "Downloading $ver, Current version is $cur"
        download "$ver-1"
        $child = Get-ChildItem -Path $DIR -Name
        set-shortcut "$DIR\$child\chrome.exe"
    }else{
        Write-Output "No new versions present"
    }
}

function check-install{
    if (Test-Path -Path $DIR){
        $child = Get-ChildItem -Path $DIR | Measure-Object
        if (($child.count -eq 0) -or ($child.count -gt 1)){
            Write-Output "ungoogled-chromium is not installed"
            check-update 0
        }else{
            Write-Output "ungoogled-chromium is installed"
            $child = Get-ChildItem -Path $DIR -Name
            $cur = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$DIR\$child\chrome.exe").ProductVersion
            Write-Output "Current version : $cur"
            check-update $cur
        }
    }else{
        Write-Output "ungoogled-chromium is not installed"
        check-update 0
    }
}

check-install