#!/bin/sh

###
#
#            Name:  Uninstall Single Application.sh
#     Description:  A template script to assist with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions. Attempts vendor uninstall by running all provided uninstallation executables, quits all running target processes, then removes all associated target files.
#                   https://github.com/palantir/jamf-pro-scripts/tree/main/scripts/script-templates/uninstaller-template
#         Created:  2017-10-23
#   Last Modified:  2025-09-25
#         Version:  2.0pal2
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



# Jamf Pro script parameter: "App Process"
appProcess="${4}"
# Jamf Pro script parameter: "App File Path"
# Should be full path to the application, e.g. "/System/Applications/Chess.app". If referencing the current user's home folder path, replace "~/" with "LOGGED_IN_USER_HOME/", e.g. "LOGGED_IN_USER_HOME/Applications/Google Chrome.app".
appFilePath="${5}"


loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserUID=$(/usr/bin/id -u "$loggedInUser")
# For any file paths used later in this script, use "$loggedInUserHome" for the current user's home folder path. Don't just assume the home folder is at /Users/${loggedInUser}.
# shellcheck disable=SC2034
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/${loggedInUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {

  if [ -z "$appProcess" ] || [ -z "$appFilePath" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
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


# Takes LOGGED_IN_USER_HOME placeholder and replaces with $loggedInUserHome.
convert_path_to_home () {

  if echo "$appFilePath" | /usr/bin/grep -q "LOGGED_IN_USER_HOME/"; then
    appFilePath=$(echo "$appFilePath" | /usr/bin/sed "s|LOGGED_IN_USER_HOME|$loggedInUserHome|")
    echo "Converted input to file path: ${appFilePath}"
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



# Exit if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments


# PROCESSES
# For each process related to the target product, run the quit_process function calling that process name to quit it. Names should match what is displayed for the process in Activity Monitor (e.g. "Chess", not "Chess.app"). Call the function again for each additional process. If no processes need to be quit, comment out or remove this line.
quit_process "$appProcess"


# FILE PATHS
# For each file and/or folder related to the target product, run the delete_file function calling that file name. Leave off trailing slashes from directory paths. Call the function again for each additional file. If no files need to be deleted, comment out or remove this line. Replaces LOGGED_IN_USER_HOME placeholder with $loggedInUsrHome as needed.
convert_path_to_home
delete_file "$appFilePath"



exit 0
