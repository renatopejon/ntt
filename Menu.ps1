Clear-Host
Write-Host "                                                                                                                                                                                   
        :-===-::-===-:                                                             
     =#@@@@@@@@@@@@@@@@%=.                                                         
   =@@@@#+*@@@@@@@@*+#@@@@+                                                        
 .%@@@+. -@@@*. +@@@=  =@@@%.                                                      
 %@@@:   @@@#    +@@@.  .%@@%      -@@@@#. %@@@@@==@@@@@@@@@@@*:@@@@@@@@@@@@       
+@@@-   :@@@+    -@@@-   :@@@*     .=%@@@%.=*@@@=:=@@++@@@#=@@#-@@#=@@@%=%@@       
#@@@     #@@@+::=@@@%     #@@@       %@@@@%.-@@@  -##::@@@+ ##+:##= @@@# *##       
%@@%      +@@@@@@@@*.     #@@@       %@@#@@%+@@@      :@@@+         @@@#           
*@@@.       :=++=-        @@@#       %@@+:@@@@@@      :@@@+         @@@#           
.@@@#                    *@@@:     .:%@@*:.%@@@@     :=@@@*:.     ::@@@#:.         
 -@@@%.                .#@@@=      -@@@@@@ .%@@@    :@@@@@@@+     @@@@@@@#         
  :%@@@*:            .+@@@@-        ......   ...     .......      ........         
    =%@@@%*=-:..:-=*%@@@@+                                                         
      :*%@@@@@@@@@@@@@*-                                                           
         .:=++**++=:.                                                                                                                                             
                                                                                         
"
Write-Output "`------------------------------------------"
Write-Output "|    LATAM I&T Utilities Script v4.0      |"
Write-Output "------------------------------------------`n"
Write-Output "1 - Install Genesys with ITSM integration"
Write-Output "2 - MSERT Scan"
Write-Output "3 - Clear data for CSIRT Tickets`n"
$num = Read-Host "Select a number"

switch ($num) {
  1 {
      Clear-Host
      Write-Output "Starting Genesys script..."
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Genesys.ps1'))
  }

  2 {
      Clear-Host
      Write-Output "Starting MSERT script..."
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script%20Public.ps1'))
  }     
  
  3 {
    Clear-Host
    Write-Output "Starting Clear Files script..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Clear-Files.ps1'))
} 
}