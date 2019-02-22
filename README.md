# git-open

A powershell module for getting into a git remote's UI, quick!

## Overview

git-open is a simple PowerShell module containing exactly one function that does what it sounds like... It opens the UI for a git repository.
When I complete some code in a feature branch and I'm ready to start the process of merging it in, I need to open up a web browser to open
up a PR or advance an already open PR. This module provides a simple command to execute in a repo that opens up a web browser to the repo
UI. 

**EXAMPLE**


See the **Customization** section if you work with internal/enterprise repositories.


## Build Info


| Windows (AppVeyor) | Linux/macOS (Travis) | Code Coverage Status |
|--------------------|----------------------|----------------------|
| [![master build status][av-master-img]][av-master-site]| [![master build status][tv-master-img]][tv-master-site] | [![master build coverage][cc-master-img]][cc-master-site] |


## Installation

Will update this as soon as it's been published to the Powershell Gallery!

## Customization

I work with a corporate git system, backed by BitBucket daily. This system uses SSH to push & pull code but an HTTPS URL to interact with the front end. 
I've also used this in GitHub Enterprise (on prem GitHub) where the URL was customized to a company URL instead of the public GitHub URL. 

Invoke-GitOpen provides the ability to set custom repo types and apply rules for various configurations. This also allows you to configure multiple
repo types for those working in multiple systems. 

```powershell
 $customRepoTypes = @(
    @{
      Name = 'BitBucketCustom'
      Type = 'BitBucket'
      Find = 'ssh://git@git.companyname.com:1234'
      Replace = 'https://git.companyname.com'
    }
  )
  
  Invoke-GitOpen -CustomRepoTypes $customRepoTypes 

```

When executed in a git repository, the Find will look for that string in the .gitconfig file to determine the repo type. The Replace allows for an override 
of that string, like in the case of SSH to push/pull code but HTTPS to interact with the UI. 

That's a heck of a command to remember & type out every time though, right? [PowerShell profiles](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-6) to the rescue!

```powershell

# my profile.ps1
Import-Module git-open

function git-open {
 $customRepoTypes = @(
    @{
      Name = 'BitBucketCustom'
      Type = 'BitBucket'
      Find = 'ssh://git@git.companyname.com:1234'
      Replace = 'https://git.companyname.com'
    }
  )
  
  Invoke-GitOpen -CustomRepoTypes $customRepoTypes @args
}

```

Which allows me to execute `git-open` in any git repository, whether public & open-source GitHub or any company management system. 


## Publish

This is just a reminder for me publishing the module

```powershell
./build/scripts/package.ps1
Publish-Module -Path .ignore/build/git-open -NuGetApiKey $env:POWERSHELL_GALLERY_KEY
```

[tv-master-img]:   https://travis-ci.org/nhudacin/git-open.svg?branch=master
[tv-master-site]:  https://travis-ci.org/nhudacin/git-open
[cc-master-img]:   https://coveralls.io/repos/github/nhudacin/git-open/badge.svg?branch=master
[cc-master-site]:  https://coveralls.io/github/nhudacin/git-open?branch=master
[av-master-site]:  https://ci.appveyor.com/project/nhudacin/git-open/branch/master
[av-master-img]:   https://ci.appveyor.com/api/projects/status/eb8erd5afaa01w80/branch/master?svg=true&pendingText=master%20%E2%80%A3%20pending&failingText=master%20%E2%80%A3%20failing&passingText=master%20%E2%80%A3%20passing

