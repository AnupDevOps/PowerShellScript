#################################################################################  
##  
## Server Health Check  
## Created by Anup Kumar Mishra(anup.mishra)   
## Date : 4 September 2019  
##   
##     
## This scripts check the Disconnected user on server and forcefully log off them.   
## This scripts need to run on Admin mode of PowerShell. 
################################################################################  


#quser | Select-String "Disc" |
#ForEach
#{logoff ($_.tostring() -split ' +')[2]}

$server = "localhost";
 
# Get all RDP sessions
$sessions = query user /server:$server | select -skip 1;
 
# Loop through each session/line returned
foreach ($line in $sessions) { 
 
    $line = -split $line;
 
    # Check for missing SessionName field/column
    if ($line.length -eq 8) {

        # Get current session state (column 4)
        $state = $line[3];

        # Get Session ID (column 3) and current idle time (column 5)
        $sessionid = $line[2]; 
        $idletime = $line[4];

    } else {

        # Get current session state (column 3)
        $state = $line[2];

        # Get Session ID (column 2) and current idle time (column 4)
        $sessionid = $line[1]; 
        $idletime = $line[3];
    }
   
    # If the session state is Disconnected 
    if ($state -eq "Disc") { 
 
        # Check if idle for more than 1 day (has a '+') and log off 
        if ($idletime -like "*+*") {
 
            logoff $sessionid /server:$server /v
 
        # Check if idle for more than 1 hour (has a ':') and log off 
        } elseif ($idletime -like "*:*") {
 
            logoff $sessionid /server:$server /v
 
        } 
    }
}