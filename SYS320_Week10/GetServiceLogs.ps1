# Storyline: View the event logs, check for valid log, and print the results
# Partial credit to Chat GPT for code

function get_services() { 

    cls

    # grab running services & create an array
    $runningServices = Get-Service | Where { $_.Status -eq "running" }
    $arrRunning = @()

    # Array for running services
    foreach ($tempRunning in $runningServices) {
        $arrRunning += $tempRunning
    }




    # grab stopped services & create an array
    $stoppedServices = Get-Service | Where { $_.Status -eq "stopped" }
    $arrStopped = @()

    # Array for stopped services
    foreach ($tempStopped in $stoppedServices) {
        $arrStopped += $tempStopped
 
    }

    # Prompt for the user choose which prossess to view:
    $readServices = Read-Host -Prompt "Do you want view all, running, or stopped services? Or 'q' to quit."

    # Checks if the user wants to quit:
    if ($readServices -match "^[qQ]$") {
        break
    
    # ouputs the running services
    } elseif ($readServices -match "^running$") {
        write-host -BackgroundColor Green -ForegroundColor white "Please wait. It might take a few moments to retrieve running services."
        sleep 2

    $arrRunning | Out-Host

    Read-Host -Prompt "Press enter when done."
    get_services

    # ouputs the stopped services
    } elseif ($readServices -match "^stopped$") {
        write-host -BackgroundColor Green -ForegroundColor white "Please wait. It might take a few moments to retrieve stopped services."
        sleep 2
    
    $arrStopped | Out-Host

    Read-Host -Prompt "Press enter when done."
    get_services

    # ouputs all services
    } elseif ($readServices -match "^all$") {
        write-Host -BackgroundColor Green -ForegroundColor White "Please wait. It might take a few moments to retrieve all services."
        sleep 2

        $arrRunning | Out-Host
        $arrStopped | Out-Host

      Read-Host -Prompt "Press enter when done."
      get_services

    } else {

    Write-Host -BackgroundColor Red -ForegroundColor White " Invalid option. Try again."
    sleep 2

    get_services

    }
} # End of get_services()


get_services
