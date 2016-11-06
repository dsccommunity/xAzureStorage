<#
.EXAMPLE
    This example shows how to download the contents of a storage container
    named 'container1' in a storage account called 'myfakeaccount' to
    "C:\sample path"
#>

Configuration Example
{
    Import-DscResource -ModuleName AzureStorageDsc

    node localhost
    {
        AzureBlobFiles ExampleFiles 
        {
            Path                    = "C:\sample path"
            StorageAccountName      = "myfakeaccount"
            StorageAccountContainer = "container1"
            StorageAccountKey       = "Your Storage Key Goes Here"
        }
    }
}
