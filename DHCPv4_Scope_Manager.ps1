# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# Define the name of the tool
function Banner {
    Write-Host "================ DHCPv4 Scope Manager ==================" -ForegroundColor Yellow
    Write-Host " Please generate the report first for your reference :) " -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Yellow
}

# Define a function to display the menu
function Show-Menu {
    Write-Host "1. Add new DHCPv4 Scope" 
    Write-Host "2. Exclude IP addresses from a scope"
    Write-Host "3. Set Option Value (Scope or Server level)"
    Write-Host "4. Import DHCPv4 Scope"
    Write-Host "5. Generate DHCPv4 Scope Report"
    Write-Host "6. Exit"
}

# This function adds the DHCPv4 Scope
function Add_IPv4_Scope {
    # Get the inputs from the user
    $compName = Read-Host "Please input computer name of the DHCP server"
    $scopeName = Read-Host "Please input a new Scope Name"
    $startIP = Read-Host "Please input start IP Address range"
    $endIP = Read-Host "Please input end IP Address range"
    $subnetMask = Read-Host "Please input subnet mask"
    
    
    # Add the DHCPv4 scope to the specified DHCP server
    try {
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $startIP -EndRange $endIP -SubnetMask $subnetMask -ComputerName $compName
        Write-Host "'$scopeName' with IP range:'$startIP - $endIP' was succesfully added to $compName." -ForegroundColor Green      
    }
    catch {
        Write-Host "Failed to add '$scopeName': $_"  -ForegroundColor Red
    }
}

# This will exclude IP ranges from a target DHCPv4 Scope ID
function Exclude_IPv4_range {
    # Get the inputs from the user
    $compName = Read-Host "Please input computer name of the DHCP server"
    $scopeID = Read-Host "Please input scope ID."
    $ex_startIP = Read-Host "Please input start IP address to exclude"
    $ex_endIP = Read-Host "Please input end IP address to exclude"

    # Add the DHCPv4 excluded addresses to the specified DHCP server and Scope ID
    try {
        Add-DhcpServerv4ExclusionRange -ScopeID $scopeID -StartRange $ex_startIP -EndRange $ex_endIP -ComputerName $compName
        Write-Host "IP address range $ex_startIP - $ex_endIP were excluded for scope ID $scopeID from $compName." -ForegroundColor Green   
    }
    catch {
        Write-Host "Failed to exclude IP range: $_" -ForegroundColor Red
    }        

}
# This will set the option at Scope ID level or Server level
function Set_Option {
    # Get the inputs from the user
    $compName = Read-Host "Please input computer name of the DHCP server"
    $optionID = Read-Host "Please input the option ID"
    $optionValue = Read-Host "Please input the value for this option"
    $scopeID = Read-Host "Please input scope ID. (If you leave it blank, it will apply this at the Server level)"

    # Set the Option ID and values to specified DHCP server
    try {
        # Set the Option ID and values to specified Scope ID in the specified DHCP server
        if (-not [string]::IsNullOrWhiteSpace($scopeID)) {
            Set-DhcpServerv4OptionValue -ScopeId $scopeID -OptionId $optionID -Value $optionValue -ComputerName $compName
            Write-Host "Option ID $optionID with the value of $optionValue was set for scope ID $scopeID on $compName." -ForegroundColor Green
        } 
        # Set the Option ID and values at SERVER LEVEL
        else {
            Set-DhcpServerv4OptionValue -OptionId $optionID -Value $optionValue -ComputerName $compName
            Write-Host "Option ID $optionID with the value of $optionValue was set globally on $compName." -ForegroundColor Green
        }   
    } catch {
        if (-not [string]::IsNullOrWhiteSpace($scopeID)) {
            Write-Host "Failed to set option for scope ID '$scopeID': $_" -ForegroundColor Red
        } else {
            Write-Host "Failed to set option globally on '$compName': $_" -ForegroundColor Red
        }
    }
}

