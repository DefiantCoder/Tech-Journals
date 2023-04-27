# Array of websites containing the threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop throgh the URLs for the rules list
foreach ($u in $drop_urls) {
    # Extract the filename
    $temp = $u.split('/')
    
    # The last element in the array plucked off is the filename
    $file_name = $temp[-1]

    if (Test-Path $file_name) {

        continue
    
    } else {

        # Download the rules list
        Invoke-WebRequest -Uri $u -Outfile $file_name

    } # close if statement

} #close the foreach loop

# Array containing the filename
$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

# Extract the IP addresses
# 108.190.109.107
# 108.191.2.72
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list.
Select-String -path $input_paths -pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"
# Use a switch statement to create an IPTables and Windows firewall ruleset based on user choice
$choice = Read-Host "Do you want to create an IPTables or Windows Firewall ruleset? (IP/WIN)"
switch ($choice) {
    'IP' {
        # Get the IP addresses discovered, loop through and replace the beginning of the line with the IPTables syntax
        # After the IP address, add the remaining IPTables syntax and save the results to a file.
        # iptables -A INPUT -s 108.191.2.72 -j DROP
        (Get-Content -Path ".\ips-bad.tmp") | % `
        { $_ -replace '^', 'iptables -A INPUT -s ' -replace '$', ' -j DROP' } | `
        Out-File -FilePath ".\iptables.bash"
    }

    'WIN' {
        # Do the same for the Windows firewall syntax
        # netsh advfirewall firewall add rule name="BLOCK IP ADDRESS - 108.191.2.72" dir=in action=block remoteip=108.191.2.72"
        (Get-Content -Path ".\ips-bad.tmp") | % `
        { $_ -replace '^', 'netsh advfirewall firewall add rule name="BLOCK IP ADDRESS - ' -replace '$', '"' } | `
        Out-File -FilePath ".\winfw.netsh"
    }

} # close switch statement
