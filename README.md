# DHCPManager
This is a DHCPv4 nmanagement tool written in Powershell


DHCP Server Scope Management Tool
This PowerShell script enables DHCPv4 scope management and reporting. It allows
users to add new scopes, exclude IP ranges, set options, import configurations from
CSV, and generate detailed HTML reports. The script presents a user-friendly menu
interface and facilitates various DHCPv4 management tasks. A remote DHCP server
can also be configured provided that it is part of the domain, enhancing efficiency and
organization.
Usage
Inputs:
  • Computer name - full computer name of the DHCPv4 server (e.g. sherwin-dc01.sherwindomain.com)
  • Scope Name - Specifies the name of the IPv4 scope that is added.
  • Start Range - Specifies the starting IP address of the range in the subnet from which IP
  addresses should be leased or exclude by the DHCP server service.
  • End Range - Specifies the ending IP address of the range in the subnet from which IP
  addresses should be leased or exclude by the DHCP server service.
  • Scope Id - Specifies the scope ID, in IPv4 address format for which one or more option
  values are set.
  • Option Id - Specifies the numeric identifier (ID) of the option for which one or more values
  are set.
  • Value - Specifies one or more values to be set for the option.

Outputs:
  • Operation 1: Add DHCPv4 Scope in the specified computer name
  • Operation 2: Exclude IP address range from the provided Scope ID in a computer
  • Operation 3: Set the option ID and value. This can be in Server Level or Scope ID level
  • Operation 4: Import DHCPv4 Scope, Excluded IP addresses, and Option settings from the
  CSV file
  • Operation 5: Generate an HTML repot

Errors:
  In case the tool failed to one of its operation, here are the possible issues:
  • Wrong computer name
  • Wrong IP address ranges and subne tmask
  • Wrong option ID and value provided
  • csv file doesn’t exists
  • Scope ID or name already exists (I highly recommend to run the Generate report first before
  trying to make any changes)
