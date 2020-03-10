function Find-GitConfigPath {
  [CmdletBinding()]
  param()

  $currentLocation = (Get-Location).Path
  $expectedConfigName = '.git/config'
  
  # will look uproot from the current directory to find the 
  # git config path. Max 10 folders deep
  for($i=0;$i -le 9; $i++) {
    # when you split path on the drive, you get a $null value back!
    # try it: Split-Path -Parent "C:\"
    if (-not $currentLocation) {
      break
    }

    Write-Verbose "Looking for a git config file in $currentLocation"
    if (Test-Path $(Join-Path $currentLocation $expectedConfigName)) {
      $configPath = Join-Path $currentLocation $expectedConfigName
    }
    else {
      $currentLocation = Split-Path -Parent $currentLocation
    }
  }

  if (-not $configPath) {
    throw "Could not find git config file"
  }

  $configPath
}