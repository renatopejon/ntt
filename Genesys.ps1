#Config Variables
$URL = "https://amlatstforms.blob.core.windows.net/guilhermeassuncao/GenesysWithITSM.zip"
$DestinationFolder ="C:\Windows\Temp"

function waitSetup {
    $running = 1
    while ($running -eq 1) {
        if ($Null -eq (get-process "setup" -ea SilentlyContinue)){
            $running = 0 
            Write-Host "OK" -ForegroundColor Green
        } 
    }    
}

 
Try {
     #Check if the Destination Folder exists. If not, create the folder for targetfile
    If(!(Test-Path -Path $DestinationFolder))
    {
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
        Write-host -f Yellow "Created a New Folder '$DestinationFolder'"
    }

    Write-Host "Downloading Genesys... " -NoNewline
    Invoke-WebRequest -Uri $URL -OutFile 'C:\Windows\Temp\GenesysWithITSM.zip'
    Write-Host "OK" -ForegroundColor Green
}
Catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

Expand-Archive -Force -Path "C:\Windows\Temp\GenesysWithITSM.zip" -DestinationPath "C:\Windows\Temp\GenesysWithITSM"

Set-Location "C:\Windows\Temp\GenesysWithITSM"

Write-Host "Installing Workspace... " -NoNewline
try {
    .\IP_IntWorkspace_8514705b1_ENU_windows\ip\setup.exe
    waitSetup
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}



Write-Host "Copying Files... " -NoNewline
try {
    Copy-Item ".\OC WDE\*" -Destination "C:\Program Files (x86)\GCTI\Workspace Desktop Edition"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "Installing SipEndpoint... " -NoNewline
try {
    .\IP_IntWSpaceSIPEp_8511540b1_ENU_windows\ip\setup.exe
    waitSetup
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "Backing up SipEndpoint.config... " -NoNewline
try {
    Rename-Item -Path "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint\SipEndpoint.config" -NewName "SipEndpoint.original.config"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "Copying new SipEndpoint.config... " -NoNewline
try {
    Copy-Item ".\SipEndpoint\*" -Destination "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Set-Location "C:\Windows\Temp"

Write-Host "Removing installation files... " -NoNewline
try {
    Remove-Item C:\Windows\Temp\GenesysWithITSM\ -Confirm:$false -Recurse -Force
    Remove-Item C:\Windows\Temp\GenesysWithITSM.zip -Confirm:$false -Recurse -Force
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "Checking number of itens on Workspace main folder"
$itens = ( Get-ChildItem "C:\Program Files (x86)\GCTI\Workspace Desktop Edition" | Measure-Object ).Count
Write-Host "$itens/120 itens."

Write-Host "Checking number of itens on SipEndpoint main folder"
$files = ( Get-ChildItem "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint" | Measure-Object ).Count
Write-Host "$files/25 files."