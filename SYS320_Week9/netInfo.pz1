# Task: Grab the network adapter information using the WMI class
# Get the IP address, Default geteway, and the DNS servers.
# BONUS: Get the DHCP server.


Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE | Format-List IPAddress, DefaultIPGateway,DHCPServer, DNSServerSearchOrder
