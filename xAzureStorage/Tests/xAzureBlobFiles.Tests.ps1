[CmdletBinding()]
param()

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

$RepoRoot = (Resolve-Path $PSScriptRoot\..).Path

$ModuleName = "MSFT_xAzureBlobFiles"
Import-Module (Join-Path $RepoRoot "Modules\xAzureStorage\DSCResources\$ModuleName\$ModuleName.psm1")

Describe "xAzureBlobFiles" {
    InModuleScope $ModuleName {
        $testParams = @{
            Path                    = ((Resolve-Path $PSScriptRoot\..).Path + "\Modules\xAzureStorage\")
            StorageAccountName      = "myfakeaccount"
            StorageAccountContainer = "container1"
            StorageAccountKey       = "Your Storage Key Goes Here"
        }

        if ($null -eq (Get-Command New-AzureStorageContext -ErrorAction SilentlyContinue)) {
            function New-AzureStorageContext() { }
            Add-Type @"
namespace Microsoft.WindowsAzure.Commands.Common.Storage {
    public enum AzureStorageContext { EmptyContextInstance };
}        
"@
        }
        if ($null -eq (Get-Command Get-AzureStorageBlob -ErrorAction SilentlyContinue)) {
            function Get-AzureStorageBlob() { }
        }
        if ($null -eq (Get-Command Get-AzureStorageBlobContent -ErrorAction SilentlyContinue)) {
            function Get-AzureStorageBlobContent() { }
        }

        $RepoRoot = (Resolve-Path $PSScriptRoot\..).Path
        $psd1Path = ($RepoRoot + "\Modules\xAzureStorage\xAzureStorage.psd1")
        $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $localHash = [System.Convert]::ToBase64String($md5.ComputeHash([System.IO.File]::ReadAllBytes($psd1Path)))
        
        Mock New-Item { return @{} }
        Mock New-AzureStorageContext { return [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance }
        Mock Get-AzureStorageBlob { return @(
            @{
                Name = "xAzureStorage.psd1"
                ICloudBlob = @{
                    Properties = @{
                        ContentMD5 = $localHash
                    }
                }
            }
        ) }
        Mock Get-AzureStorageBlobContent { @{} }

        Context "The local path does not exist and files have not been synced" {

            Mock Test-Path { return $false }

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

            Mock Test-Path { return $true } -ParameterFilter { $Path -eq $testParams.Path }
            Mock Test-Path { return $false } -ParameterFilter { $Path -ne $testParams.Path }

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
            
            Mock Test-Path { return $true }

            It "returns true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context "The local path exists and files to match match the provided hash values" {

            Mock Test-Path { return $true }
            Mock Join-Path { return $psd1Path }

            Mock Get-AzureStorageBlob { return @(
                @{
                    Name = "xAzureStorage.psd1"
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
        }

    }
}