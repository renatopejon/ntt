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
Write-Output "|         I&T Utilities Script           |"
Write-Output "------------------------------------------`n"
Write-Output "1 - Install Genesys with ITSM integration"
Write-Output "2 - MSERT Scan `n"
$num = Read-Host "Select a number"

switch ($num) {
  1 {
      Write-Output "Starting Genesys script..."
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/Genesys.ps1'))
  }

  2 {
      Write-Output "Starting MSERT script..."
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/renatopejon/ntt/main/MSERT%20Script%20Public.ps1'))
  }      
}