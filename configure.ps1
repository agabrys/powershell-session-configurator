if (!(Test-Path -Path "${PSScriptRoot}\generated" -PathType 'Container')) {
  New-Item -Path "${PSScriptRoot}\generated" -ItemType 'Directory' > $null
}

foreach ($fileName in Get-ChildItem -Path "${PSScriptRoot}\scripts" -Filter '*.ps1' -Name -File) {
  . "${PSScriptRoot}\scripts\${fileName}"
}

foreach ($fileName in Get-ChildItem -Path "${PSScriptRoot}\generated" -Filter '*.ps1' -Name -File) {
  . "${PSScriptRoot}\generated\${fileName}"
}
