#!/bin/bash

###
#
#            Name:  uninstaller-template.sh
#     Description:  A template script to assist with the uninstallation of
#                   macOS products where the vendor has missing or incomplete
#                   removal solutions. Attempts vendor uninstall by targeting
#                   all known paths for their scripts, quits all running target
#                   processes, unloads all associated launchd tasks, disables
#                   kernel extensions, then removes all associated files.
#                   https://github.com/palantir/mac-jamf/tree/master/scripts/script-templates/uninstaller-template
#         Created:  2017-10-23
#   Last Modified:  2018-11-28
#         Version:  1.2.2
#
#
# Copyright 2017 Palantir Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
###



########## variable-ing ##########



scriptName=$("/usr/bin/basename" "$0")
loggedInUser=$("/usr/bin/stat" -f%Su "/dev/console")
loggedInUserHome=$("/usr/bin/dscl" . -read "/Users/$loggedInUser" NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
loggedInUserUID=$("/usr/bin/id" -u "$loggedInUser")
# A list of full file paths to vendor-provided uninstall scripts.
# Use "$loggedInUserHome" for the current user's home folder path.
# If the vendor did not provide an uninstaller, comment this array out.
vendorUninstallerPaths=(
  "/path/to/vendor_uninstaller_script1"
  "/path/to/vendor_uninstaller_script2"
)
# a list of application processes to target for quit and login item removal
# names should match what is displayed for the process in Activity Monitor
# (e.g. "Chess", not "Chess.app")
processNames=(
  "Process Name 1"
  "Process Name 2"
)
# a list of full file paths to target for launchd unload and deletion
resourceFiles=(
  "/path/to/file1"
  "/path/to/file2"
)
currentProcesses=$("/bin/ps" aux)
launchAgentCheck=$("/bin/launchctl" asuser "$loggedInUserUID" "/bin/launchctl" list)
launchDaemonCheck=$("/bin/launchctl" list)



########## function-ing ##########



# run vendor uninstaller if present
run_vendor_uninstaller () {
  for vendorUninstaller in "${vendorUninstallerPaths[@]}"; do
    if [[ -e "$vendorUninstaller" ]]; then
      # This syntax will differ depending on how the uninstall script functions.
      # In this example, the vendor uninstaller is a Bash script executed
      # without arguments, but some vendors may use their own command-line
      # tools, custom flags, or other workflows to accomplish this task (that's
      # why this script exists!), so make any necessary changes to the below
      # command.
      "/bin/bash" "$vendorUninstaller"
      "/bin/echo" "Ran vendor uninstaller at $vendorUninstaller."
    else
      "/bin/echo" "No uninstaller found at $vendorUninstaller."
    fi
  done
}


# quit target processes, remove associated login items
quit_processes () {
  for process in "${processNames[@]}"; do
    if [[ $("/bin/echo" "$currentProcesses" | "/usr/bin/grep" "$process" | "/usr/bin/grep" -v "grep") = "" ]]; then
      "/bin/echo" "$process not running."
    else
      "/bin/launchctl" asuser "$loggedInUserUID" "/usr/bin/osascript" -e "tell application \"$process\" to quit"
      "/usr/bin/osascript" -e "tell application \"System Events\" to delete every login item whose name is \"$process\""
      "/bin/echo" "Quit $process, removed from login items if present."
    fi
  done
}


# remove all remaining resource files
delete_files () {
  "/bin/echo" "Removing files..."
  for targetFile in "${resourceFiles[@]}"; do
    # if file exists
    if [[ -e "$targetFile" ]]; then
      # if file is a plist
      if [[ "$targetFile" == *".plist" ]]; then
        # if plist is loaded as LaunchAgent or LaunchDaemon, unload it
        justThePlist=$("/usr/bin/basename" "$targetFile" | "/usr/bin/awk" -F.plist '{print $1}')
        if [[ "$launchAgentCheck" =~ "$justThePlist" ]]; then
          "/bin/launchctl" asuser "$loggedInUserUID" "/bin/launchctl" unload "$targetFile"
          "/bin/echo" "Unloaded LaunchAgent at $targetFile."
        elif [[ "$launchDaemonCheck" =~ "$justThePlist" ]]; then
          "/bin/launchctl" unload "$targetFile"
          "/bin/echo" "Unloaded LaunchDaemon at $targetFile."
        fi
      fi
      # disable kexts, delete all other file types
      if [[ "$targetFile" == *".kext" ]]; then
        appKextKillPath="/tmp/$scriptName"
        "/bin/mkdir" -p "$appKextKillPath"
        "/bin/mv" "$targetFile" "$appKextKillPath"
        "/bin/echo" "Moved $targetFile to $appKextKillPath. File will be deleted on subsequent restart."
      else
        "/bin/rm" -rf "$targetFile"
        "/bin/echo" "Removed $targetFile."
      fi
    fi
  done
}



########## main process ##########



# runs each function as needed (skips if arrays are empty)
if [[ "$vendorUninstallerPaths" != "" ]]; then
  run_vendor_uninstaller
fi


if [[ "$processNames" != "" ]]; then
  quit_processes
fi


if [[ "$resourceFiles" != "" ]]; then
  delete_files
fi



exit 0
