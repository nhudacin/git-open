$moduleRoot = Split-Path -Parent $PSScriptRoot

# clean the session & re-import
Remove-Module "git-open" -Force -ErrorAction Ignore
Import-Module "$moduleRoot\git-open.psm1" -Force

InModuleScope git-open {
  Describe 'Invoke-GitOpen' {
    Mock Start-Process { Write-Output $FilePath}
    
    $repoRoot = Split-Path -Parent $moduleRoot
    $currentLocation = Get-Location

    Context "GitHub" {
      $gitHubConfig = Get-Content $(Join-Path $repoRoot 'test/fixtures/gitconfig.github.txt') -Raw
      Setup -File 'gh/.git/config' -Content $gitHubConfig
      Setup -File 'gh/.git/HEAD' -Content 'ref: refs/heads/architecture-diagram'
      Set-Location "$TestDrive/gh"

      It 'Opens up GitHub' {
        Invoke-GitOpen
        Assert-MockCalled Start-Process -ParameterFilter { $FilePath -match 'https://github.com/nhudacin/hello/tree/architecture-diagram' } -Exactly 1 -Scope It
      }

      It 'Correctly opens up the pull-requests screen' {
        $url = Invoke-GitOpen -PR
        $url | Should Be 'https://github.com/nhudacin/hello/pulls'
      }

      It 'Parses the current branch and adds it to the URL' {
        $url = Invoke-GitOpen
        $url| Should Be 'https://github.com/nhudacin/hello/tree/architecture-diagram'
      }
    }

    Context "BitBucket-Custom" {
      $bitBucketConfig = Get-Content $(Join-Path $repoRoot 'test/fixtures/gitconfig.bitbucketcustom.txt') -Raw
      Setup -File 'bb/.git/config' -Content $bitBucketConfig
      Setup -File 'bb/.git/HEAD' -Content 'ref: refs/heads/architecture-diagram'
      Set-Location "$TestDrive/bb"

      $customRepoTypes = @(
        @{
          Name = 'BitBucketCustom'
          Type = 'BitBucket'
          Find = 'ssh://git@git.companyname.com:7999'
          Replace = 'https://git.companyname.com'
        }
      )

      It 'Opens up BitBucket' {
        Invoke-GitOpen -CustomRepoTypes $customRepoTypes -WarningAction SilentlyContinue
        Assert-MockCalled Start-Process -ParameterFilter { $FilePath -match 'https://git.companyname.com/projects/bbproject/repos/bbrepo' } -Exactly 1 -Scope It
      }

      It 'Correctly opens up the pull-requests screen' {
        $url = Invoke-GitOpen -CustomRepoTypes $customRepoTypes -PR -WarningAction SilentlyContinue
        $url | Should Be 'https://git.companyname.com/projects/bbproject/repos/bbrepo/pull-requests'
      }

      It 'Parses the current branch and adds it to the URL' {
        $url = Invoke-GitOpen -CustomRepoTypes $customRepoTypes -WarningAction SilentlyContinue
        $url | Should Be 'https://git.companyname.com/projects/bbproject/repos/bbrepo/browse?at=refs%2Fheads%2Farchitecture-diagram'
      }
    }

    Context "Azure Devops" {
      $azureConfig = Get-Content $(Join-Path $repoRoot 'test/fixtures/gitconfig.azuredevops.txt') -Raw
      Setup -File 'ado/.git/config' -Content $azureConfig
      Setup -File 'ado/.git/HEAD' -Content 'ref: refs/heads/architecture-diagram'
      Set-Location "$TestDrive/ado"

      It 'Opens up Azure Devops' {
        Invoke-GitOpen
        Assert-MockCalled Start-Process -ParameterFilter { $FilePath -match 'https://dev.azure.com/organization/project/_git/repo' } -Exactly 1 -Scope It
      }

      It 'Correctly opens up the pull-requests screen' {
        $url = Invoke-GitOpen -PR
        $url | Should Be 'https://dev.azure.com/organization/project/_git/repo/pullrequests'
      }

      It 'Parses the current branch and adds it to the URL' {
        $url = Invoke-GitOpen
        $url| Should Be 'https://dev.azure.com/organization/project/_git/repo?version=GBarchitecture-diagram'
      }
    }

    Set-Location $currentLocation
  }
}