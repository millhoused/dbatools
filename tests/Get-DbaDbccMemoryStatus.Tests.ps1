$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
$global:TestConfig = Get-TestConfig

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance', 'SqlCredential', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}
Describe "$commandname  Integration Test" -Tag "IntegrationTests" {
    $props = 'ComputerName', 'InstanceName', 'RecordSet', 'RowId', 'RecordSetId', 'Type', 'Name', 'Value', 'ValueType'
    $result = Get-DbaDbccMemoryStatus -SqlInstance $TestConfig.instance2

    Context "Validate standard output" {
        foreach ($prop in $props) {
            $p = $result[0].PSObject.Properties[$prop]
            It "Should return property: $prop" {
                $p.Name | Should Be $prop
            }
        }
    }

    Context "Command returns proper info" {
        It "returns results for DBCC MEMORYSTATUS" {
            $result.Count -gt 0 | Should Be $true
        }
    }
}