# This will import IPv4 Scopes, Excluded addresses and options from a csv file
function Import_IPv4_Scope {
    # Prompt the user for the path to the CSV file
    $csvPath = Read-Host "Enter the path to the CSV file"

    # Import the csv file and store the header names to variables
    Import-Csv $csvPath | ForEach-Object {
        try {
            $compName = $_.ComputerName
            $scopeName = $_.ScopeName
            $startIP = $_.StartIP
            $endIP = $_.EndIP
            $subnetMask = $_.SubnetMask
            $excluded_StartIP = $_.Excluded_StartIP
            $excluded_EndIP = $_.Excluded_EndIP
            $option_ID = $_.Option_ID
            $value = $_.Value

            # Add DHCP Scope if all required fields are complete, otherwise skip
            if ($scopeName -and $startIP -and $endIP -and $subnetMask -and $compName) {
                Add-DhcpServerv4Scope -Name $scopeName -StartRange $startIP -EndRange $endIP -SubnetMask $subnetMask -ComputerName $compName 
                $scopeID = (Get-DhcpServerv4Scope -ComputerName $compName | Where-Object Name -eq $scopeName).ScopeId
                Write-Host "'$scopeName' with IP range:'$startIP - $endIP' was succesfully added to $compName." -ForegroundColor Green    

                # Add Exclusion Range if all required fields are complete
                if ($scopeID -and $excluded_StartIP -and $excluded_EndIP -and $compName) {
                    Add-DhcpServerv4ExclusionRange -ScopeID $scopeID -StartRange $excluded_StartIP -EndRange $excluded_EndIP -ComputerName $compName
                }

                # Set DHCP Option Value if all required fields are complete
                if ($scopeID -and $option_ID -and $value -and $compName) {
                    Set-DhcpServerv4OptionValue -ScopeID $scopeID -OptionID $option_ID -Value $value -ComputerName $compName
                }
            }
            else {
                Write-Host "Failed to add '$scopeName'. One or more required fields are empty'. Skipping..." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Failed to add '$scopeName': $_" -ForegroundColor Red
        }
    }
}

# This will generate an HTML report for DHCPv4 Scopes, Excluded Addresses and Options (Server level and Scope ID level)
function Generate_DHCPv4_Report {
    # Get the DHCP server name from the user
    $compName = Read-Host "Please input computer name of the DHCP server"

    # report name
    $reportName = "DHCPv4 Scope Report-$compName.htm"

    # this is the html table styling that will be applied on the report html file    
    $htmlParams = @{
        Head = "<style>
            table {
                border-collapse: collapse;
                
            }
            th, td {
                border: 1px solid #dddddd;
                text-align: left;
                padding: 8px;
            }
            th {
                background-color: #f2f2f2;
            }
        </style>" 
    }
    # Get the date
    $date = Get-Date
    try {
        # Generate the report
        "<h2>DHCP IPv4 Scope Report</h2>" | Out-File $reportName
        "<h4>Report generated at $date</h4>" | Out-File $reportName -Append
        "<h3>List of DHCPv4 Scopes for $compName</h3>" | Out-File $reportName -Append
        
        # Get the list of scopes and append it to the report file
        Get-DhcpServerv4Scope -ComputerName $compName |
        ConvertTo-Html @htmlParams -Property ScopeId, Name, StartRange, EndRange, SubnetMask, LeaseDuration, State  | Out-File $reportName -Append

        # Get the list of excluded addresses and append it to the report file
        "<h3>List of excluded addreses for $compName</h3>" | Out-File $reportName -Append
        Get-DhcpServerv4ExclusionRange -ComputerName $compName | 
        ConvertTo-Html @htmlParams -Property ScopeId, StartRange, EndRange  | Out-File $reportName -Append

        # Get the list of options at SERVER LEVEL and append it to the report file
        "<h3>List of Option Value at Server level</h3>" | Out-File  $reportName -Append
        Get-DhcpServerv4OptionValue -ComputerName $compName |
        # I use this loop from Chat-GPT to expand the Value property since I am having a hard time parsing it to HTML
        ForEach-Object {
            foreach ($val in $_.Value) {
                $_ | Select-Object ScopeId, OptionId, Name, @{Name="Value"; Expression={$val}}
            }
        } |
        ConvertTo-Html @htmlParams -Property ScopeId, OptionId, Name, Value | Out-File  $reportName -Append

        # Get the list of options at SCOPE LEVEL and append it to the report file
        # create an array
        $scopeIDs = @()
        # Retrieve all scope IDs and store them in the array
        Get-DhcpServerv4Scope -ComputerName $compName | ForEach-Object {
            $scopeIDs += $_.ScopeId
        }
        # Loop through the array of scope IDs
        foreach ($scopeID in $scopeIDs) {
            # Perform actions for each scope ID
            "<h3>List of Option Value for Scope ID : $scopeID</h3>" | Out-File  $reportName  -Append
            Get-DhcpServerv4OptionValue -ComputerName $compName -ScopeID $scopeID | 
            # I use this loop from Chat-GPT to expand the Value property since I am having a hard time parsing it to HTML
            ForEach-Object {
                foreach ($val in $_.Value) {
                    $_ | Select-Object ScopeId, OptionId, Name, @{Name="Value"; Expression={$val}}
                }
            } |
            ConvertTo-Html @htmlParams -Property ScopeId, OptionId, Name, Value | Out-File  $reportName  -Append
        }
        # Launch the DHCPv4 Scope Report.htm
        Invoke-Item $reportName
    }
    catch {
        Write-Host "Failed to connect to '$compName ': $_ " -ForegroundColor Red
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
    $operation = Read-Host "Select an operation to perform (1-6):"

    # Validate the user's input
    try{ 
        $operation = [int]$operation
            if ($operation -lt 1 -or $operation -gt 6) {
                Write-Host "Invalid input. Please select a number between 1 and 6."
                continue
            }   
    } 
    catch {
        Write-Host "Operation is invalid. Please input numeric values."
    }  
      
    # Perform the selected operation
    switch ($operation) {
        1 {
            # Code for operation 1
            Write-Host "Performing addition of DHCPv4 Scope..." -ForegroundColor Yellow
            # Add a new IPv4 scope range
            Add_IPv4_Scope
        }
        2 {
            # Code for operation 2
            Write-Host "Performing exclusion of IPv4 addresses..." -ForegroundColor Yellow
            # Exclude IPv4 range from a scope
            Exclude_IPv4_range
            
        }
        3 {
            # Code for operation 3
            Write-Host "Performing Option settings..." -ForegroundColor Yellow
            # Set Option Value
            Set_Option
            
        }
        4 {
            # Code for operation 4
            Write-Host "Performing DHCv4 Scope import from a CSV file..." -ForegroundColor Yellow
            Import_IPv4_Scope
        }
        5 {
            # Code for operation 5
            Write-Host "Generating DHCv4 Scope report..." -ForegroundColor Yellow
            Generate_DHCPv4_Report
        }
        6 {
            # Code for operation 6
            Write-Host "Exiting..." -ForegroundColor Yellow
            $continue = $false
        }
    }
}

# End of script



