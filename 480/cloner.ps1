# Adam L SEC-480 cloner.ps1 will create a linked clone of a vm, make an independent vm and then do cleanup
# Run the Following commands to find your inputs before running the code, Record your Snapshot name but using "Base" as a standard makes things simplier 
# Get-VM
# Get-VMHost
# Get-Datastore

### Records your inputs from the above commands

# Records the Name of the VM
$vmName = Read-Host -Prompt "Enter Your VM Name: "
# Records the Host IP
$hostIP = Read-Host "Enter VM Host IP: "
# Records the datastore
$dsName = Read-Host "Input Name of Datastore : "
# Records the desired snapshot to use for linked clone
$snapshotName = Read-Host "Enter Snapshot Name: "


##### Creates your VM




# Gets Your VM
$vm = Get-VM -Name $vmName
# Gets Your vmHost
$vmhost = Get-VMHost -Name $hostIP
# Gets Your Datastore
$ds = Get-Datastore -Name $dsName
# Gets Snapshot Name
$snapshot = Get-Snapshot -VM $vm -Name $snapshotName

# New VM name
$newVMName = Read-Host "Enter the Name of the new VM: "
# {0} Becomes Your VM Name
$linkedClone = “{0}.linked” -f $vm.name 
# To create new linked clone
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
# Creates full Independent VM Using Linked Clone
$newvm = New-VM -Name $newVMName -VM $linkedvm -VMHost $vmhost -Datastore $ds
# Creates a Snapshot of the New VM
$newvm | New-Snapshot -Name "Base"
# Removes the Old Linked Clone
$linkedvm | Remove-VM -DeletePermanently -Force




