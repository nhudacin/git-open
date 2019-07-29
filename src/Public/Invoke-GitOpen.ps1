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
      UrlBase: The start of the URL for your git config. Example: "https://dev.azure.com"
      BrowseUrlFormat: The format of the browse URL. This varies by source control type
      PRUrlFormat: The format of the PR URL. This varies by source control type

    Example:
      @{
        Name            = 'BitBucketCustom'
        Type            = 'BitBucket'
        Find            = 'ssh://git@git.companyname.com:7999'
        Replace         = 'https://git.companyname.com'
        UrlBase         = 'https://git.companyname.com'
        BrowseUrlFormat = '$urlBase/projects/$projectName/repos/$repoName/browse?at=refs%2Fheads%2F$branchName'
        PRUrlFormat     = '$urlBase/projects/$projectName/repos/$repoName/pull-requests'
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
        UrlBase         = 'https://git.companyname.com'
        BrowseUrlFormat = '$urlBase/projects/$projectName/repos/$repoName/browse?at=refs%2Fheads%2F$branchName'
        PRUrlFormat     = '$urlBase/projects/$projectName/repos/$repoName/pull-requests'
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

  $configPath = Find-GitConfigPath

  $sanitizedUrl = Get-UrlFromGitConfig -ConfigPath $configPath

  # get the $urlBase 
  # take into consideration the requirement to support custom urls
  [array]$repoTypes = Get-DefaultRepoTypes
  
  if ($customRepoTypes) {
    # TO DO: Validate input
    foreach ($customDataType in $customRepoTypes) {
      $repoTypes += $customRepoTypes
    }
  }

  # find the repo type by comparing the URL in the
  # gitconfig with default & custom URL
  foreach($repoType in $repoTypes) {
    if ($sanitizedUrl.Contains($repoType.Find)) {
      # run any customizations with config.find & config.replace
      if ($repoType.Replace) {
        $sanitizedUrl = $sanitizedUrl.Replace($repoType.Find,$repoType.Replace)
      }
      break
    }

    # no repoType found. do NOT be fooled with $repoType being populated
    $repoType = $null
  }

  # get the project/org/repo values
  
  # get the repo name from the last piece of the sanitizedUrl
  # sanitizedUrl = ssh://git@git.companyname.com:7999/bbproject/bbrepo
  # --------------------------------------------------------------^
  $repoName =  Split-Path -Leaf $sanitizedUrl
  
  # if this is Azure Devops or Github, we need to get the organization
  if ($repoType.Type -eq 'GitHub') {
    $orgName = Split-Path -Leaf $(Split-Path -Parent $sanitizedUrl)
  }

  if ($repoType.Type -eq 'AzureDevops') {    
    $orgName = Split-Path -Leaf $(Split-Path -Parent $( Split-Path -Parent $(Split-Path -Parent $sanitizedUrl)))
    $projectName = Split-Path -Leaf $( Split-Path -Parent $(Split-Path -Parent $sanitizedUrl))
  }

  if ($repoType.Type -eq 'BitBucket') {
    $projectName = Split-Path -Leaf $(Split-Path -Parent $sanitizedUrl)
  }

  if ($repoType.UrlBase) {
    $urlBase = $repoType.UrlBase
  }
  else {
    # legacy code
    Write-Warning "Please use the new property UrlBase in your custom repo type config. This fallback will be removed in future versions."
    $urlBase = $sanitizedUrl.Remove($sanitizedUrl.IndexOf("/$projectName/$repoName")).TrimEnd('/')
  }
  
  # TO DO:
  # switch statement
  # add issues $startAgz
  if ($PR) {
    if ($repoType.PRUrlFormat) {
      $PRUrlFormat = $repoType.PRUrlFormat
    }
    else {
      Write-Warning "Please use the new property PRUrlFormat in your custom repo type config. This fallback will be removed in future versions."

      $PRUrlFormat = switch ($repoType.Type) {
        'Bitbucket' { '$urlBase/projects/$projectName/repos/$repoName/pull-requests' }
        default { '$urlBase/$orgName/$repoName/pulls' }
      
      }
    }
    $startArgz = $ExecutionContext.InvokeCommand.ExpandString($PRUrlFormat)    
  }
  else {
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

    if ($repoType.BrowseUrlFormat) {
      $browseUrlFormat = $repoType.BrowseUrlFormat
    }
    else {
      Write-Warning "Please use the new property BrowseUrlFormat in your custom repo type config. This fallback will be removed in future versions."

      $browseUrlFormat = switch ($repoType.Type) {
        'Bitbucket' { '$urlBase/projects/$projectName/repos/$repoName/browse?at=refs%2Fheads%2F$branchName' }
        default { '$urlBase/$orgName/$repoName/tree/$branchName' }
      }
    }

    $startArgz = $ExecutionContext.InvokeCommand.ExpandString($browseUrlFormat)
  }

  # open 'er up!
  Start-Process $startArgz
}