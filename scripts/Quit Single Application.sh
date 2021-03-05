#!/bin/sh

###
#
#            Name:  Quit Single Application.sh
#     Description:  Quits target application.
#                   NOTE: This script is managed by AutoPkg and should be
#                   updated in the jamf-pro-scripts repository rather than the
#                   Jamf Pro console.
#         Created:  2021-03-01
#   Last Modified:  2021-03-04
#         Version:  1.0
#
# Copyright 2021 Palantir Technologies, Inc.
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
###



########## variable-ing ##########



# The application we want to quit.
# Use the application file name without extension (e.g. "Google Chrome").
# Jamf Pro script parameter: "Target Application"
targetApp="${4}"
# Get current user and OS information.
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUID=$(/usr/bin/id -u "$loggedInUser")
macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $1}')
macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $2}')



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetApp" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}


# Verifies macOS version is compatible with script.
check_macos_version () {
  if [ "$macOSVersionMajor" -lt 10 ] || [ "$macOSVersionMajor" -eq 10 ] && [ "$macOSVersionMinor" -lt 10 ]; then
    echo "❌ ERROR: macOS version ($(/usr/bin/sw_vers -productVersion)) unrecognized or incompatible, unable to proceed."
    exit 1
  fi
}


# Exits if root is the currently logged-in user, or no logged-in user is detected.
check_logged_in_user () {
  if [ "$loggedInUser" = "root" ] || [ -z "$loggedInUser" ]; then
    echo "Nobody is logged in, no action required."
    exit 0
  fi
}



########## main process ##########



# Check script prerequisites.
check_jamf_pro_arguments
check_macos_version
check_logged_in_user


# Quit target application in current user context using launchctl.
if [ -d "/Applications/${targetApp}.app" ]; then
  echo "Quitting ${targetApp}..."
  /bin/launchctl asuser "$loggedInUID" /usr/bin/osascript -e "tell application \"${targetApp}\" to quit"
fi



exit 0
