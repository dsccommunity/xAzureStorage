# xAzureStorage

[![Build status](https://ci.appveyor.com/api/projects/status/agagdsi40p1g7a5f/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xazurestorage/branch/master)

The xAzureStorage PowerShell module provides DSC resources specific to working with Azure storage accounts and the content they store.

This module is provided AS IS, and is not supported through any Microsoft standard support program or service. 
The "x" in xAzureStorage stands for experimental, which means that these resources will be fix forward and monitored by the module owner(s).

Please leave comments, feature requests, and bug reports in the issues tab for this module.

If you would like to modify xAzureStorage module, please feel free. 

## Installation

To install the xAzureStorage module:

Unzip the content under $env:ProgramFiles\WindowsPowerShell\Modules folder 

To confirm installation:

Run Get-DSCResource to see that xAzureStorage is among the DSC Resources listed. Requirements This module requires the latest version of PowerShell (v4.0, which ships in Windows 8.1 or Windows Server 2012R2). 
To easily use PowerShell 4.0 on older operating systems, install WMF 4.0. 
Please read the installation instructions that are present on both the download page and the release notes for WMF 4.0

## DSC Resources

Below is a list of DSC resource types that are currently provided by xAzureStorage:

 - xAzureBlobFiles

## Examples

Review the "examples" directory in the xAzureStorage resource for some general examples of how the overall module can be used.

## Version History

### 1.0.0.0

 * Initial release including xAzureBlobFiles resource
