<#

#>
function Invoke-GitOpen {
  [CmdletBinding()]
  param(
      # open the pull request page
      [Parameter()]
      [Switch]$PR
  )

  # the url is in the config
  $config = Get-Content -Path './.git/config' | Where-Object { $_ -match 'url =' }

  # parse it out
  if ($config -match '(?<=url = )(.*)(?=\.git)' ) {
      $url_base = $Matches[1]
  }
  else {
      Throw 'Couldn''t get a url from the git config'
  }

  if ($PR) {
    $start_arg = "$url_base/pulls"
  }

  # if the PR switch is not used
  # get the branch and open up to the branch tree
  if (-not $start_arg) {
      # get the ref (current branch)
      $ref = Get-Content -Path './.git/HEAD'

      # will be in this format:
      # ref: refs/heads/nuix_develop
      #
      # grab the branch (end)
      $ref = $ref.Substring($ref.LastIndexOf('/') + 1)

      $start_arg = "$url_base/tree/$ref"

      # for bitbucket support
      # if ($bitBucket) {
      #     $start_arg = "$url_base/browse?at=refs%2Fheads%2F$ref"
      # }
  }
  
  # open 'er up!
  Start-Process $start_arg
}