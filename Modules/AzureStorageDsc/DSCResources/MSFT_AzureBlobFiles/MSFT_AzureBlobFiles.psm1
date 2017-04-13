function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountName,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountKey,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountContainer,
        
        [parameter(Mandatory = $false)]
        [System.Boolean]
        $ValidateCheckSum
    )
    
    Write-Verbose -Message "Passing out the current settings that the resource should use"

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
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountName,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountKey,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountContainer,
        
        [parameter(Mandatory = $false)]
        [System.Boolean]
        $ValidateCheckSum
    )
    
    Write-Verbose -Message "Copying content from Azure storage to local path"

    if ( -not (Test-Path $Path) ) 
    { 
        New-Item $Path -Type Directory | Out-Null 
    }

    if ($null -eq (Get-Module -Name Azure.Storage -ListAvailable))
    {
        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            Install-Module -Name Azure.Storage
        }
        else 
        {
            throw ("Unable to find module 'Azure.Storage' on this machine. Please either " + `
                   "install it (following the steps at " + `
                   "https://azure.microsoft.com/en-us/downloads/) or upgrade your machine to " + `
                   "use PowerShell 5.0 to allow this DSC resource to attempt to download it " + `
                   "for you automatically")
        }
    }

    Import-Module -Name Azure.Storage

    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName `
                                       -StorageAccountKey $StorageAccountKey

    $blobs = Get-AzureStorageBlob -Container $StorageAccountContainer `
                                  -Context $context

    $blobs | ForEach-Object -Process {
        $VerbosePreference = "Continue"
        $localPath = Join-Path -Path $Path -ChildPath $_.Name
        if ((Test-Path -Path $localPath) -eq $false) 
        {
            Write-Verbose -Message "Downloading file $($_.Name) as it does not exist"
            Get-AzureStorageBlobContent -Blob $_.Name `
                                        -Container $StorageAccountContainer `
                                        -Destination $Path `
                                        -Context $context | Out-Null
        } 
        else 
        {
            if ($ValidateCheckSum -eq $true) 
            {
                $md5 = New-Object -TypeName "System.Security.Cryptography.MD5CryptoServiceProvider"
                $localFileBytes = [System.IO.File]::ReadAllBytes($localPath)
                $md5Hash = $md5.ComputeHash($localFileBytes)
                $localHash = [System.Convert]::ToBase64String($md5Hash)
                $cloudHash = $_.ICloudBlob.Properties.ContentMD5

                if ($localHash -ne $cloudHash) 
                {
                    Write-Verbose -Message ("Downloading file $($_.Name) as the local hash " + `
                                            "does not match the hash in Azure")
                    Get-AzureStorageBlobContent -Blob $_.Name `
                                                -Container $StorageAccountContainer `
                                                -Destination $Path `
                                                -Context $context `
                                                -Force | Out-Null
                }
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountName,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountKey,
        
        [parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountContainer,
        
        [parameter(Mandatory = $false)]
        [System.Boolean]
        $ValidateCheckSum
    )

    $VerbosePreference = "Continue"

    if ( -not (Test-Path $Path) ) 
    { 
        Write-Verbose -Message ("Local path $Path does not exist, the folder can not be in " + `
                                "sync with cloud storage")
        return $false 
    }

    if ($null -eq (Get-Module -Name Azure.Storage -ListAvailable))
    {
        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            Install-Module -Name Azure.Storage
        }
        else 
        {
            throw ("Unable to find module 'Azure.Storage' on this machine. Please either " + `
                   "install it (following the steps at " + `
                   "https://azure.microsoft.com/en-us/downloads/) or upgrade your machine to " + `
                   "use PowerShell 5.0 to allow this DSC resource to attempt to download it " + `
                   "for you automatically")
        }
    }

    Import-Module -Name Azure.Storage

    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName `
                                       -StorageAccountKey $StorageAccountKey
    $blobs = Get-AzureStorageBlob -Container $StorageAccountContainer `
                                  -Context $context

    $returnVal = $true
    
    $blobs | ForEach-Object {
        $localPath = Join-Path -Path $Path -ChildPath $_.Name
        if ((Test-Path -Path $localPath) -eq $false) 
        {
            Write-Verbose -Message "File $($_.Name) does not exist"
            $returnVal = $false
        } 
        else 
        {
            if ($ValidateCheckSum -eq $true)
            {
                $md5 = New-Object -TypeName "System.Security.Cryptography.MD5CryptoServiceProvider"
                $localFileBytes = [System.IO.File]::ReadAllBytes($localPath)
                $md5Hash = $md5.ComputeHash($localFileBytes)
                $localHash = [System.Convert]::ToBase64String($md5Hash)
                $cloudHash = $_.ICloudBlob.Properties.ContentMD5

                if ($localHash -ne $cloudHash) 
                {
                    Write-Verbose -Message ("File $($_.Name) does not match the MD5 hash of " + `
                                            "the file in cloud storage and needs to be " + `
                                            "downloaded again")
                    $returnVal = $false
                }
            }
        }
    }

    return $returnVal
}

Export-ModuleMember -Function *-TargetResource
