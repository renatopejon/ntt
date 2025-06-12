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
Write-Output "|    LATAM I&T Utilities Script v5.2      |"
Write-Output "------------------------------------------`n"
Write-Output "1 - Clear data for CSIRT Tickets"
Write-Output "2 - AnyConnect update for MS-Service-Platforms`n"
$num = Read-Host "Select a number"

switch ($num) {
  1 {
    Clear-Host
    Write-Output "Starting Clear Files script..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Clear-Files.ps1'))
  } 

  2 {
      Clear-Host
      Write-Output "Starting AnyConnect update script..."
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/AnyConnect.ps1'))
  }       
}