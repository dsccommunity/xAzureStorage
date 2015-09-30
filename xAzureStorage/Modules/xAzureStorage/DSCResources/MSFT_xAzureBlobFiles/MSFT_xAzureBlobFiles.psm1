function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Path,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountName,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountKey,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountContainer
    )
    return @{
        Path = $Path
        StorageAccountName = $StorageAccountName
        StorageAccountKey = $StorageAccountKey
        StorageAccountContainer = $StorageAccountContainer
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Path,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountName,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountKey,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountContainer
    )
    if ( -not (Test-Path $Path) ) { New-Item $Path  -Type Directory | Out-Null }

    Import-Module Azure

    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    $blobs = Get-AzureStorageBlob -Container $StorageAccountContainer -Context $context

    $blobs | ForEach-Object {
        $VerbosePreference = "Continue"
        if ((Test-Path -Path (Join-Path -Path $Path -ChildPath $_.Name)) -eq $false) {
            Write-Verbose "Downloading file $($_.Name) as it does not exist"
            Get-AzureStorageBlobContent -Blob $_.Name -Container $StorageAccountContainer -Destination $Path -Context $context | Out-Null
        } else {
            $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            $localHash = [System.Convert]::ToBase64String($md5.ComputeHash([System.IO.File]::ReadAllBytes((Join-Path -Path $Path -ChildPath $_.Name))))
            $cloudHash = $_.ICloudBlob.Properties.ContentMD5

            if ($localHash -ne $cloudHash) {
                Write-Verbose "Downloading file $($_.Name) as the local hash does not match the hash in Azure"
                Get-AzureStorageBlobContent -Blob $_.Name -Container $StorageAccountContainer -Destination $Path -Context $context -Force | Out-Null
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Path,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountName,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountKey,
        [parameter(Mandatory = $true)]  [System.String]  $StorageAccountContainer
    )

    $VerbosePreference = "Continue"

    if ( -not (Test-Path $Path) ) { 
        Write-Verbose "Local path $Path does not exist, the folder can not be in sync with cloud storage"
        return $false 
    }

    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    $blobs = Get-AzureStorageBlob -Container $StorageAccountContainer -Context $context

    $returnVal = $true
    
    $blobs | ForEach-Object {
        if ((Test-Path -Path (Join-Path -Path $Path -ChildPath $_.Name)) -eq $false) {
            Write-Verbose "File $($_.Name) does not exist"
            $returnVal = $false
        } else {
            $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            $localHash = [System.Convert]::ToBase64String($md5.ComputeHash([System.IO.File]::ReadAllBytes((Join-Path -Path $Path -ChildPath $_.Name))))
            $cloudHash = $_.ICloudBlob.Properties.ContentMD5

            if ($localHash -ne $cloudHash) {
                Write-Verbose "File $($_.Name) does not match the MD5 hash of the file in cloud storage and needs to be downloaded again"
                $returnVal = $false
            }
        }
    }

    return $returnVal
}