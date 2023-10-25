$URL = "https://www.microsoft.com/security/encyclopedia/adlpackages.aspx?package=scanner&arch=x64"
$EXEPath = "C:\msert.exe"
$JSON = 'https://raw.githubusercontent.com/sindresorhus/cli-spinners/main/spinners.json'
$global:scriptLog = $null

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

# Log function
function CreatelogFile{
    Param($content)
   
    $hostname = $env:computername
    $timeNow = Get-date -UFormat "%m-%d-%Y - %H:%M:%S"
    $global:scriptLog += "$timeNow || $content\n"

$body = @"
{
    `"hostname`": `"$hostname`",
    `"content`": `"$global:scriptLog`"
}
"@

    Invoke-WebRequest 'https://prod-214.westeurope.logic.azure.com:443/workflows/f7b4e154acda4ef399245583a632f661/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=yS0X1g6SNi27ruBOc9b4z2oI30ukMelDJXQ7nP1BQT0' `
    -Method 'POST' `
    -ContentType 'application/json; charset=utf-8' `
    -Body $body
}

# HTTP request to PowerAutomate function
function sendToFlow{

$content = Get-Content "C:\Windows\debug\msert.log"
$hostname = $env:computername

foreach ($line in $content) {
    $logContent += "$line\n"
}

$body = @"
{
    `"hostname`": `"$hostname`",
    `"logContent`": `"$logContent`"
}
"@

Invoke-WebRequest 'https://prod-238.westeurope.logic.azure.com:443/workflows/ef9a4ee201ba4e4daf6e12f3b809391a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Ddv4TQWfU_cnkjzcD40NUI5ZA6QsItPNKKhGHR25Vc8' `
-Method 'POST' `
-ContentType 'application/json; charset=utf-8' `
-Body $body
}

# Clean Cache, Cookies and Temp files, script by mark05e: https://gist.github.com/mark05e/745afaf5604487b804ede2cdc38a977f

#------------------------------------------------------------------#
#- Clear-GlobalWindowsCache                                        #
#------------------------------------------------------------------#
Function Clear-GlobalWindowsCache {
    Remove-CacheFiles 'C:\Windows\Temp' 
}

#------------------------------------------------------------------#
#- Clear-UserCacheFiles                                            #
#------------------------------------------------------------------#
Function Clear-UserCacheFiles {
    # Stop-BrowserSessions
    ForEach($localUser in (Get-ChildItem 'C:\users').Name)
    {
        Clear-ChromeCache $localUser
        Clear-EdgeCache $localUser
        Clear-FirefoxCacheFiles $localUser
    }
}

#------------------------------------------------------------------#
#- Remove-CacheFiles                                               #
#------------------------------------------------------------------#
Function Remove-CacheFiles {
    param([Parameter(Mandatory=$true)][string]$path)    
    BEGIN 
    {
        $originalVerbosePreference = $VerbosePreference
        $VerbosePreference = 'Continue'  
    }
    PROCESS 
    {
        if((Test-Path $path))
        {
            if([System.IO.Directory]::Exists($path))
            {
                try 
                {
                    if($path[-1] -eq '\')
                    {
                        [int]$pathSubString = $path.ToCharArray().Count - 1
                        $sanitizedPath = $path.SubString(0, $pathSubString)
                        Remove-Item -Path "$sanitizedPath\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    else 
                    {
                        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue              
                    } 
                } catch { }
            }
            else 
            {
                try 
                {
                    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                } catch { }
            }
        }    
    }
    END 
    {
        $VerbosePreference = $originalVerbosePreference
    }
}

#------------------------------------------------------------------#
#- Clear-ChromeCache                                               #
#------------------------------------------------------------------#
Function Clear-ChromeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Google\Chrome\User Data\Default"))
    {
        $chromeAppData = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default" 
        $possibleCachePaths = @('Cache','Cache2\entries\','Cookies','History','Top Sites','VisitedLinks','Web Data','Media Cache','Cookies-Journal','ChromeDWriteFontCache')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$chromeAppData\$cachePath"
        }      
    } 
}

#------------------------------------------------------------------#
#- Clear-EdgeCache                                                 #
#------------------------------------------------------------------#
Function Clear-EdgeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"))
    {
        $EdgeAppData = "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"
        $possibleCachePaths = @('Cache','Cache2\entries','Cookies','History','Top Sites','Visited Links','Web Data','Media History','Cookies-Journal')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$EdgeAppData$cachePath"
        }
        }
}


