$URL = "http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/amd64/MSERT.exe"
$EXEPath = "C:\msert.exe"
$JSON = 'https://raw.githubusercontent.com/sindresorhus/cli-spinners/main/spinners.json'
#$Creds = get-credential

# Loading animation function
(Invoke-WebRequest -Uri $JSON -UseBasicParsing).Content  | 
    Set-Content -Path c:\spinners.json -Encoding UTF8

function Write-TerminalProgress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet('aesthetic','arc','arrow','arrow2','arrow3','balloon','balloon2','betaWave','bluePulse','bounce','bouncingBall','bouncingBar','boxBounce','boxBounce2','christmas','circle','circleHalves','circleQuarters','clock','dots','dots10','dots11','dots12','dots2','dots3','dots4','dots5','dots6','dots7','dots8','dots8Bit','dots9','dqpb','earth','fingerDance','fistBump','flip','grenade','growHorizontal','growVertical','hamburger','hearts','layer','line','line2','material','mindblown','monkey','moon','noise','orangeBluePulse','orangePulse','pipe','point','pong','runner','shark','simpleDots','simpleDotsScrolling','smiley','soccerHeader','speaker','squareCorners','squish','star','star2','timeTravel','toggle','toggle10','toggle11','toggle12','toggle13','toggle2','toggle3','toggle4','toggle5','toggle6','toggle7','toggle8','toggle9','triangle','weather')]
        $IconSet
    )
    $path = "C:\spinners.json"
    $spinners = Get-Content $path | ConvertFrom-Json 
    $frameCount = $spinners.$IconSet.frames.count
    $frameInterval = $spinners.$IconSet.interval
    $e = "$([char]27)"
    1..30 | ForEach-Object -Begin {write-host "$($e)[s" -NoNewline} -Process { 
        $frame = $spinners.$IconSet.frames[$_ % $frameCount]
        Write-Host "$e[u$frame" -NoNewline
        Start-Sleep -Milliseconds $frameInterval
    }
}

# Install PowerShell SharePoint Module
If(-not(Get-InstalledModule PnP.PowerShell -ErrorAction silentlycontinue)){
    Install-Module PnP.PowerShell -Confirm:$False -Force
}

# Check if MSERT is running
if ($Null -eq (get-process "msert" -ea SilentlyContinue)){ 
}
else { 
    Write-Output "Looks like Msert might be running, please do a PS command and confirm."
    Write-Output "Ending script...."
    exit
}

# Check if there is an older version of MSERT to delete
if (Test-Path $EXEPath) {      
    try {
        Write-output "Attempting to delete $EXEPath"
        Remove-Item $EXEPath -Force -ErrorAction Stop
        Write-Output "Old MSERT deleted succesfuly"
    }
    catch {
        Write-Output "ERROR: Unable to delete $EXEPath, script terminating with error $($_.Exception.Message)"
        throw
    }
}
else {
    Write-output "EXE does not exist in $EXEPath - continuing"
}

# Download lastest 64bit version of MSERT
Write-output "Downloading the MSERT 64bit..."
Invoke-WebRequest -Uri $URL -outfile $EXEPath    

# Delete old msert.log if exists
if (Test-Path 'C:\Windows\Debug\msert.log') {
    try {
        Write-output "Attempting to delete old C:\Windows\Debug\msert.log"
        Remove-Item 'C:\Windows\Debug\msert.log' -Force -ErrorAction Stop
    }
    catch {
        Write-Output "ERROR: Unable to delete the msert.log file, scripting terminating with error $($_.Exception.Message)"
        throw
    }
}

# Start MSERT in quiet mode
Write-Output "Starting MSERT...."
Start-Process -FilePath "powershell.exe" -ArgumentList "-exec bypass -enc YwBtAGQALgBlAHgAZQAgAC0ALQAlACAALwBjACAAYwA6AFwATQBTAEUAUgBUAC4AZQB4AGUAIAAvAFEAIAAvAEYAOgBZAA=="
Start-Sleep -Seconds 5

# Set CPU priority to not use to much CPU
if ($Null -eq (get-process "msert" -ea SilentlyContinue)){ 
    Write-Output "MSERT does not appear to be runnning, do a PS comamnd to confirm and try re-runnning the script."
}
else { 
    Write-Output "Lets lower the CPU priority so we are not too abusive."
    Get-Process msert | ForEach-Object { 
        $_.PriorityClass='BelowNormal'
        $_.ProcessorAffinity = 7
    }

    Write-Output "Looks like msert is running, lets cat c:\windows\debug\msert.log to confirm."
    Write-Output "Giving MSERT 5 seconds to start before catting the file."
    Start-Sleep -Seconds 5
    Get-Content -Path "c:\windows\debug\msert.log" -Raw
}

# Wait MSERT finishes to send the log and upload it to SharePoint
$running = 1
while ($running -eq 1) {
    if ($Null -eq (get-process "msert" -ea SilentlyContinue)){
        $running = 0 
        
        $URLSP = "https://nttlimited.sharepoint.com/teams/AmericasISBrasil/"

        #Add-PnPStoredCredential -Name $URLSP -Username $Creds.UserName -Password $Creds.Password

        import-Module PnP.PowerShell 
        Connect-PnPOnline -Url $URLSP -UseWebLogin

        $ctx = Get-PnPContext
        $ctx.Load($ctx.Web.CurrentUser)
        $ctx.ExecuteQuery()
        $email = $ctx.Web.CurrentUser.Email
        $user = $email -replace '@.*$', ''

        Rename-Item -Path "C:\Windows\debug\msert.log" -NewName "$user-$env:COMPUTERNAME-msert.log"
        $Files = Get-ChildItem "C:\Windows\debug\$user-$env:COMPUTERNAME-msert.log"
        foreach($File in $Files){
            Add-PnPFile -Folder "Shared Documents/General/Logs" -Path $File.FullName
        }
    }
    else { 
        Clear-Host
        Write-Output "Scanning in progress, it may take a long time please wait"
        Write-TerminalProgress -IconSet simpleDots
    }   
}

Remove-Item C:\msert.exe -Confirm:$false -Recurse -Force
Remove-Item C:\spinners.json -Confirm:$false -Recurse -Force

exit 