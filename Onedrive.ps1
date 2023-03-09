function Get-ODfBSyncLibrary {
    <#
    .SYNOPSIS
    Returns all synchronized libraries in OneDrive for Business under current logged-in user
    .PARAMETER Detailed
    Returns detailed information about each synchronized library
    .OUTPUTS
    TypeName: Selected.System.Management.Automation.PSCustomObject. Get-ODfBSyncLibrary returns a PSCustomObject
    .EXAMPLE
    Get-ODfBSyncLibrary
    .EXAMPLE
    Get-ODfBSyncLibrary -Detailed
    .LINK
    https://github.com/freddiecode/Get-ODfBSyncLibrary
    .AUTHOR
    Freddie Christiansen | www.cloudpilot.no
    #>
            [cmdletbinding()]
    
            param(
    
            [Parameter(Mandatory=$false)]
            [switch]
            $Detailed
    
            )
      
      try {
    
    
        $ODfBSync = Get-ChildItem -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SyncEngines\Providers\OneDrive
        $Items = $ODfBSync | Where-Object {$_.Name -notmatch "Personal"} | ForEach-Object { Get-ItemProperty $_.PsPath }  
    
        $AllODfBLibs = [System.Collections.ArrayList]@()
    
        ForEach ($Item in $Items) {
    
        $Obj = New-Object PSCustomObject
    
        $ODfBLib = [ordered]@{
    
                Url              = $Item.UrlNamespace
                MountPoint       = $Item.MountPoint
                LibraryType       = $Item.LibraryType
                LastModifiedTime = $(if ($Item.LastModifiedTime -as [DateTime]) { [datetime]::Parse($Item.LastModifiedTime) } else { $_ })
    
                }
    
                
                $Obj | Add-Member -MemberType NoteProperty -Name Url -Value $ODfBLib.Url
                $Obj | Add-Member -MemberType NoteProperty -Name MountPoint -Value $ODfBLib.MountPoint
                $Obj | Add-Member -MemberType NoteProperty -Name LibraryType -Value (Get-Culture).TextInfo.ToTitleCase($ODfBLib.LibraryType)
                $Obj | Add-Member -MemberType NoteProperty -Name LastModifiedTime -Value $ODfBLib.LastModifiedTime
    
                            
                $AllODfBLibs += $Obj
                   
            }
        }
    
        catch {
    
        Write-Host $_
    
        } 
    
    if(!$Detailed) { return $AllODfBLibs | Select-Object Url} else { return $AllODfBLibs | Sort-Object LibraryType }
    
    
}

$lib = Get-ODfBSyncLibrary -Detailed
$lib | Format-List

foreach ($type in $lib) {
    if ($type.LibraryType -eq "Teamsite") {Write-Output "dsdadsa"}
}

### GET Necessary ID
## tenantId=e3cf3c98-a978-465f-8254-9d541eeea73c&siteId={0af8c254-bc0f-442d-b82f-78efac18d189}&webId={59cf5f49-8787-44f1-a68d-d054f9e67d5f}&listId=190eaa12-8437-4e09-917b-efa23d23b80e&folderId=e3e77ed9-e06f-4096-9d90-4b0771f7cd06&webUrl=https://nttlimited.sharepoint.com/teams/am.brazil-public&version=1

$SiteURL = "https://nttlimited.sharepoint.com/teams/am.brazil-public"
Connect-PnPOnline -Url $SiteURL -UseWebLogin

# Site ID
$Site = Get-PnPSite -Includes ID
Write-host -f Green "Site ID:"$Site.Id 

# Web ID
$Web = Get-PnPWeb -Includes ID
Write-host -f Green "Web ID:"$Web.Id

# List ID
[string]$ListID = ($List | Where-Object {$_.Title -eq "Documents"}).Id

#### Sync ####

$WebURL = "https://nttlimited.sharepoint.com/teams/am.brazil-public"
$SiteName = "MySiteName Test"
$SiteID = "59cf5f49-8787-44f1-a68d-d054f9e67d5f"
$WebID = "{my Web GUID}"
$ListID = "{my List GUID}"

# Give Windows some time to load before getting the email address
Start-Sleep -s 20

$UserName = $env:USERNAME
$Domain = "@global.ntt"

# Use a "Do" loop to check to see if OneDrive process has started and continue to check until it does
Do{
    # Check to see if OneDrive is running
    $ODStatus = Get-Process onedrive -ErrorAction SilentlyContinue
    
    # If it is start the sync. If not, loopback and check again
    If ($ODStatus) 
    {
        # Give OneDrive some time to start and authenticate before syncing library
        Start-Sleep -s 30

        # set the path for odopen
        $odopen = "odopen://sync/?siteId=" + $SiteID + "&webId=" + $WebID + "&webUrl=" + $webURL + $SiteName + "&listId=" + $ListID + "&userEmail=" + $UserName + $Domain + "&webTitle=" + $SiteName + ""
        
        #Start the sync
        Start-Process $odopen
    }
}
Until ($ODStatus)