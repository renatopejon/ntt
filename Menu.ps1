Write-Host "@@@@@@@@++++++++++++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@++..++....++..++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@##..##++++++++##..++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@..##@@..@@@@..@@##..@@@@@@++##@@++++##++++++++##++++++++##@@
@@##++@@##..@@@@++##@@++##@@@@    ##    ..        ..        ..@@
@@++++@@##..@@@@..##@@++++@@@@++  ++++..##............++  ++..@@
@@++++@@@@++....++@@@@##++@@@@++    ....@@@@..  @@@@@@++  @@@@@@
@@++++@@@@@@++++@@@@@@++++@@@@++  ..  ..@@@@..  @@@@@@++  @@@@@@
@@##++@@@@@@@@@@@@@@@@..##@@@@..  ##  ..@@@@    @@@@@@..  @@@@@@
@@@@..##@@@@@@@@@@@@##..@@@@@@    ##....@@++    ++@@##    ..@@@@
@@@@##..##@@@@@@@@##..##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@++..++####++..++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@##++....++##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`n"
Write-Output "`n------------------------------------------"
Write-Output "|         I&T Utilities Script           |"
Write-Output "------------------------------------------`n"
Write-Output "1 - Install Genesys with ITSM integration"
Write-Output "2 - Do a MSERT Scan"
Write-Output "3 - Do a MSERT Scan (BETA)`n"
$num = Read-Host "Select a number"

switch ($num) {
    1 {
        Write-Output "Starting Genesys script..."
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Genesys.ps1'))
    }

    2 {
        Write-Output "Starting MSERT script..."
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script.ps1'))
    }

    3 {
        Write-Output "Starting MSERT script..."
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script%20Public.ps1'))
    }
    
    
}