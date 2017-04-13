function Invoke-TestHarness
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        $TestResultsFile,

        [Parameter(Mandatory = $false)]
        [System.String]
        $DscTestsPath,

        [Parameter(Mandatory = $false)]
        [Switch]
        $IgnoreCodeCoverage
    )

    Write-Verbose -Message 'Commencing all AzureStorageDsc tests'

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '..\' -Resolve

    $testCoverageFiles = @()
    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        Get-ChildItem -Path "$repoDir\modules\AzureStorageDsc\DSCResources\**\*.psm1" -Recurse | ForEach-Object {
            if ($_.FullName -notlike '*\DSCResource.Tests\*') 
            {
                $testCoverageFiles += $_.FullName
            }
        }
    }

    $testResultSettings = @{ }
    if ([String]::IsNullOrEmpty($TestResultsFile) -eq $false) 
    {
        $testResultSettings.Add('OutputFormat', 'NUnitXml' )
        $testResultSettings.Add('OutputFile', $TestResultsFile)
    }

    Import-Module -Name "$repoDir\modules\AzureStorageDsc\AzureStorageDsc.psd1"
    $testsToRun = @(
        "$repoDir\tests\unit"
    )


    # DSC Common Tests
    if ($PSBoundParameters.ContainsKey('DscTestsPath') -eq $true)
    {
        $testsToRun += @( $DscTestsPath )
    }

    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        $testResultSettings.Add('CodeCoverage', $testCoverageFiles)
    }

    $results = Invoke-Pester -Script $testsToRun -PassThru @testResultSettings

    return $results
}
