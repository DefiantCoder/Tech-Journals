# Storyline: Script that pulls processes, services, tcp network sockets, user account info, and network adapter configs and some other information for
# an Instant Reponse kit.

function irToolkit() {

    cls

    # Prompts user for location path to save exported files
    $filePath = Read-Host -Prompt "Please create a folder on your desktop and then enter file path to that folder. Example: C:\Users\Adam\Documents\Incident"

    # Outputs Processes and prints them out to csv
    Get-Process | Select-Object ProcessName, Path, ID | `
    Export-Csv -Path $filePath"\process.csv" -NoTypeInformation

    # Outputs the registered services
    Get-WmiObject win32_service | Select Name,StartMode, PathName | `
    Export-Csv -Path $filePath"\services.csv" -NoTypeInformation

    # Outputs all of the TCP network sockets
    Get-NetTCPConnection | `
    Export-Csv -Path $filePath"\tcpsocket.csv" -NoTypeInformation

    # Outputs all of the user account info
    Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | `
    Export-Csv -Path $filePath"\userinfo.csv" -NoTypeInformation

    # Outputs all of the NetworkAdapterConfig info
    Get-NetAdapter -Name * | `
    Export-Csv -Path $filePath"\netinfo.csv" -NoTypeInformation

    # Test-Connection a cmdlet that tests for network connectivity. pings google in this case
    # A good test to check for outbound connectivity
    Test-Connection 8.8.8.8 -Count 2 -Delay 2 | `
    Export-Csv -Path $filePath"\networkConnection.csv"

    # Get-Content is a cmdlet that allows you to check the contents of a file.
    # For this script I will have it print out the contents of a test file I  will make to show function.
    Get-Content -Path C:\Users\test\test\sample.txt.txt | `
    Export-Csv -Path $filePath"\contents.csv" -NoTypeInformation

    # Get-ExecutionPolicy  cmdlet that lets the user see the execution policy for scripts.
    # Can check to see if the execution policy is unsecure and might show weakpoints malicious code can exploit
    Get-ExecutionPolicy | `
    Export-Csv -Path $filepath"\executionPolicy.csv" -NoTypeInformation

    # Get-Process | Where-Object will search for a process when given a specfic process name. It will create a list instances of the process
    # This example uses powershell
    Get-Process | Where-Object {$_.Name –eq “pwsh”} | `
    Export-csv -Path $filePath"\runningProcess.csv" -NoTypeInformation

     # Creating FileHash for each file in folder
    Get-FileHash $filePath\*.csv | Export-Csv -Path $home\Desktop\zhash.csv -NoTypeInformation 

}

IRScript

Compress-Archive -Path $filePath -DestinationPath $filePath\IRScript.zip -Force
