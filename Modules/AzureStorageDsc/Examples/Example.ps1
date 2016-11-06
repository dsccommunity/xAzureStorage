Configuration BlobStorageSample
{
    Import-DscResource AzureStorageDsc

    AzureBlobFiles ExampleFiles {
        Path                    = "C:\sample path"
        StorageAccountName      = "myfakeaccount"
        StorageAccountContainer = "container1"
        StorageAccountKey       = "Your Storage Key Goes Here"
    }
}
