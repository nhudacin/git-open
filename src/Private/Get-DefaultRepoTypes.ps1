function Get-DefaultRepoTypes {
  [CmdletBinding()]
  param()

  $defaultRepoTypes = @(
    @{
      Name            = 'GitHubStandard'
      Type            = 'GitHub'
      Find            = 'github'
      Replace         = $null
      UrlBase         = 'https://github.com'
      BrowseUrlFormat = '$urlBase/$orgName/$repoName/tree/$branchName'
      PRUrlFormat     = '$urlBase/$orgName/$repoName/pulls'
    },
    @{
      Name            = 'AzureDevopsStandard'
      Type            = 'AzureDevops'
      Find            = 'dev.azure.com'
      UrlBase         = 'https://dev.azure.com'
      Replace         = $null
      BrowseUrlFormat = '$urlBase/$orgName/$projectName/_git/$($repoName)?version=GB$branchName'
      PRUrlFormat     = '$urlBase/$orgName/$projectName/_git/$repoName/pullrequests'
    },
    @{
      Name            = 'BitBucketStandard'
      Type            = 'BitBucket'
      Find            = 'bitbucket.org'
      Replace         = $null
      UrlBase         = 'https://bitbucket.org'
      BrowseUrlFormat = '$urlBase/projects/$projectName/repos/$repoName/browse?at=refs%2Fheads%2F$branchName'
      PRUrlFormat     = '$urlBase/projects/$projectName/repos/$repoName/pull-requests'
    }
  )

  $defaultRepoTypes
}