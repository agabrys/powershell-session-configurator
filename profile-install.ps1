if (Invoke-Command -ScriptBlock {
  $command = ". `"${PSScriptRoot}\configure.ps1`""

  $result = Select-String -Pattern $command -Path $profile -SimpleMatch

  if ($result -ne $null) {
    Write-Host 'Skipping installation. The configure.ps1 script is already executed by the user profile file'
    return $false
  }

  Write-Host 'Installing...'
  Write-Host 'Modyfing the user profile file...'
  "`n${command}" | Add-Content -Path $profile
  return $true
}) {
  Write-Host 'Configuring the current PowerShell session...'
  . "${PSScriptRoot}\configure.ps1"
  Write-Host 'Installed sucessfully'
}
