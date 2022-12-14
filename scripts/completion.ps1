Invoke-Command -ScriptBlock {
  $generatedDir = "${PSScriptRoot}\..\generated"

  function SetupAll {
    SetupKubectl
    UpdateCommandCompletion -CommandName 'k3d' > $null
  }

  function SetupKubectl {
    $result = UpdateCommandCompletion -CommandName 'kubectl'
    if ($result.Exists) {
      Set-Alias -Name 'k' -Value 'kubectl' -Scope 'Global'
    }
    if ($result.Updated) {
      $script = Get-Content -Path $result.FilePath
      $script = $script.Replace('__kubectl_', '__kalias_')
      $script = $script.Replace('kubectl', 'k')
      $script | Add-Content -Path $result.FilePath
    }
  }

  function UpdateCommandCompletion {
    param (
      [string]$CommandName
    )

    $result = [pscustomobject]@{
      Exists = $false;
      Updated = $false;
      FilePath = $null
    }

    $completionPath = "${generatedDir}\${commandName}.ps1"
    $result.FilePath = $completionPath

    $command = Get-Command -Name $commandName -ErrorAction 'SilentlyContinue'
    if ($command -ne $null) {
      $result.Exists = $true
      $recreate = $true
      $completionFile = Get-Item -Path $completionPath -ErrorAction 'SilentlyContinue'
      if ($completionFile -ne $null) {
        $commandTime = Get-ItemProperty -Path $command.Source -Name 'LastWriteTime'
        $recreate = $completionFile.LastWriteTime -lt $commandTime.LastWriteTime
      }
      if ($recreate) {
        Invoke-Expression -Command "${commandName} completion powershell" | Set-Content -Path $completionPath
        $result.Updated = $true
      }
    } elseif (Test-Path -Path $completionPath -PathType 'Leaf') {
      Remove-Item -Path $completionPath
    }

    return $result
  }

  SetupAll
}
