#!/bin/sh

###
#
#            Name:  Uninstall Adobe Creative Cloud Desktop.sh
#     Description:  A template script to assist with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions. Attempts vendor uninstall by running all provided uninstallation executables, quits all running target processes, then removes all associated target files.
#                   https://github.com/palantir/jamf-pro-scripts/tree/main/scripts/script-templates/uninstaller-template
#         Created:  2017-10-23
#   Last Modified:  2023-07-18
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
delete_file "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/AppsPanel/Updater/Adobe Application Updater.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/CCXProcess/CCXProcess.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/HDCore/Install.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/HDCore/Uninstaller.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Desktop App.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Installer.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud/"
delete_file "/Applications/Utilities/Adobe Creative Cloud Experience/CCXProcess.app"
delete_file "/Applications/Utilities/Adobe Creative Cloud Experience"



exit 0
