# DHCPv4 Scope Manager

This PowerShell script provides an interactive tool for managing DHCPv4 scopes on a specified DHCP server. It supports various operations, including adding and configuring DHCP scopes, excluding IP ranges, setting options, importing configuration from a CSV file, and generating HTML reports.

## Features

- **Add DHCPv4 Scope**: Define and add a new DHCPv4 scope with a specified IP range, subnet mask, and DHCP server name.
- **Exclude IP Addresses**: Exclude specified IP address ranges from an existing DHCPv4 scope.
- **Set Option Value**: Set DHCP option values at either the scope or server level.
- **Import DHCPv4 Scope from CSV**: Load DHCP configurations from a CSV file, including scopes, exclusions, and option values.
- **Generate DHCPv4 Scope Report**: Create an HTML report showing current DHCPv4 scope configurations, exclusions, and option values.

## Usage Instructions

### Prerequisites

- **PowerShell**: Set the execution policy to allow the execution of remote-signed scripts:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
  ```
- Ensure that the DHCP PowerShell module is installed and that you have the necessary permissions to manage DHCP settings.

### Running the Script

1. Open PowerShell with Administrator privileges.
2. Run the script to launch the DHCPv4 Scope Manager tool.
3. Follow the on-screen prompts to select a specific operation.

## Menu Options

### Option 1: Add New DHCPv4 Scope
- Enter the DHCP server name, scope name, IP range, and subnet mask.

### Option 2: Exclude IP Addresses
- Specify the DHCP server, scope ID, and IP range to exclude.

### Option 3: Set Option Value
- Input the DHCP server, option ID, value, and scope ID (optional for scope-level configuration).

### Option 4: Import DHCPv4 Scope from CSV
- Provide a path to a CSV file containing scope configurations. The CSV should include fields for:
  - `ComputerName`
  - `ScopeName`
  - `StartIP`
  - `EndIP`
  - `SubnetMask`
  - `Excluded_StartIP`
  - `Excluded_EndIP`
  - `Option_ID`
  - `Value`

### Option 5: Generate DHCPv4 Scope Report
- Generate an HTML report of the current DHCP configurations, exclusions, and option values for a specified DHCP server.

### Option 6: Exit
- Exits the tool.

## Report Generation

The report is saved as an HTML file in the current directory with the format `DHCPv4 Scope Report-<timestamp>.htm`. It includes details on scopes, exclusions, and options.

---

Feel free to customize this script further to meet your specific needs or contribute enhancements!