#------------------------------------------------------------------#
#- Clear-FirefoxCacheFiles                                         #
#------------------------------------------------------------------#
Function Clear-FirefoxCacheFiles {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $firefoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName 
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$firefoxAppDataPath\$cachePath"
        }
    } 
}

#------------------------------------------------------------------#
#- Clear-WaterfoxCacheFiles                                        #
#------------------------------------------------------------------#
Function Clear-WaterfoxCacheFiles { 
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Waterfox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $waterfoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Waterfox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$waterfoxAppDataPath\$cachePath"
        }
    }   
}

Write-Host "Clearing Windows temp files and DNS cache"
try {
    ipconfig /flushdns
    Clear-GlobalWindowsCache
    CreatelogFile -content "INFO: Windows temp files and DNS cache cleared."
}
catch {
    CreatelogFile -content "ERROR: Unable to clear Windows temp files and DNS cache: $($_.Exception.Message)"
}

Write-Host "Reseting all browsers cookies and cache"
try {
    Clear-UserCacheFiles
    CreatelogFile -content "INFO: Browsers cookies and cache cleared."
}
catch {
    CreatelogFile -content "ERROR: Unable to clear browsers cookies and cache: $($_.Exception.Message)"
}

# Check if MSERT is running
if ($Null -eq (get-process "msert" -ea SilentlyContinue)){ 
}
else { 
    Write-Output "Looks like Msert might be running, please kill msert.exe task."
}

# Check if there is an older version of MSERT to delete
if (Test-Path $EXEPath) {      
    try {
        Write-output "Attempting to delete $EXEPath"
        Remove-Item $EXEPath -Force -ErrorAction Stop
        Write-Output "Old MSERT deleted succesfuly"
        CreatelogFile -content "INFO: Old MSERT deleted succesfuly."
    }
    catch {
        Write-Output "ERROR: Unable to delete $EXEPath, script terminating with error $($_.Exception.Message)"
        CreatelogFile -content "ERROR: Unable to delete $EXEPath, script terminating with error: $($_.Exception.Message)"
        throw
    }
}
else {
    Write-output "EXE does not exist in $EXEPath - continuing"
}

# Download lastest 64bit version of MSERT
Write-output "Downloading the MSERT 64bit..."
try {
    Invoke-WebRequest -Uri $URL -outfile $EXEPath  
}
catch {
    CreatelogFile -content "ERROR: MSERT didn't download, scripting terminating with error: $($_.Exception.Message)"
    throw
}

# Delete old msert.log if exists
if (Test-Path 'C:\Windows\Debug\msert.log') {
    try {
        Write-output "Attempting to delete old C:\Windows\Debug\msert.log"
        Remove-Item 'C:\Windows\Debug\msert.log' -Force -ErrorAction Stop
        CreatelogFile -content "INFO: Old msert.log deleted."
    }
    catch {
        Write-Output "ERROR: Unable to delete the msert.log file, scripting terminating with error $($_.Exception.Message)"
        CreatelogFile -content "ERROR: Unable to delete the msert.log file, scripting terminating with error: $($_.Exception.Message)"
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
    CreatelogFile -content "INFO: MSERT Scan has started."
}

# Wait MSERT finishes to send the log
$running = 1
while ($running -eq 1) {
    if ($Null -eq (get-process "msert" -ea SilentlyContinue)){
        $running = 0 
        CreatelogFile -content "INFO: MSERT Scan finished."

        try {
            sendToFlow
            CreatelogFile -content "INFO: MSERT log sent to the Logs folder."
        }
        catch {
            CreatelogFile -content "ERROR: Unable to send MSERT log to Sharepoint. Error: $($_.Exception.Message)"
        }
    }
    else { 
        Clear-Host
        Write-Output "Scanning in progress, it may take a long time please wait"
        Write-TerminalProgress -IconSet simpleDots
    }   
}

# Clean files after scan finishes
try {
    Remove-Item C:\msert.exe -Confirm:$false -Recurse -Force
    Remove-Item C:\spinners.json -Confirm:$false -Recurse -Force
    CreatelogFile -content "INFO: Script files deleted and finished the script."
}
catch {
    CreatelogFile -content "ERROR: Unable to delete the script files. Error: $($_.Exception.Message)"
}

exit