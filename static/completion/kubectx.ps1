
# Copyright 2023 Adam Gabryś
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script based on the kubectl PowerShell completion

function __kubectx_debug {
  if ($env:BASH_COMP_DEBUG_FILE) {
    "${args}" | Out-File -Append -FilePath "${env:BASH_COMP_DEBUG_FILE}"
  }
}

filter __kubectx_escapeStringWithSpecialChars {
  $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&', '`$&'
}

Register-ArgumentCompleter -CommandName 'kubectx' -ScriptBlock {
  param(
    $WordToComplete,
    $CommandAst,
    $CursorPosition
  )

  # Get the current command line and convert into a string
  $command = $CommandAst.CommandElements
  $command = "${command}"

  __kubectx_debug ''
  __kubectx_debug '========= starting completion logic =========='
  __kubectx_debug "WordToComplete: ${WordToComplete} Command: ${command} CursorPosition: ${CursorPosition}"

  # The user could have moved the cursor backwards on the command-line
  # We need to trigger completion from the $CursorPosition location, so we need
  # to truncate the command-line ($command) up to the $CursorPosition location
  # Make sure the $command is longer then the $CursorPosition before we truncate
  # This happens because the $command does not include the last space
  if ($command.Length -gt $CursorPosition) {
    $command = $command.Substring(0, $CursorPosition)
  }
  __kubectx_debug "Truncated command: ${command}"

  $program, $arguments = $command.Split(' ', 2)
  if ($arguments -eq $null) {
    $arguments = @()
    __kubectx_debug "No arguments"
  } else {
    $arguments = $arguments.Split(' ')
    __kubectx_debug "Arguments: ${arguments}"
  }

  # When at least one agrument is passed, we should not provide more completions
  if ($WordToComplete -eq '' -and $arguments.Length -gt 0) {
    __kubectx_debug "Only one argument is supported. No more completions"
    return
  }

  # We cannot use $WordToComplete because it has the wrong values
  # if the cursor was moved so use the last argument
  if ($WordToComplete -ne '') {
    $WordToComplete = $arguments[-1]
  }
  __kubectx_debug "New WordToComplete: ${WordToComplete}"

  __kubectx_debug "Calling ${program} to get available contexts"
  # Call the command store the output in $out and redirect stderr and stdout to null
  # $values is an array contains each line per element
  Invoke-Expression -OutVariable values "$program" 2>&1 | Out-Null
  __kubectx_debug "The completions are: ${values}"

  # Filter the result
  $values = $values | Where-Object {
    $_ -like "${WordToComplete}*"
  }

  # Get the current mode
  $mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq 'Tab'}).Function
  __kubectx_debug "Mode: $mode"

  $values | ForEach-Object {
    # PowerShell supports three different completion modes
    # - TabCompleteNext (default windows style - on each key press the next option is displayed)
    # - Complete (works like bash)
    # - MenuComplete (works like zsh)
    # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

    # CompletionResult Arguments:
    # 1) CompletionText text to be used as the auto completion result
    # 2) ListItemText   text to be displayed in the suggestion list
    # 3) ResultType     type of completion result
    # 4) ToolTip        text for the tooltip with details about the object

    # kubectx supports only one parameter, so we do not need to add additional spaces at the end
    # The same completion result is returned for all modes
    [System.Management.Automation.CompletionResult]::new(
      $($_ | __kubectl_escapeStringWithSpecialChars),
      $_,
      'ParameterValue',
      $_
    )
  }
}
