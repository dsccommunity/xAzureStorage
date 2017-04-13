# AzureStorageDsc

[![Build status](https://ci.appveyor.com/api/projects/status/agagdsi40p1g7a5f/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/AzureStorageDsc/branch/master)

The AzureStorageDsc PowerShell module (formerly known as xSharePoint) provides
DSC resources that can be used to deploy and manage a SharePoint farm.

Please leave comments, feature requests, and bug reports in the issues tab for
this module.

If you would like to modify AzureStorageDsc module, please feel free. Please
refer to the [Contribution Guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md)
for information about style guides, testing and patterns for contributing
to DSC resources.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any
additional questions or comments.

## Installation

To manually install the module, download the source code and unzip the contents
of the \Modules\AzureStorageDsc directory to the
$env:ProgramFiles\WindowsPowerShell\Modules folder

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

    Find-Module -Name AzureStorageDsc -Repository PSGallery | Install-Module

To confirm installation, run the below command and ensure you see the
SharePoint DSC resoures available:

    Get-DscResource -Module AzureStorageDsc

### Azure PowerShell requirements

This module requires the Azure.Storage PowerShell module. If you are using
PowerShell 5.0 then this will be automatically downloaded the first time
you run a resource from this module. If you are using PowerShell 4 then
this module will need to be downloaded and installed manually (following
the instructions at [https://azure.microsoft.com/en-us/downloads/](https://azure.microsoft.com/en-us/downloads/))

## Documentation and examples

For a full list of resources in AzureStorageDsc and examples on their use, check
out the [AzureStorageDsc wiki](https://github.com/PowerShell/AzureStorageDsc/wiki).
You can also review the "examples" directory in the AzureStorageDsc module for
some general use scenarios for all of the resources that are in the module.

## Changelog

A full list of changes in each version can be found in the
[change log](CHANGELOG.md).
