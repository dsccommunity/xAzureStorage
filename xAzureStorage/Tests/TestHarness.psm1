function Invoke-xAzureStorageTests() {
    param
    (
        [parameter(Mandatory = $false)] [System.String] $testResultsFile
    )

    $repoDir = (Join-Path $PSScriptRoot "..\" -Resolve).TrimEnd('\')

    $testCoverageFiles = @()
    Get-ChildItem "$repoDir\modules\xAzureStorage\**\*.psm1" -Recurse | ForEach-Object { $testCoverageFiles += $_.FullName }

    $testResultSettings = @{ }
    if ([string]::IsNullOrEmpty($testResultsFile) -eq $false) {
        $testResultSettings.Add("OutputFormat", "NUnitXml" )
        $testResultSettings.Add("OutputFile", $testResultsFile)
    }
    Import-Module "$repoDir\modules\xAzureStorage\xAzureStorage.psd1"

    $results = Invoke-Pester "$repoDir\Tests" -CodeCoverage $testCoverageFiles -PassThru @testResultSettings

    return $results
}

Export-ModuleMember -Function *