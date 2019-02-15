function Get-DefaultRepoTypes {
  [CmdletBinding()]
  param()

  $defaultRepoTypes = @(
    @{
      Name = 'GitHubStandard'
      Type = 'GitHub'
      Find = 'github'
      Replace = $null
    }
  )

  $defaultRepoTypes
}