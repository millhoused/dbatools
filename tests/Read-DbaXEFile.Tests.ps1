$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
$global:TestConfig = Get-TestConfig
$base = (Get-Module -Name dbatools | Where-Object ModuleBase -notmatch net).ModuleBase

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }
        [object[]]$knownParameters = 'Path', 'Raw', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    Context "Verifying command output" {
        # THIS WORKS, I SWEAR
        It "returns some results" {
            $results = Get-DbaXESession -SqlInstance $TestConfig.instance2 | Read-DbaXEFile -Raw -WarningAction SilentlyContinue
            [System.Linq.Enumerable]::Count($results) -gt 1 | Should Be $true
        }
        It "returns some results" {
            $results = Get-DbaXESession -SqlInstance $TestConfig.instance2 | Read-DbaXEFile -WarningAction SilentlyContinue
            $results.Count -gt 1 | Should Be $true
        }
    }
}
