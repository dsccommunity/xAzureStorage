$harnessPath = Join-Path -Path $PSScriptRoot `
                         -ChildPath "..\Tests\Unit\TestHarness.psm1"
Import-Module -Name $harnessPath

$DscTestsPath = Join-Path -Path $PSScriptRoot `
                          -ChildPath "..\Modules\AzureStorageDsc\DscResource.Tests"

if ((Test-Path -Path $DscTestsPath) -eq $false) 
{
    throw ("Unable to locate DscResource.Tests repo at '$DscTestsPath', " + `
           "common DSC resource tests will not be executed")
}

$helperPath = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\Modules\AzureStorageDsc\DscResource.Tests\TestHelper.psm1"
Import-Module -Name $helperPath

$helperTestsPath = Join-Path -Path $PSScriptRoot `
                             -ChildPath "..\Modules\AzureStorageDsc\DscResource.Tests"
Set-Location -Path $helperTestsPath

Invoke-Pester 
