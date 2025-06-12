# Config Variables
$URL = "https://amlatstforms.blob.core.windows.net/guilhermeassuncao/AnyConnect.zip"
$DestinationFolder ="C:\Temp"

try {
    $msiexec = Get-Process msiexec -ErrorAction SilentlyContinue

    if ($null -ne $msiexec) {
        Write-Host -NoNewline "A msiexec process was found! Trying to stop it... "
        Stop-Process -Name "msiexec" -Force
        Write-Host -ForegroundColor Green "OK"
    }
}
catch {
    Write-Host -ForegroundColor Red "ERROR"
}

# Download the zip file
Try {

   If(!(Test-Path -Path $DestinationFolder))
   {
        Write-Host -NoNewline "Creating the temp files folder... "
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
        Write-host -ForegroundColor Green "OK"
   }

   Write-Host -NoNewline "Downloading files... "
   Invoke-WebRequest -Uri $URL -OutFile 'C:\Temp\AnyConnect.zip'
   Write-host -ForegroundColor Green "OK"
}
Catch {
    Write-Host -ForegroundColor Red "ERROR"
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}

# Extracting and installing AnyConnect
try {
    Expand-Archive -Force -Path "C:\Temp\AnyConnect.zip" -DestinationPath "C:\Temp\AnyConnect"
    Set-Location "C:\Temp\AnyConnect"

    Write-Host "Installing AnyConnect... " -NoNewline
    Start-Process msiexec.exe -ArgumentList '/i "C:\Temp\AnyConnect\anyconnect-win-4.10.08029-core-vpn-predeploy-k9.msi" /quiet /norestart' -Wait
    Write-host -ForegroundColor Green "OK"

}
catch {
    Write-Host -ForegroundColor Red "ERROR"
    Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
}

# Copy profile file and remove temp files
Write-Host "Adding MS-Service-Platform profile... " -NoNewline
try {
    Remove-Item "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\DDBR.xml" -Confirm:$false -Recurse -Force
    Remove-Item "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\NTTA-Sao-Paulo.xml" -Confirm:$false -Recurse -Force
    Remove-Item "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\NTTA-Texas.xml" -Confirm:$false -Recurse -Force
    Copy-Item ".\*.xml" -Destination "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile"
    Write-Host "OK" -ForegroundColor Green
    
    Write-Host -NoNewline "Removing temp files... "
    Remove-Item "C:\Temp\*" -Confirm:$false -Recurse -Force
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host -ForegroundColor Red "ERROR"
    Write-Host "Error: $($_.Exception.Message)"
}