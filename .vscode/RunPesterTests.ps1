
$harnessPath = Join-Path -Path $PSScriptRoot `
                         -ChildPath "..\Tests\Unit\TestHarness.psm1" `
                         -Resolve
Import-Module -Name $harnessPath -Force

$DscTestsPath = Join-Path -Path $PSScriptRoot `
                          -ChildPath "..\Modules\AzureStorageDsc\DscResource.Tests" `
                          -Resolve
if ((Test-Path $DscTestsPath) -eq $false) 
{
    Write-Warning -Message ("Unable to locate DscResource.Tests repo at '$DscTestsPath', " + `
                            "common DSC resource tests will not be executed")
    Invoke-AzureStorageDscTestSuite -CalculateTestCoverage $false
} 
else 
{
    Invoke-AzureStorageDscTestSuite -DscTestsPath $DscTestsPath -CalculateTestCoverage $false
}
