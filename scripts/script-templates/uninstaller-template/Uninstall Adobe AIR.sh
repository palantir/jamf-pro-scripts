#!/bin/sh

###
#
#            Name:  Uninstall Adobe AIR.sh
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



# Runs specified vendor uninstaller.
run_vendor_uninstaller () {

  if [ -e "${1}" ]; then
    echo "Running vendor uninstaller: ${1}"
    ./"${1}"
  else
    echo "Vendor uninstaller not found at ${1}."
  fi

}


# Quits specified process.
quit_process () {

  currentProcesses=$(/bin/ps aux)
  if echo "$currentProcesses" | /usr/bin/grep -q "${1}"; then
    /bin/launchctl asuser "$loggedInUserUID" /usr/bin/osascript -e "tell application \"${1}\" to quit"
    echo "Quit ${1}."
  fi

}


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



# VENDOR UNINSTALLERS
# For each vendor-provided uninstallation tool file path that exists on the system, run the run_vendor_uninstaller function calling that path to run it. Note that vendor uninstaller workflows may differ greatly from app to app. Some vendors may use their own command-line tools with custom flags or other workflows to accomplish this task (that's why this script exists!), so make any necessary changes to the below commands if the uninstallation workflow isn't simply calling executable files. Call the function again for each additional uninstaller. If the vendor did not provide an uninstaller workflow, comment out or remove this line.
run_vendor_uninstaller "/Applications/Utilities/Adobe AIR Uninstaller.app/Contents/MacOS/Adobe AIR Installer"


# PROCESSES
# For each process related to the target product, run the quit_process function calling that process name to quit it. Names should match what is displayed for the process in Activity Monitor (e.g. "Chess", not "Chess.app"). Call the function again for each additional process. If no processes need to be quit, comment out or remove this line.
quit_process "Adobe AIR Application Installer"
quit_process "Adobe AIR Installer"


# FILE PATHS
# For each file and/or folder related to the target product, run the delete_file function calling that file name. Leave off trailing slashes from directory paths. Call the function again for each additional file. If no files need to be deleted, comment out or remove this line.
delete_file "/Applications/Adobe/Flash Player/AddIns/airappinstaller"
delete_file "/Applications/Utilities/Adobe AIR Application Installer.app"
delete_file "/Applications/Utilities/Adobe AIR Uninstaller.app"
delete_file "/Library/Frameworks/Adobe AIR.framework"



exit 0
