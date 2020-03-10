$moduleRoot = Split-Path -Parent $PSScriptRoot

# clean the session & re-import
Remove-Module "git-open" -Force -ErrorAction Ignore
Import-Module "$moduleRoot\git-open.psm1" -Force

InModuleScope git-open {
  Describe 'Find-GitConfigPath' {
    $currentLocation = (Get-Location).Path

    Context "General Tests" {
      Setup -File '.git/config' -Content "Hello Ruby"
      
      Set-Location $TestDrive
      $expectedResult = Join-Path $TestDrive '.git\config'

      It "Finds the config path from the repo root" {
        Find-GitConfigPath | Should Be $expectedResult
      }

      It "Throws an error when the git config file could not be found" {
        Remove-Item "$TestDrive/.git/config" -Force 
        { Find-GitConfigPath } | Should Throw "Could not find git config file"
      }
    }

    Context "Directory Traversal" {
      Setup -File '.git/config' -Content "Hello Ruby"
      Setup -Dir 'tests/unit/pester'

      Set-Location "$TestDrive/tests/unit/pester"
      $expectedResult = Join-Path $TestDrive '.git\config'

      It "Finds the git config uproot from the current directory" {
        Find-GitConfigPath | Should Be $expectedResult
      }
    }

    Set-Location $currentLocation
  }
}