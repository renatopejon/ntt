Write-Output "Hello World!"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/renatopejon/ntt/main/teste.ps1" -outfile "C:\Windows\Temp\teste.ps1"

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/teste.ps1'))
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Genesys.ps1'))


Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script%20Public.ps1'))