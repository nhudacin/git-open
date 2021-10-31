$moduleRoot = Split-Path -Parent $PSScriptRoot

# clean the session & re-import
Remove-Module "git-open" -Force -ErrorAction Ignore
Import-Module "$moduleRoot\git-open.psm1" -Force

InModuleScope git-open {
  Describe 'Get-UrlFromGitConfig' {    
    $repoRoot = Split-Path -Parent $moduleRoot

    It 'Parses the URL from a GitHub config file' {
      Get-UrlFromGitConfig -ConfigPath $(Join-Path $repoRoot 'test/fixtures/gitconfig.github.txt') | Should be 'https://github.com/nhudacin/hello'
    }

    It 'Parses the URL from a BitBucket config file' { 
      Get-UrlFromGitConfig -ConfigPath $(Join-Path $repoRoot 'test/fixtures/gitconfig.bitbucketcustom.txt') | Should be 'ssh://git@git.companyname.com:7999/bbproject/bbrepo'
    }

    It 'Parses the URL from an Azure Devops config file' {
      Get-UrlFromGitConfig -ConfigPath $(Join-Path $repoRoot 'test/fixtures/gitconfig.azuredevops.txt') | Should be 'https://organization@dev.azure.com/organization/project/_git/repo'
    }

    It 'Does not strip off the trailing g in a repo name' {
      Get-UrlFromGitConfig -ConfigPath $(Join-Path $repoRoot 'test/fixtures/gitconfig.trimend_bug.txt') | Should be 'https://github.com/nhudacin/hellog'
    }

  }
}