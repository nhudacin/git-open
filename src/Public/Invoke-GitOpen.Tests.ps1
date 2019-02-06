$moduleRoot = Split-Path -Parent $PSScriptRoot
Remove-Module "git-open" -Force -ErrorAction Ignore
Import-Module "$moduleRoot\git-open.psm1" -Force

InModuleScope git-open {
  Describe 'Invoke-GitOpen' {
    Mock Start-Process { Write-Output $FilePath}
    
    $gitHubConfig = @"
[core]
  repositoryformatversion = 0
  filemode = false
  bare = false
  logallrefupdates = true
  ignorecase = true
[remote "origin"]
  url = https://github.com/nhudacin/hello.git
  fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
  remote = origin
  merge = refs/heads/master
"@

    $currentLocation = Get-Location

    Context "GitHub" {
      Setup -File 'gh/.git/config' -Content $gitHubConfig
      Setup -File 'gh/.git/HEAD' -Content 'ref: refs/heads/architecture-diagram'
      Set-Location "$TestDrive/gh"

      It 'Opens up GitHub' {
        Invoke-GitOpen
        Assert-MockCalled Start-Process -ParameterFilter { $FilePath -match 'https://github.com/nhudacin/hello/tree/architecture-diagram' } -Exactly 1 -Scope It
      }

      It 'Parses the current branch and adds it to the URL' {
        $url = Invoke-GitOpen
        $url| Should Be 'https://github.com/nhudacin/hello/tree/architecture-diagram'
      }
    }

    Set-Location $currentLocation
  }
}