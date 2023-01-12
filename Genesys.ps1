#Config Variables
$SiteURL = "https://nttlimited.sharepoint.com/teams/am.brazil-public"
$FileServerRelativeURL = "Shared Documents/General/I&T/GenesysWithITSM.zip"
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

# Install PowerShell SharePoint Module
If(-not(Get-InstalledModule PnP.PowerShell -ErrorAction silentlycontinue)){
    Install-Module PnP.PowerShell -Confirm:$False -Force
}
 
Try {
     #Check if the Destination Folder exists. If not, create the folder for targetfile
     If(!(Test-Path -Path $DestinationFolder))
     {
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
        Write-host -f Yellow "Created a New Folder '$DestinationFolder'"
     }
     
    Write-Output "Downloading Genesys..."
    #Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -UseWebLogin
     
    #Check if File exists
    $File = Get-PnPFile -Url $FileServerRelativeURL -ErrorAction SilentlyContinue
    If($Null -ne $File)
    {
        #Download file from sharepoint online
        Get-PnPFile -Url $FileServerRelativeURL -Path $DestinationFolder -Filename $File.Name -AsFile -Force
        Write-host "File Downloaded Successfully!" -f Green
    }
    Else
    {
        Write-host "Could not Find File at "$FileServerRelativeURL -f Red
    }
}
Catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

Expand-Archive -Force -Path "C:\Windows\Temp\GenesysWithITSM.zip" -DestinationPath "C:\Windows\Temp\GenesysWithITSM"

Set-Location "C:\Windows\Temp\GenesysWithITSM"

Write-Output "Installing Workspace..."
try {
    .\IP_IntWorkspace_8514705b1_ENU_windows\ip\setup.exe
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

waitSetup

Write-Output "Copying Files..."
try {
    Copy-Item ".\OC WDE\*" -Destination "C:\Program Files (x86)\GCTI\Workspace Desktop Edition"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

Write-Output "Installing SipEndpoint..."
try {
    .\IP_IntWSpaceSIPEp_8511540b1_ENU_windows\ip\setup.exe
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

waitSetup

Write-Output "Backing up SipEndpoint.config..."
try {
    Rename-Item -Path "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint\SipEndpoint.config" -NewName "SipEndpoint.original.config"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

Write-Output "Copying new SipEndpoint.config"
try {
    Copy-Item ".\SipEndpoint\*" -Destination "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint"
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

Set-Location "C:\Windows\Temp"

Write-Output "Removing installation files"
try {
    Remove-Item C:\Windows\Temp\GenesysWithITSM\ -Confirm:$false -Recurse -Force
    Remove-Item C:\Windows\Temp\GenesysWithITSM.zip -Confirm:$false -Recurse -Force
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
}

Write-Output "Checking number of itens on Workspace main folder"
$itens = ( Get-ChildItem "C:\Program Files (x86)\GCTI\Workspace Desktop Edition" | Measure-Object ).Count
Write-Host "$itens/120 itens."

Write-Output "Checking number of itens on SipEndpoint main folder"
$files = ( Get-ChildItem "C:\Program Files (x86)\GCTI\Workspace Desktop Edition\InteractionWorkspaceSIPEndpoint" | Measure-Object ).Count
Write-Host "$files/25 files."