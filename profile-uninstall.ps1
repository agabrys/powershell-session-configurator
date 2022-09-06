Invoke-Command -ScriptBlock {
  $command = ". `"${PSScriptRoot}\configure.ps1`""

  $originalScript = Get-Content -Path $profile
  $index = $originalScript.IndexOf($command)
  if ($index -eq -1) {
    Write-Host 'Skipping uninstallation. The configure.ps1 script is not executed by the user profile file'
    return
  }

  [System.Collections.ArrayList]$modifiedScript = @()
  foreach ($line in $originalScript) {
    $modifiedScript += $line
  }
  $modifiedScript.RemoveAt($index)
  $removeEmptyLineBefore = $index -gt 0 -and $originalScript.Get($index - 1).Trim().Length -eq 0
  if ($removeEmptyLineBefore) {
    $modifiedScript.RemoveAt($index - 1)
  }

  Write-Host 'Uninstalling...'
  Write-Host 'Modyfing the user profile file...'
  $modifiedScript | Out-String | Set-Content -Path $profile -NoNewline
  Write-Host 'Uninstalled sucessfully'
  Write-Host 'Cleaning PowerShell sessions is unsupported'
  Write-Host 'Restart them to see the uninstallation effects'
}
