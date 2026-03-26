<#
    Cleanup-windows-installer.ps1
    
    http://www.bryanvine.com/2015/06/powershell-script-cleaning-up.html
    
    Bryan Vine
    6/22/2015
    www.bryanvine.com
    
    This script uses Heath Stewart's VB script to identify which files need to be saved and then removes everything else.
    Can be run locally or pushed to remove servers with PSRemoting or PSexec.  
    It does take a bit to run, but can save you 3-5gb on average.
    
    Requires to be ran as administrator.
#>


#Heath Stewart's VB script from 
#   http://blogs.msdn.com/b/heaths/archive/2007/01/31/how-to-safely-delete-orphaned-patches.aspx 

$VBSFile = @"
'' Identify which patches are registered on the system, and to which
'' products those patches are installed.
''
'' Copyright (C) Microsoft Corporation. All rights reserved.
''
'' THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
'' KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
'' IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
'' PARTICULAR PURPOSE.
'Option Explicit
Dim msi : Set msi = CreateObject("WindowsInstaller.Installer")
'Output CSV header
WScript.Echo "The data format is ProductCode, PatchCode, PatchLocation"
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("output.txt", True)
objFile.WriteLine "ProductCode, PatchCode, PatchLocation"
objFile.WriteLine ""
' Enumerate all products
Dim products : Set products = msi.Products
Dim productCode
For Each productCode in products
	' For each product, enumerate its applied patches
	Dim patches : Set patches = msi.Patches(productCode)
	Dim patchCode
	For Each patchCode in patches
		' Get the local patch location
		Dim location : location = msi.PatchInfo(patchCode, "LocalPackage")
        objFile.WriteLine productCode & ", " & patchCode & ", " & location
		
	Next
Next
WScript.Echo "Data written to output.txt, these are the registered objects and SHOULD be kept!"
"@

$VBSFile | Set-Content .\WiMsps.vbs

cscript .\WiMsps.vbs 

$savelist = Import-Csv .\output.txt

$filelocation = $savelist | Select-Object -ExpandProperty PatchLocation

#First pass to remove exact file names
Get-ChildItem C:\windows\Installer -file | ForEach-Object{
    $fullname = $_.FullName
    if($filelocation | Where-Object{$_ -like "*$fullname*"}){
        "Keeping $fullname"
    }
    else{
        Remove-Item $fullname -Force -Verbose
    }


}

#second pass to match product and patch codes
Get-ChildItem C:\windows\Installer -Directory | ForEach-Object{
    $fullname = $_.name
    if($savelist | Where-Object{$_.ProductCode -like "*$fullname*" -or $_.PatchCode -like "*$fullname*" }){
        "Keeping $fullname"
    }
    else{
        Remove-Item $_.fullname -Force -Verbose -Recurse
    }

}
