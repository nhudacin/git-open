$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'
$baseDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $(Split-Path -Parent $baseDir)
$srcPath = Join-Path $repoRoot 'src'
$buildDir = Join-Path $repoRoot '.ignore/build/git-open'

if (Test-Path $buildDir) {
    $null = Remove-Item $buildDir -Recurse -Force -Verbose
}

$null = New-Item -Path $buildDir -ItemType Directory -Verbose

# these are all the files that should not be packaged. 
$packageExclusions = @(
  'Private/*.tests.ps1',
  'Public/*.tests.ps1',
  '*.tests.ps1'
)

$files = Get-ChildItem -Path $srcPath -Exclude $packageExclusions -Recurse

# move the new files over to the tempLocation
# parent directories must be created in the tempLocation
# if they do not exist
foreach($file in $files) {

  # pull out the relative path so that the directory structure remains consistent
  $relativePath = $file.FullName.Replace($srcPath,'').Trim()
  
  $sourcePath = Join-Path $srcPath $relativePath
  $targetPath = Join-Path $buildDir $relativePath

  # if parent path not exists, create it!
  if (-not ( Test-Path $(Split-Path $targetPath -parent))) {
    $null = New-Item -ItemType Container -Path $(Split-Path $targetPath -Parent) -Verbose
  }

  # copy the file over
  Copy-Item -Path $sourcePath -Destination $targetPath -Verbose
}
