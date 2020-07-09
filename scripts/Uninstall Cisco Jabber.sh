#!/bin/bash
# shellcheck disable=SC2034

###
#
#            Name:  Uninstall Cisco Jabber.sh
#     Description:  Uninstalls Cisco Jabber.
#                   Attempts vendor uninstall by running all provided
#                   uninstallation commands, quits all running target processes,
#                   unloads all associated launchd tasks, disables kernel
#                   extensions, then removes all associated files.
#                   Based on uninstaller-template:
#                   https://github.com/palantir/jamf-pro-scripts/tree/master/scripts/script-templates/uninstaller-template
#         Created:  2017-10-23
#   Last Modified:  2020-07-08
#         Version:  1.3.2pal1
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



# ENVIRONMENT VARIABLES (leave as-is):
scriptName=$(/usr/bin/basename "$0")
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
# For any file paths used later in this script, use "$loggedInUserHome" for the
# current user's home folder path.
# Don't just assume the home folder is at /Users/$loggedInUser.
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
loggedInUserUID=$(/usr/bin/id -u "$loggedInUser")
currentProcesses=$(/bin/ps aux)
launchAgentCheck=$(/bin/launchctl asuser "$loggedInUserUID" /bin/launchctl list)
launchDaemonCheck=$(/bin/launchctl list)


# UNINSTALLER COMMANDS (update or comment out arrays as needed):
# A list of full commands to execute vendor-provided uninstallation workflows.
# Syntax will differ depending on how the uninstall script functions. In the
# below examples, the vendor uninstallers are shell scripts executed without
# arguments, but some vendors may use their own command-line tools, custom
# flags, or other workflows to accomplish this task (that's why this script
# exists!), so make any necessary changes to the below commands.
# If the vendor did not provide an uninstaller, comment this array out.
vendorUninstallerCommands=(
#  "sh /path/to/vendor_uninstaller_command1.sh"
#  "sh /path/to/vendor_uninstaller_command2.sh"
)


# PROCESSES:
# A list of application processes to target for quit and login item removal.
# Names should match what is displayed for the process in Activity Monitor
# (e.g. "Chess", not "Chess.app").
# If no processes need to be quit, comment this array out.
processNames=(
  "Cisco Jabber"
)


# FILE PATHS:
# A list of full file paths to target for launchd unload and deletion.
# If no files need to be manually deleted, comment this array out.
resourceFiles=(
  "/Applications/Cisco Jabber.app"
  "/Library/Cisco/Jabber"
  "$loggedInUserHome/Library/Application Support/Cisco/Unified Communications/Jabber"
  "$loggedInUserHome/Library/Caches/com.cisco.Jabber"
  "$loggedInUserHome/Library/Preferences/com.cisco.Jabber.plist"
)



########## function-ing ##########



# Run vendor uninstaller commands.
# This will fail if a command references nonexistent scripts or binaries.
function run_vendor_uninstallers {
  for vendorUninstaller in "${vendorUninstallerCommands[@]}"; do
    $vendorUninstaller
  done
}


# Quit target processes and remove associated login items.
function quit_processes {
  for process in "${processNames[@]}"; do
    if echo "$currentProcesses" | /usr/bin/grep -q "$process"; then
      /bin/launchctl asuser "$loggedInUserUID" /usr/bin/osascript -e "tell application \"$process\" to quit"
      /usr/bin/osascript -e "tell application \"System Events\" to delete every login item whose name is \"$process\""
      echo "Quit $process, removed from login items if present."
    else
      echo "$process not running."
    fi
  done
}


# Remove all remaining resource files.
function delete_files {
  for targetFile in "${resourceFiles[@]}"; do
    # if file exists
    if [[ -e "$targetFile" ]]; then
      # if file is a plist
      if [[ "$targetFile" == *".plist" ]]; then
        # if plist is loaded as LaunchAgent or LaunchDaemon, unload it
        justThePlist=$(/usr/bin/basename "$targetFile" | /usr/bin/awk -F.plist '{print $1}')
        if [[ "$launchAgentCheck" =~ $justThePlist ]]; then
          /bin/launchctl asuser "$loggedInUserUID" /bin/launchctl unload "$targetFile"
          echo "Unloaded LaunchAgent at $targetFile."
        elif [[ "$launchDaemonCheck" =~ $justThePlist ]]; then
          /bin/launchctl unload "$targetFile"
          echo "Unloaded LaunchDaemon at $targetFile."
        fi
      fi
      # disable kexts, delete all other file types
      if [[ "$targetFile" == *".kext" ]]; then
        appKextKillPath="/tmp/$scriptName"
        /bin/mkdir -p "$appKextKillPath"
        /bin/mv "$targetFile" "$appKextKillPath"
        echo "Moved $targetFile to $appKextKillPath. File will be deleted on subsequent restart."
      else
        /bin/rm -rf "$targetFile"
        echo "Removed $targetFile."
      fi
    fi
  done
}



########## main process ##########



# Each function will only execute if the respective source array is not empty
# or undefined.
if [[ -n "${vendorUninstallerCommands[*]}" ]]; then
  echo "Running vendor uninstallers..."
  run_vendor_uninstallers
fi


if [[ -n "${processNames[*]}" ]]; then
  echo "Quitting processes (if running)..."
  quit_processes
fi


if [[ -n "${resourceFiles[*]}" ]]; then
  echo "Removing files (if present)..."
  delete_files
fi



exit 0
