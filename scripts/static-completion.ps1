Invoke-Command -ScriptBlock {
  $rootDir = "${PSScriptRoot}\.."

  function SetupAll {
    UpdateCompletionScript -CommandName 'kubectx' > $null
  }

  function UpdateCompletionScript {
    param (
      [string]$CommandName
    )

    $result = [pscustomobject]@{
      Exists = $false;
      Updated = $false;
      FilePath = $null
    }

    $destCompletionPath = "${rootDir}\generated\${commandName}.ps1"
    $result.FilePath = $completionPath

    $command = Get-Command -Name $commandName -ErrorAction 'SilentlyContinue'
    if ($command -ne $null) {
      $result.Exists = $true
      $recreate = $true
      $destCompletionFile = Get-Item -Path $destCompletionPath -ErrorAction 'SilentlyContinue'
      $srcCompletionPath = "${rootDir}\static\completion\${commandName}.ps1"
      if ($destCompletionFile -ne $null) {
        $sourceCompletionFileTime = Get-ItemProperty -Path $srcCompletionPath -Name 'LastWriteTime'
        $recreate = $destCompletionFile.LastWriteTime -lt $sourceCompletionFileTime.LastWriteTime
      }
      if ($recreate) {
        Copy-Item -Path $srcCompletionPath -Destination $destCompletionPath
        $result.Updated = $true
      }
    } elseif (Test-Path -Path $destCompletionPath -PathType 'Leaf') {
      Remove-Item -Path $destCompletionPath
    }

    return $result
  }

  SetupAll
}
