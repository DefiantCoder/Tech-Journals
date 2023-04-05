# Task: Write a program that can start and stop the Windows Calculator only using Powershell and using only the process name for the Windows Calculator (to start and stop it).
# Start the calculator (Process name cannot be used until the process is running.)
Start-Process calc.exe
# Wait 5 seconds
Start-Sleep -Seconds 4
# Stop the calculator using the process name
Stop-Process -Name CalculatorApp
