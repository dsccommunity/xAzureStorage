function Invoke-AzureStorageDscTestSuite
{
    param
    (
        [parameter(Mandatory = $false)] 
        [System.String]  
        $TestResultsFile,

        [parameter(Mandatory = $false)] 
        [System.String]  
        $DscTestsPath,

        [parameter(Mandatory = $false)] 
        [System.Boolean] 
        $CalculateTestCoverage = $true
    )

    Write-Verbose "Commencing AzureStorageDsc unit tests"

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath "..\..\" -Resolve

    $testCoverageFiles = @()
    if ($CalculateTestCoverage -eq $true) 
    {
        Write-Warning -Message ("Code coverage statistics are being calculated. This will slow the " + `
                                "start of the tests by several minutes while the code matrix is " + `
                                "built. Please be patient")
        Get-ChildItem "$repoDir\modules\AzureStorageDsc\**\*.psm1" -Recurse | ForEach-Object -Process { 
            if ($_.FullName -notlike "*\DSCResource.Tests\*") 
            {
                $testCoverageFiles += $_.FullName    
            }
        }    
    }
    
    $testResultSettings = @{ }
    if ([string]::IsNullOrEmpty($TestResultsFile) -eq $false) 
    {
        $testResultSettings.Add("OutputFormat", "NUnitXml" )
        $testResultSettings.Add("OutputFile", $TestResultsFile)
    }
    Import-Module -Name "$repoDir\modules\AzureStorageDsc\AzureStorageDsc.psd1"
    
    $testsToRun = @(
        @{
            'Path' = "$repoDir\tests\unit"
            'Parameters' = @{ }
        }
    )
    
    if ($PSBoundParameters.ContainsKey("DscTestsPath") -eq $true) 
    {
        $testsToRun += @{
            'Path' = $DscTestsPath
            'Parameters' = @{ }
        }
    }
    $Global:VerbosePreference = "SilentlyContinue"
    $results = Invoke-Pester -Script $testsToRun `
                             -CodeCoverage $testCoverageFiles `
                             -PassThru `
                             @testResultSettings

    return $results
}

Export-ModuleMember -Function *
