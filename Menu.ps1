Write-Output "`n------------------------------------------"
Write-Output "|         I&T Utilities Script           |"
Write-Output "------------------------------------------`n"
Write-Output "1 - Install Genesys with ITSM integration"
Write-Output "2 - Do a MSERT Scan`n"
$num = Read-Host "Select a number"

switch ($num) {
    1 {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Genesys.ps1'))
    }
    2 {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script%20Public.ps1'))
    }
    
}