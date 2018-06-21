#!/bin/bash

###
#
#            Name:  Uninstall Pulse Secure.sh
#     Description:  Uninstalls Junos Pulse and Pulse Secure. Quits all running
#                   processes, attempts vendor uninstall by targeting all known
#                   paths for the shell script, unloads all associated launchd
#                   tasks, then removes all associated files.
#                   Based on uninstaller-template (see script-templates).
#         Created:  2016-09-20
#   Last Modified:  2018-06-20
#         Version:  3.1.1
#
#
# Copyright 2016 Palantir Technologies, Inc.
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



loggedInUser=$("/usr/bin/stat" -f%Su "/dev/console")
loggedInUserHome=$("/usr/bin/dscl" . -read "/Users/$loggedInUser" NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
loggedInUserUID=$("/usr/bin/id" -u "$loggedInUser")
# A list of full file paths to vendor-provided uninstall scripts.
# Use "$loggedInUserHome" for the current user's home folder path.
# If the vendor did not provide an uninstaller, comment this array out.
vendorUninstallerPath=(
  "/Library/Application Support/Juniper Networks/Junos Pulse/Uninstall.app/Contents/Resources/uninstall.sh"
  "/Library/Application Support/Pulse Secure/Pulse/Uninstall.app/Contents/Resources/uninstall.sh"
)
# a list of application processes to target for quit and login item removal
# names should match what is displayed for the process in Activity Monitor
# (e.g. "Chess", not "Chess.app")
processName=(
  "Junos Pulse"
  "Pulse Secure"
)
# a list of full file paths to target for launchd unload and deletion
resourceFiles=(
  "/Applications/Junos Pulse.app"
  "/Applications/Pulse Secure.app"
  "/Library/Application Support/Juniper Networks/Junos Pulse"
  "/Library/Application Support/Pulse Secure"
  "/Library/LaunchAgents/net.pulsesecure.pulsetray.plist"
  "/Library/LaunchDaemons/net.pulsesecure.AccessService.plist"
  "/Library/LaunchDaemons/net.pulsesecure.UninstallPulse.plist"
)
currentProcesses=$("/bin/ps" aux)
launchAgentCheck=$("/bin/launchctl" asuser "$loggedInUserUID" "/bin/launchctl" list)
launchDaemonCheck=$("/bin/launchctl" list)



########## function-ing ##########



# run vendor uninstaller if present
run_vendor_uninstaller () {
  for vendorUninstaller in "${vendorUninstallerPath[@]}"; do
    if [[ -e "$vendorUninstaller" ]]; then
      # This syntax will differ depending on how the uninstall script functions.
      # See uninstaller template for guidance on modifying this section.
      "/bin/sh" "$vendorUninstaller"
      "/bin/echo" "Ran vendor uninstaller at $vendorUninstaller."
    else
      "/bin/echo" "No uninstaller found at $vendorUninstaller."
    fi
  done
}


# quit target processes, remove associated login items
quit_processes () {
  for process in "${processName[@]}"; do
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
if [[ "$vendorUninstallerPath" != "" ]]; then
  run_vendor_uninstaller
fi


if [[ "$processName" != "" ]]; then
  quit_processes
fi


if [[ "$resourceFiles" != "" ]]; then
  delete_files
fi



exit 0
