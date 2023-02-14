Invoke-Command -ScriptBlock {
  $rootDir = "${PSScriptRoot}\.."

  function SetupAll {
    UpdateCompletionScript -CommandName 'kubectx' -TemplateName 'kube-ctx-ns' > $null
    UpdateCompletionScript -CommandName 'kubens' -TemplateName 'kube-ctx-ns' > $null
  }

  function UpdateCompletionScript {
    param (
      [string]$CommandName,
      [string]$TemplateName
    )

    $result = [pscustomobject]@{
      Exists = $false;
      Updated = $false;
      FilePath = $null
    }

    $destCompletionPath = "${rootDir}\generated\${CommandName}.ps1"
    $result.FilePath = $completionPath

    $command = Get-Command -Name $CommandName -ErrorAction 'SilentlyContinue'
    if ($command -ne $null) {
      $result.Exists = $true
      $recreate = $true
      $destCompletionFile = Get-Item -Path $destCompletionPath -ErrorAction 'SilentlyContinue'
      $srcCompletionPath = "${rootDir}\templates\completion\${TemplateName}.ps1"
      if ($destCompletionFile -ne $null) {
        $sourceCompletionFileTime = Get-ItemProperty -Path $srcCompletionPath -Name 'LastWriteTime'
        $recreate = $destCompletionFile.LastWriteTime -lt $sourceCompletionFileTime.LastWriteTime
      }
      if ($recreate) {
        $script = Get-Content -Path $srcCompletionPath
        $script = $script.Replace('COMMAND_NAME_TOKEN', $CommandName)
        $script | Set-Content -Path $destCompletionPath
      }
    } elseif (Test-Path -Path $destCompletionPath -PathType 'Leaf') {
      Remove-Item -Path $destCompletionPath
    }

    return $result
  }

  SetupAll
}
