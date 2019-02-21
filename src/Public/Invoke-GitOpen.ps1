<#
.SYNOPSIS
    Opens up a browser window to the git repository's remote

.DESCRIPTION
    When executed from in a git repository, will open up a web browser to the 
    repository's remote configuration. This allows for easy and seamless transition
    between local work and remote work - managing pull requests, issues, and general 
    code management stuff.

.PARAMETER PR
    Switch to open up the remote config pull request screen

.PARAMETER CustomRepoTypes
    This array allows for some customization. In a lot of enterprise settings, a
    custom URL is used for the source control management system. An array of 
    repo types that can be used to find & replace values in the .gitconfig. 

    Each object in the array should include these properties: 
      Name: The name of the custom config
      Type: "BitBucket" or "Github"
      Find: String to look for in the .gitconfig to determine whether repo is this type
      Replace: *OPTIONAL* when finding the string, optional ability to replace 

    Example:
      @{
        Name = 'BitBucketCustom'
        Type = 'BitBucket'
        Find = 'ssh://git@git.companyname.com:7999'
        Replace = 'https://git.companyname.com'
      }

.EXAMPLE
    PS C:\SomeGitRepo> Invoke-GitOpen
    Will open up a web browser to the "SomeGitRepo" remote.


.EXAMPLE
    PS C:\SomeGitRepo> $companyRepoType = @{
        Name = 'BitBucketCustom'
        Type = 'BitBucket'
        Find = 'ssh://git@git.companyname.com:7999'
        Replace = 'https://git.companyname.com'
      }
    PS C:\SomeGitRepo> Invoke-GitOpen -CustomRepoTypes @($companyRepoType)

    My company uses SSH for git operations. This configuration will find the 
    ssh configuration for my company repositories and then replace that ssh remote
    configuration with the https remote URL.
#>
function Invoke-GitOpen {
  [CmdletBinding()]
  param(
    # open the pull request page
    [Parameter()]
    [Switch]$PR,

    [Parameter()]
    [Array]$CustomRepoTypes
  )

  # TO DO
  # Make this more dynamic. We should be able to find this
  # if the shell is in a repo
  $configPath = './.git/config'

  <#
    DEBUG
    $urlRaw = 'url = ssh://git@git.companyname.com:7999/bbproject/bbrepo.git'
    $urlRaw = 'url = https://github.com/nhudacin/git-open.git'
  #>
  
  # pull the url out of the .gitconfig, clean it up a little
  $urlRaw = Get-Content -Path $configPath | Where-Object { $_ -match 'url =' } | Select-Object -First 1
  if ($urlRaw -match '(?<=url = )(.*)(?=\.git)' ) {
    $sanitizedUrl = $Matches[1]
  }

  # gotta stop here if we didn't snag a url
  if (-not $sanitizedUrl) {
    throw 'Couldn''t get a url from the git config'
  }

  # get the repo name 
  # sanitizedUrl = ssh://git@git.companyname.com:7999/bbproject/bbrepo
  # --------------------------------------------------------------^
  $repoName =  Split-Path -Leaf $sanitizedUrl
  
  # we need the Github Organization || BitBucket Project
  # sanitizedUrl = ssh://git@git.companyname.com:7999/bbproject/bbrepo
  # ------------------------------------------------------^
  $repoParent = Split-Path -Leaf $(Split-Path -Parent $sanitizedUrl)

  <#
    TO DO: Move this hostname section to it's own function

    The Find & Replace functionality inside $customRepoTypes must be
    run in oder to find the correct hostname/url

    $sanitizedURL can be changed during this process!

    At the end of this block --> we should also know the $repoType
    in order to construct the url query
  #>

  # get the host name
  # take into consideration the requirement to support custom urls
  [array]$repoTypes = Get-DefaultRepoTypes
  
  if ($customRepoTypes) {
    # TO DO: Validate input
    foreach ($customDataType in $customRepoTypes) {
      $repoTypes += $customRepoTypes
    }
  }

  # find the url type & run any customizations
  foreach($repoType in $repoTypes) {
    if ($sanitizedUrl.Contains($repoType.Find)) {
      if ($repoType.Replace) {
        $sanitizedUrl = $sanitizedUrl.Replace($repoType.Find,$repoType.Replace)
      }
      break
    }

    # no repoType found. do NOT be fooled with $repoType being populated
    $repoType = $null
  }

  # FINALLY - get the repoUrlBase
  $repoUrlBase = $sanitizedUrl.Remove($sanitizedUrl.IndexOf("/$repoParent/$repoName")).TrimEnd('/')

  # now that we know all of the parts, it's time to re-assemble them depending on the
  # repo type. 
  $formattedUrlBase = switch($repoType.Type) {
    'BitBucket' { 
      "$repoUrlBase/projects/$repoParent/repos/$repoName"
    }
    default {
      "$repoUrlBase/$repoParent/$repoName"
    }
  }
  
  # PR is easy! no more processing needed
  if ($PR) {    
    # stupid var name - I've been burned in posh using "special" variable names like $args
    $startArgz = switch($repoType.Type) {
      'BitBucket' {
        "$formattedUrlBase/pull-requests"
      }
      default {
        "$formattedUrlBase/pulls"
      }
    }
  }

  # TO DO:
  # add issues $startAgz

  # if we don't have the args set then we have a little more digging to do
  # get the branch and open up to the branch tree
  if (-not $startArgz) {
    # get the ref (current branch)
    <#
    DEBUG
      $ref = "ref: refs/heads/nuix_develop"
    #>
    $ref = Get-Content -Path $(Join-Path $(Split-Path -Parent $configPath) 'HEAD')
    
    # will be in this format:
    # ref: refs/heads/nuix_develop
    #
    # grab the branch (end)
    $branchName = $ref.Substring($ref.LastIndexOf('/') + 1)
    
    $startArgz = switch($repoType.Type) {
      'BitBucket' {
        "$formattedUrlBase/browse?at=refs%2Fheads%2F$branchName"
      }
      default {
        "$formattedUrlBase/tree/$branchName"
      }
    }
  }

  # open 'er up!
  Start-Process $startArgz
}