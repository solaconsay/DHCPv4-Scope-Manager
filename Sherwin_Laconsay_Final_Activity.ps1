# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

function Banner {
    Write-Host "===============================" -ForegroundColor Yellow
    Write-Host " DHCPv4 Server Management Tool " -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Yellow
}


# Define a function to display the menu
function Show-Menu {
    Write-Host "1. Install DHCP Server" 
    Write-Host "2. Authorize DHCP Server in AD"
    Write-Host "3. Configure IPv4 Scope"
    Write-Host "4. Import DHCP Server"
    Write-Host "5. Import IPv4 Scope"
    Write-Host "6. Get DHCP Bindings"
    Write-Host "7. Generate DHCPv4 Report"
    Write-Host "8. Exit"
}


function Install_DHCP {
    $dhcpInstalled = Get-WindowsFeature | Where-Object Name -eq "DHCP"
    if ($dhcpInstalled.InstallState -eq "Installed") {
        Write-Host "DHCP Server is already installed" -ForegroundColor Green
    }
    else {
        Install-WindowsFeature DHCP -IncludeManagementTools
    }
    Write-Host "`n" 
}

function Add_DHCP_AD {
    $dnsName = Read-Host "Please input DNS Name"
    $ipAddress = Read-Host "Please input IP Address"
    try {
        Add-DhcpServerInDC -IPAddress $ipAddress -DnsName $dnsName 
        Write-Host "'$dnsName' with IP address:'$ipAddress' was succesfully added" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add '$dnsName': $_" -ForegroundColor Red
    }
    Write-Host "`n"
}

function Config_IPv4_Scope {
    $scopeName = Read-Host "Please input Scope Name"
    $startIP = Read-Host "Please input start IP Address range"
    $endIP = Read-Host "Please input end IP Address range"
    $subnetMask = Read-Host "Please input subnet mask"
    try {
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $startIP -EndRange $endIP -SubnetMask $subnetMask
        Write-Host "'$scopeName' with IP rane:'$startIP - $endIP' was succesfully added" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to add '$scopeName ': $_" -ForegroundColor Red
    }
    Write-Host "`n"
}

function Import_DHCP_Server {

}


function Import_IPv4_Scope {


}

function Generate_DHCPv4_Report {

}

function Get_DHCP_Bindings {
    $dnsHostnames = @()
    # Get all computers from Active Directory and add their DNS hostnames to the list
    $computers = Get-ADComputer -Filter * -Properties DNSHostName | ForEach-Object {
        $dnsHostnames += $_.DNSHostName
    }
   
    foreach ($computers in $dnsHostnames) {
        Write-Host $computers
        try {
            Get-DhcpServerv4Binding -ComputerName $computers
        }
        catch {
            Write-Host "Error: $_`n" -ForegroundColor Red
        }
    } 
}


# Define a variable to keep track of whether to continue the loop
$continue = $true

# Loop until the user chooses to exit
while ($continue) {
    # Display the banner
    Banner

    # Display the menu and prompt the user for input
    Show-Menu
    $operation = Read-Host "Select an operation to perform (1-8):"

    # Validate the user's input
    try{ 
        $operation = [int]$operation
            if ($operation -lt 1 -or $operation -gt 8) {
                Write-Host "Invalid input. Please select a number between 1 and 8."
                continue
            }   
    } 
    catch {
        Write-Host "Operation is invalid. Please input numeric values."
    }  
      
    # Perform the selected operation
    switch ($operation) {
        1 {
            
            Write-Host "Performing operation 1..." -ForegroundColor Yellow
            # Install DHCP role function
            Install_DHCP
        }
        2 {
            # Code for operation 2
            Write-Host "Performing operation 2..." -ForegroundColor Yellow
            # Add DH
            Add_DHCP_AD
        }
        3 {
            # Code for operation 3
            Write-Host "Performing operation 3..." -ForegroundColor Yellow
            Config_IPv4_Scope
        }
        4 {
            # Code for operation 4
            Write-Host "Performing operation 4..." -ForegroundColor Yellow
        }
        5 {
            # Code for operation 5
            Write-Host "Performing operation 5..." -ForegroundColor Yellow
        }
        6 {
            # Code for operation 6
            Write-Host "Performing operation 6..." -ForegroundColor Yellow
            Get_DHCP_Bindings
        }
        7 {
            # Code for exiting the menu
            Write-Host "Performing operation 7..." -ForegroundColor Yellow
            
        }
        8 {
            # Code for exiting the menu
            Write-Host "Exiting the menu..." -ForegroundColor Yellow
            $continue = $false
        }
    }
}

# End of script



