[CmdletBinding()]
param()

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

$RepoRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\" -Resolve

$ModuleName = "MSFT_AzureBlobFiles"
Import-Module (Join-Path $RepoRoot "Modules\AzureStorageDsc\DSCResources\$ModuleName\$ModuleName.psm1")

Describe "AzureBlobFiles" {
    InModuleScope $ModuleName {

        $RepoRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\" -Resolve
        $VerbosePreference = "SilentlyContinue"

        $testParams = @{
            Path                    = "$RepoRoot\Modules\AzureStorageDsc\"
            StorageAccountName      = "myfakeaccount"
            StorageAccountContainer = "container1"
            StorageAccountKey       = "Your Storage Key Goes Here"
            ValidateCheckSum        = $true
        }

        if ($null -eq (Get-Command New-AzureStorageContext -ErrorAction SilentlyContinue)) 
        {
            function New-AzureStorageContext() { }
            Add-Type @"
namespace Microsoft.WindowsAzure.Commands.Common.Storage {
    public enum AzureStorageContext { EmptyContextInstance };
}        
"@
        }
        
        if ($null -eq (Get-Command Get-AzureStorageBlob -ErrorAction SilentlyContinue)) 
        {
            function Get-AzureStorageBlob() { }
        }
        if ($null -eq (Get-Command Get-AzureStorageBlobContent -ErrorAction SilentlyContinue)) 
        {
            function Get-AzureStorageBlobContent() { }
        }

        Mock -CommandName Import-Module -MockWith { }

        $psd1Path = ($RepoRoot + "\Modules\AzureStorageDsc\AzureStorageDsc.psd1")
        $md5 = New-Object -TypeName "System.Security.Cryptography.MD5CryptoServiceProvider"
        $localFileBytes = [System.IO.File]::ReadAllBytes($psd1Path)
        $md5Hash = $md5.ComputeHash($localFileBytes)
        $localHash = [System.Convert]::ToBase64String($md5Hash)
        
        Mock -CommandName New-Item { 
            return @{} 
        }
        Mock -CommandName New-AzureStorageContext { 
            return [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance 
        }
        Mock -CommandName Get-AzureStorageBlob { 
            return @(
                @{
                    Name = "AzureStorageDsc.psd1"
                    ICloudBlob = @{
                        Properties = @{
                            ContentMD5 = $localHash
                        }
                    }
                }
            ) 
        }
        
        Mock -CommandName Get-AzureStorageBlobContent { @{} }

        Context "The local path does not exist and files have not been synced" {

            Mock -CommandName Test-Path { return $false }

            It "cretes the local path and downloads files" {
                Set-TargetResource @testParams
                Assert-MockCalled New-Item
                Assert-MockCalled Get-AzureStorageBlobContent
            }

            It "returns false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }
        }

        Context "The local path exists but no files have been synced" {

            Mock -CommandName Test-Path { return $true } -ParameterFilter { $Path -eq $testParams.Path }
            Mock -CommandName Test-Path { return $false } -ParameterFilter { $Path -ne $testParams.Path }

            It "downloads files to the local directory" {
                Set-TargetResource @testParams
                Assert-MockCalled Get-AzureStorageBlobContent
            }

            It "returns false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "returns the provided values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }
        }

        Context "The local path exits and all files are synced" {
            
            Mock -CommandName Test-Path { return $true }

            It "returns true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context "The local path exists and files to match match the provided hash values" {

            Mock -CommandName Test-Path { return $true }
            Mock -CommandName Join-Path { return $psd1Path }

            Mock -CommandName Get-AzureStorageBlob { return @(
                @{
                    Name = "AzureStorageDsc.psd1"
                    ICloudBlob = @{
                        Properties = @{
                            ContentMD5 = "Wrong Hash"
                        }
                    }
                }
            ) }

            It "downloads files to the local directory" {
                Set-TargetResource @testParams
                Assert-MockCalled Get-AzureStorageBlobContent
            }

            It "returns false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            $testParams.ValidateCheckSum = $false

            It "ignores the failing hash in the set method when told to skip the hash check" {
                Set-TargetResource @testParams
            }

            It "ignores the failing hash in the test method when told to skip the hash check" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

    }
}
