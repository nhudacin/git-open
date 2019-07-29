function Find-GitConfigPath {
  [CmdletBinding()]
  param()

  # TO DO
  # Make this more dynamic. We should be able to find this
  # if the shell is inside a repo
  $configPath = './.git/config'

  $configPath
}