# Install AzureAD SharePoint Module
If(-not(Get-InstalledModule AzureAD -ErrorAction silentlycontinue)){
    Install-Module -Name AzureAD -Confirm:$False -Force
}

function Open-File([string] $initialDirectory){

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV files (*.csv)|*.csv"
    $OpenFileDialog.ShowDialog() |  Out-Null

    return $OpenFileDialog.filename
} 

Write-Host "Please, log in to your AzureAD account"

Import-Module AzureAD
#$connection = Connect-AzureAD
If(!$connection){$connection = Connect-AzureAD}

$test = Test-Connection -Server 10.214.10.20

if ($null -eq $test) {
    Write-Host "Can't connect to the local resources, exiting..."
    throw
}

$prompt = Read-Host "Type the user's email for check or just leave it blank to upload a CSV file"

$list = @()

if ($prompt -eq ''){
    Write-Host "Choose the CSV file to check the users"

    $open_file = Open-File $env:USERPROFILE
    if ($open_file -eq "") 
    {
        Write-Host "You didn't select a file" 
        throw
    } 

    $list = Import-Csv $open_file
} else {
    $list = New-Object -TypeName psobject -Property @{mail=$prompt}
}


foreach ($user in $list.mail) {
    $users_am = $false
    $default_am = $false
    $default_latam = $false

    $groups = Get-AzureADUserMembership -ObjectId $user | Select-Object Objectid

    Write-Host -ForegroundColor Yellow "User: $user"
    Write-Host ""
    Write-Host -ForegroundColor Cyan "Checking AzureAD groups:"

    ## Azure AD checks

    # Check EDM.Intune.Main-AutoPilot Users-AM
    Write-Host -NoNewline "     EDM.Intune.Main-AutoPilot Users-AM "
    foreach ($item in $groups.ObjectId) {
        if ($item -eq "ac22000b-5199-4152-b161-fab147cf5406") {
            $users_am = $true
        }
    }

    if ($users_am) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor Red "FAIL!"
    }

    # Check EDM.Intune.App-DefaultRequired-AM
    Write-Host -NoNewline "     EDM.Intune.App-DefaultRequired-AM "
    foreach ($item in $groups.ObjectId) {
        if ($item -eq "3d081ca5-bc34-49e2-a162-6624fa3b4f7d") {
            $default_am = $true
        }
    }

    if ($default_am) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor Red "FAIL!"
    }

    # Check EDM.Intune.App-DefaultRequired-AM-LATAM
    Write-Host -NoNewline "     EDM.Intune.App-DefaultRequired-AM-LATAM "
    foreach ($item in $groups.ObjectId) {
        if ($item -eq "d68f3e67-033d-4c47-9cb9-21a2199a32ff") {
            $default_latam = $true
        }
    }

    if ($default_latam) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor Red "FAIL!"
    }

    # Check EDM.CA-ON-BlockAccess-Members
    Write-Host -NoNewline "     EDM.CA-ON-BlockAccess-Members "
    foreach ($item in $groups.ObjectId) {
        if ($item -ne "b7039ba9-e48c-4b3b-b50a-fb21902eaae9") {
            $default_latam = $true
        }
    }

    if ($default_latam) {
        Write-Host -ForegroundColor green "OK"
        Write-Host ""
    } else {
        Write-Host -ForegroundColor Red "FAIL!"
        Write-Host ""
    }


    ## On-prem AD checks
    Write-Host -ForegroundColor Cyan "Checking on-prem AD attributes"

    $user = $user.Replace("@global.ntt", "")
    $aduser = Get-ADUser -Server 10.214.10.20 -Identity $user -Properties * | Select-Object identitylifecyclestate, lockoutime, msExchHideFromAddressLists, msNPAllowDialin, lockoutTime

    Write-Host -NoNewline "     identitylifecyclestate "
    if ($aduser.identitylifecyclestate -eq 'active') {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor red "FAIL!"
    }

    Write-Host -NoNewline "     lockoutTime "
    if ($aduser.lockoutTime -eq 0 -or $null -eq $aduser.lockoutTime) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor red "FAIL!"
    }

    Write-Host -NoNewline "     msExchHideFromAddressLists "
    if ($aduser.msExchHideFromAddressLists -eq $false) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor red "FAIL"
    }

    Write-Host -NoNewline "     msNPAllowDialin "
    if ($null -eq $aduser.msNPAllowDialin) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor red "FAIL"
    }

    Write-Host ""
    Write-Host "==============================="
    Write-Host ""
}