# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

function Banner {
    Write-Host "===============================" -ForegroundColor Yellow
    Write-Host " DHCPv4 Scope Management Tool "  -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Yellow
}

# Define a function to display the menu
function Show-Menu {
    Write-Host "1. Add new IPv4 Scope" 
    Write-Host "2. Exclude IPv4 Scope"
    Write-Host "3. Configure Option Value"
    Write-Host "4. Import IPv4 Scope"
    Write-Host "5. Generate DHCPv4 Scope Report"
    Write-Host "6. Exit"
}

function Add_IPv4_Scope {
    $scopeName = Read-Host "Please input Scope Name"
    $startIP = Read-Host "Please input start IP Address range"
    $endIP = Read-Host "Please input end IP Address range"
    $subnetMask = Read-Host "Please input subnet mask"
    $compName = Read-Host "Please input computer name of the target DHCP server"
    
    try {
        
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $startIP -EndRange $endIP -SubnetMask $subnetMask -ComputerName $compName
        Write-Host "'$scopeName' with IP range:'$startIP - $endIP' was succesfully added to $compName." -ForegroundColor Green      
    }
    catch {
        Write-Host "Failed to add '$scopeName': $_"  -ForegroundColor Red
    }
    Write-Host "`n"
}

function Exclude_IPv4_range {
    $ex_startIP = Read-Host "Please input start IP address to exclude"
    $ex_endIP = Read-Host "Please input end IP address to exclude"
    $scopeName = Read-Host "Please input the scope name"
    $compName = Read-Host "Please input computer name of the DHCP server"
    $scopeID = (Get-DhcpServerv4Scope -ComputerName $compName | Where-Object Name -eq $scopeName).ScopeId

    try {
        Add-DhcpServerv4ExclusionRange -ScopeID $scopeID -StartRange $ex_startIP -EndRange $ex_endIP -ComputerName $compName
        Write-Host "IP address range $ex_startIP - $ex_endIP were excluded for scope ID $scopeID from $compName." -ForegroundColor Green   
    }
    catch {
        Write-Host "Failed to exclude IP range: $_" -ForegroundColor Red
    }        

}

function Set_Option {
    $optionID = Read-Host "Please input the option ID"
    $optionValue = Read-Host "Please input the value for this option"
    $scopeName = Read-Host "Please input the scope name"
    $compName = Read-Host "Please input computer name of the DHCP server"
    $scopeID = (Get-DhcpServerv4Scope -ComputerName $compName | Where-Object Name -eq $scopeName).ScopeId

    try {
        Set-DhcpServerv4OptionValue -ScopeID $scopeID -OptionID $optionID -Value $optionValue -ComputerName $compName
        Write-Host "Option ID $optionID with the value of $optionValue was set for $scopeID in $compName." -ForegroundColor Green      
    }
    catch {
        Write-Host "Failed to set option for scope ID '$scopeID': $_" -ForegroundColor Red
    } 
}

# function Import_IPv4_Scope {
#     # Prompt the user for the path to the CSV file
#     $csvPath = Read-Host "Enter the path to the CSV file"

#     Import-Csv $csvPath | ForEach-Object {
#         try {
#             $compName = $_.ComputerName
#             Add-DhcpServerv4Scope -Name $_.ScopeName -StartRange $_.StartIP -EndRange $_.EndIP -SubnetMask $_.SubnetMask -ComputerName $compName 
#             $scopeID = (Get-DhcpServerv4Scope -ComputerName $compName | Where-Object Name -eq $_.ScopeName).ScopeId
#             Add-DhcpServerv4ExclusionRange -ScopeID $scopeID -StartRange $_.Excluded_StartIP -EndRange $_.Excluded_EndIP -ComputerName $compName
#             Set-DhcpServerv4OptionValue -ScopeID $scopeID -OptionID $_.Option_ID -Value $_.Value -ComputerName $compName

#         }
#         catch {
#             Write-Host "Failed to add '$scopeName': $_" -ForegroundColor Red
#         }
#     }
# }

function Import_IPv4_Scope {
    # Prompt the user for the path to the CSV file
    $csvPath = Read-Host "Enter the path to the CSV file"

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

            # Add DHCP Scope
            if ($scopeName -and $startIP -and $endIP -and $subnetMask -and $compName) {
                Add-DhcpServerv4Scope -Name $scopeName -StartRange $startIP -EndRange $endIP -SubnetMask $subnetMask -ComputerName $compName 
                $scopeID = (Get-DhcpServerv4Scope -ComputerName $compName | Where-Object Name -eq $scopeName).ScopeId
                

                # Add Exclusion Range
                if ($scopeID -and $excluded_StartIP -and $excluded_EndIP -and $compName) {
                    Add-DhcpServerv4ExclusionRange -ScopeID $scopeID -StartRange $excluded_StartIP -EndRange $excluded_EndIP -ComputerName $compName
                }

                # Set DHCP Option Value
                if ($scopeID -and $option_ID -and $value -and $compName) {
                    Set-DhcpServerv4OptionValue -ScopeID $scopeID -OptionID $option_ID -Value $value -ComputerName $compName
                }
            }
            else {
                Write-Host "One or more required fields are empty for '$scopeName'. Skipping..." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Failed to add '$scopeName': $_" -ForegroundColor Red
        }
    }
}


function Generate_DHCPv4_Report {
    
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
            Write-Host "Performing operation 1..." -ForegroundColor Yellow
            # Add a new IPv4 scope range
            Add_IPv4_Scope
        }
        2 {
            # Code for operation 2
            Write-Host "Performing operation 2..." -ForegroundColor Yellow
            # Exclude IPv4 range from a scope
            Exclude_IPv4_range
            
        }
        3 {
            # Code for operation 3
            Write-Host "Performing operation 3..." -ForegroundColor Yellow
            # Set Option Value
            Set_Option
            
        }
        4 {
            # Code for operation 4
            Write-Host "Performing operation 4..." -ForegroundColor Yellow
            Import_IPv4_Scope
        }
        5 {
            # Code for operation 5
            Write-Host "Performing operation 5..." -ForegroundColor Yellow
        }
        6 {
            # Code for operation 6
            Write-Host "Exiting..." -ForegroundColor Yellow
            $continue = $false
        }
    }
}

# End of script



