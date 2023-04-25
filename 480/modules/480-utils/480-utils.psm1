function 480Banner()
{
    $banner=@"
Author: Adam
"@
    
    Write-Host $banner
}
function 480Connect([string] $server)
{
    $conn = $global:DefaultVIServer
    # Already connect?
    if ($conn){
        $msg = "Already Connect to: {0}" -f $conn

        Write-Host -ForegroundColor Green $msg
    }else {
        try {
            $conn = Connect-VIServer -Server $server
        }
        catch [Exception]{
            $exception = $_.Exception
            Write-Host -ForgroundColor Green $exception 
        }
        
    }
}
function Menu($config)
{
    Clear-Host
    480Banner
    Write-Host "
    Please select an option:
    [1] Exit
    [2] Linked Clone
    [3] Full Clone
    [4] Power on/off VM

    "
    $selection = Read-Host "Enter the option above"
    
    switch($selection){
        '1' {
            Clear-Host
            $conn = $global:DefaultVIServer
            # Already connect?
            if ($conn){
                Disconnect-VIServer -server * -Force -Confirm:$false
            }
            Exit
        }
        '2' {
            Clear-Host
            linkedClone($config)
        }
        '3' {
            Clear-Host
            FullClone($config)
        }
        '4' {
            Clear-Host
            powerVM($config)
        }
        Default {
            Write-Host -ForegroundColor "Red" "Please rerun you have selected outside the range" 
            break
        }
    }
}
function Get-480Config([string] $config_path)
{
    Write-Host 'Reading ' $config_path
    $conf = $null
    if ( Test-Path $config_path )
    {
        $conf = (Get-Content -Raw -path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    }else {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
}
# Select VM
function Select-VM([string] $folder)
{
    Write-Host "Selecting your VM" -ForegroundColor "Cyan"
    $selected_vm=$null
    try {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish?"
        try {
            $selected_vm = $vms[$pick_index -1]
            Write-Host "You chose " $selected_vm.Name
        }
        catch [Exception]{
            $msg = 'Invalid format please select number from provided range'
            Write-Host -ForgroundColor "Red" $msg
        }
        #note this is a full on vm object we can interract with
        return $selected_vm 
    }
    catch {
        Write-Host "Invalid folder: $folder" -ForegroundColor "Red"    
    }

}
# -------------------------- Milestone 5 -----------------
# Creates a Linked Clone
function linkedClone($config){
    Write-Host "Linked Cloner"


    $folder = $config.vm_folder
    $vm = Select-VM -folder $folder
    
    $linkedClone = Read-Host "Enter Name of New Linked Clone:"
    Write-Host "Creating Linked Clone"
    New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore

    Start-Sleep -Seconds 3
    Menu($config)
}
# Full Clone
function FullClone($config){
    Write-Host " Clone"

    $folder = $config.vm_folder
    $vm = Select-VM -folder $folder

    $newVMName = Read-Host "Please enter the Name of the new VM: "

    $iflinked = $false
    foreach ($realvm in Get-VM){
        if (“{0}.linked” -f $vm.name -eq $realvm.name){
            Write-Host "Link is already created"
            $iflinked = $true
            $linkedvmName = “{0}.linked” -f $vm.name
            $linkedvm = Get-VM -Name $linkedvmName
            break
        }else{
            $linkedClone = “{0}.linked” -f $vm.name 
            # To create new linked clone
            $linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $config.snapshot -VMHost $config.esxi_host -Datastore $config.default_datastore
            break
        }
    }
    # Creates a Full clone
    $newvm = New-VM -Name $newVMName -VM $linkedvm -VMHost $config.esxi_host -Datastore $config.default_datastore
    
    # makes snapshot of new vm
    Write-Host "Setting base snap shot"
    $newvm | New-Snapshot -Name $config.snapshot
    
    # Deletes the old linked clone when finished
    if (!$iflinked){
        $linkedvm | Remove-VM -DeletePermanently -Confirm:$false
    }
    
    Start-Sleep -Seconds 3
    Menu($config)
}

# Powers the chosen vm on or off
function powerVM($config){
    Write-Host "Selecting your VM" 
    $selected_vm=$null
    $vms = Get-VM
    $index = 1

    foreach($vm in $vms)
    {
        Write-Host [$index] $vm.Name
        $index+=1
    }
    $pick_index = Read-Host "Which index number [x] do you wish?"
    try {
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You chose " $selected_vm.Name
    }
    catch [Exception]{
        $msg = 'Invalid format please select number from provided range'
        Write-Host -ForgroundColor "Red" $msg
    }

    $Power = Read-Host "Would you like to turn that VM 'on' or 'off'?"

    if($Power -like 'on'){
        Start-VM -VM $selected_vm -Confirm:$true -RunAsync
    }elseif ($Power -like 'off') {
        Stop-VM -VM $selected_vm -Confirm:$true
    }
   
    Menu($config)
}
# -------------------------------------








