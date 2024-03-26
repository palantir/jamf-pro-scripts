#!/bin/sh

###
#
#            Name:  Uninstall Safari User Preferences.sh
#     Description:  A template script to assist with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions. Attempts vendor uninstall by running all provided uninstallation executables, quits all running target processes, then removes all associated target files.
#                   https://github.com/palantir/jamf-pro-scripts/tree/main/scripts/script-templates/uninstaller-template
#         Created:  2017-10-23
#   Last Modified:  2024-03-26
#         Version:  2.0pal1
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserUID=$(/usr/bin/id -u "$loggedInUser")
# For any file paths used later in this script, use "$loggedInUserHome" for the current user's home folder path. Don't just assume the home folder is at /Users/${loggedInUser}.
# shellcheck disable=SC2034
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/${loggedInUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')



########## function-ing ##########



# Removes specified file.
delete_file () {

  # Check if file exists.
  if [ -e "${1}" ]; then
    # Check if file is a plist.
    if echo "${1}" | /usr/bin/grep -q ".plist"; then
      # If plist is loaded as LaunchAgent or LaunchDaemon, unload it.
      justThePlist=$(/usr/bin/basename "${1}" | /usr/bin/awk -F.plist '{print $1}')
      if /bin/launchctl asuser "$loggedInUserUID" /bin/launchctl list | /usr/bin/grep -q "$justThePlist"; then
        /bin/launchctl asuser "$loggedInUserUID" /bin/launchctl unload "${1}"
        echo "Unloaded LaunchAgent at ${1}."
      elif /bin/launchctl list | /usr/bin/grep -q "$justThePlist"; then
        /bin/launchctl unload "${1}"
        echo "Unloaded LaunchDaemon at ${1}."
      fi
    fi
    # Remove system immutable flag if present.
    if /bin/ls -ldO "${1}" | /usr/bin/awk '{print $5}' | /usr/bin/grep -q "schg"; then
      /usr/bin/chflags -R noschg "${1}"
      echo "Removed system immutable flag for ${1}."
    fi
    # Remove file.
    /bin/rm -rf "${1}"
    echo "Removed ${1}."
  fi

}



########## main process ##########



# FILE PATHS
# For each file and/or folder related to the target product, run the delete_file function calling that file name. Leave off trailing slashes from directory paths. Call the function again for each additional file. If no files need to be deleted, comment out or remove this line.
delete_file "${loggedInUserHome}/Library/Caches/com.apple.Safari"
delete_file "${loggedInUserHome}/Library/Caches/com.apple.WebKit.PluginProcess"
delete_file "${loggedInUserHome}/Library/Caches/Metadata/Safari"
delete_file "${loggedInUserHome}/Library/Containers/com.apple.Safari"
delete_file "${loggedInUserHome}/Library/Containers/com.apple.Safari.DiagnosticExtension"
delete_file "${loggedInUserHome}/Library/Containers/com.apple.SafariTechnologyPreview"
delete_file "${loggedInUserHome}/Library/Containers/com.apple.SafariTechnologyPreview.DiagnosticExtension"
delete_file "${loggedInUserHome}/Library/Cookies/Cookies.binarycookies"
delete_file "${loggedInUserHome}/Library/Preferences/ByHost/com.apple.Safari.$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/ {print $NF}').plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.Safari.LSSharedFileList.plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.Safari.plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.Safari.plistls"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.Safari.RSS.plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.WebFoundation.plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.WebKit.PluginHost.plist"
delete_file "${loggedInUserHome}/Library/Preferences/com.apple.WebKit.PluginProcess.plist"
delete_file "${loggedInUserHome}/Library/PubSub/Database"
delete_file "${loggedInUserHome}/Library/Safari"
delete_file "${loggedInUserHome}/Library/Saved Application State/com.apple.Safari.savedState"



exit 0
