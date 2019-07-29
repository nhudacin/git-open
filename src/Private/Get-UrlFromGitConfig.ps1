function Get-UrlFromGitConfig {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
      [string]$ConfigPath
  )

  <#
    DEBUG
    $urlRaw = 'url = ssh://git@git.companyname.com:7999/bbproject/bbrepo.git'
    $urlRaw = 'url = https://github.com/nhudacin/git-open.git'
  #>

  # pull the url out of the .gitconfig, clean it up a little
  $urlRaw = Get-Content -Path $ConfigPath | Where-Object { $_ -match 'url =' } | Select-Object -First 1

  if ($urlRaw -match '(?<=url = )(.*)' ) {
    $sanitizedUrl = $Matches[1]

    $sanitizedUrl = $sanitizedUrl.Trim()

    if ($sanitizedUrl.EndsWith('.git')) {
      $sanitizedUrl = $sanitizedUrl.TrimEnd('.git')
    }
  }

  # gotta stop here if we didn't snag a url
  if (-not $sanitizedUrl) {
    throw 'Couldn''t get a url from the git config'
  }

  $sanitizedUrl
}