# if debugging, set moduleRoot to current directory
if ($MyInvocation.MyCommand.Path) {
  $moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path
}else {
  $moduleRoot = $PWD.Path
}

# Load up the dependent functions
"$moduleRoot\Public\*.ps1",
"$moduleRoot\Private\*.ps1" |
  Resolve-Path |
      Where-Object { -not ($_.ProviderPath.ToLower().Contains('.tests.')) } |
        ForEach-Object { . $_.ProviderPath }

Export-ModuleMember Invoke-GitOpen
New-Alias -Name 'git-open' -Value Invoke-GitOpen