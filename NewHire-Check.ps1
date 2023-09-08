# Install AzureAD SharePoint Module
If(-not(Get-InstalledModule AzureAD -ErrorAction silentlycontinue)){
    Install-Module -Name AzureAD -Confirm:$False -Force
}

Import-Module AzureAD
Connect-AzureAD

function Open-File([string] $initialDirectory){

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV files (*.csv)|*.csv"
    $OpenFileDialog.ShowDialog() |  Out-Null

    return $OpenFileDialog.filename
} 

$open_file = Open-File $env:USERPROFILE
$list = Import-Csv $open_file

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
    Write-Host -NoNewline "EDM.Intune.Main-AutoPilot Users-AM "
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
    Write-Host -NoNewline "EDM.Intune.App-DefaultRequired-AM "
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
    Write-Host -NoNewline "EDM.Intune.App-DefaultRequired-AM-LATAM "
    foreach ($item in $groups.ObjectId) {
        if ($item -eq "d68f3e67-033d-4c47-9cb9-21a2199a32ff") {
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
    $aduser = Get-ADUser -Server "na.didata.local" -Identity $user -Properties * | Select-Object identitylifecyclestate, lockoutime, msExchHideFromAddressLists

    Write-Host -NoNewline "identitylifecyclestate "
    if ($aduser.identitylifecyclestate -eq 'active') {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor red "FAIL!"
    }

    Write-Host -NoNewline "msExchHideFromAddressLists "
    if ($aduser.msExchHideFromAddressLists -eq $false) {
        Write-Host -ForegroundColor green "OK"
    } else {
        Write-Host -ForegroundColor green "FAIL"
    }

    Write-Host ""
    Write-Host "==============================="
    Write-Host ""
}