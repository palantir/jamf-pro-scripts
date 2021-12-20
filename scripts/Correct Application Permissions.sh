#!/bin/sh

###
#
#            Name:  Correct Application Permissions.sh
#     Description:  Changes ownership of the target application to the current
#                   logged-in user.
#                   NOTE: This script is managed by AutoPkg and should be
#                   updated in the jamf-pro-scripts repository rather than the
#                   Jamf Pro console.
#         Created:  2021-03-04
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


# Jamf Pro script parameter: "Target Application"
# The application to target for permissions repair.
# Use the application file name without extension (e.g. "Google Chrome").
targetApp="${4}"
# Get current user and OS information.
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetApp" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
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
check_logged_in_user


# Change ownership on the target application to the current logged-in user.
if [ -d "/Applications/${targetApp}.app" ]; then
  echo "Correcting permissions for ${targetApp}..."
  chown -R "$(stat -f%Su /dev/console)" "/Applications/${targetApp}.app"
else
  echo "❌ ERROR: ${targetApp} missing, unable to proceed."
  exit 1
fi



exit 0
