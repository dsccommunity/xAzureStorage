Configuration BlobStorageSample
{
    Import-DscResource xAzureStorage

    xAzureBlobFiles ExampleFiles {
        Path                    = "C:\sample path"
        StorageAccountName      = "myfakeaccount"
        StorageAccountContainer = "container1"
        StorageAccountKey       = "Your Storage Key Goes Here"
    }
}