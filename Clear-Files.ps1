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

Write-Host "Clearing Windows temp files and DNS cache"
try {
    ipconfig /flushdns
    Clear-GlobalWindowsCache
}
catch {
    Write-Error $_.Exception.Message
}

Write-Host "Reseting all browsers cookies and cache"
try {
    Clear-UserCacheFiles
    Write-Host " OK" -NoNewline -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    Write-Host " ERROR" -NoNewline -ForegroundColor Red
}