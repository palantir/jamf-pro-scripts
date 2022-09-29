#!/bin/sh

###
#
#            Name:  Create Folder for All Users.sh
#     Description:  Creates specified folder for all users of a particular Mac
#                   at the top level of each user's home folder.
#         Created:  2016-08-22
#   Last Modified:  2022-09-28
#         Version:  1.4
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



# Jamf Pro script parameter: "Target Folder"
# Folder will be created in the top level of each user's home folder.
targetFolder="${4}"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetFolder" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments


# Iterate through all users with ID greater than 500.
for targetUser in $(/usr/bin/dscl . list "/Users" UniqueID | /usr/bin/awk '$2 > 500 {print $1}'); do
  targetUserHome=$(/usr/bin/dscl . -read "/Users/${targetUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
  targetFolderPath="${targetUserHome}/${targetFolder}"
  # Exit with error if home folder path is undefined.
  if [ -z "$targetUserHome" ]; then
    echo "❌ ERROR: No home folder defined for ${targetUser}, unable to proceed."
    exit 1
    # Exit with error if home folder doesn't exist.
  elif [ ! -d "$targetUserHome" ]; then
    echo "❌ ERROR: No home folder found at ${targetUserHome}, unable to proceed."
    exit 1
  # Skip if target folder already exists.
  elif [ -d "$targetFolderPath" ]; then
    echo "Folder already exists at ${targetFolderPath}, no action required for this user."
  else
    # For each user, create target folder.
    /bin/mkdir "$targetFolderPath" && echo "Created folder: ${targetFolderPath}"
    # Make the user the owner of the folder.
    /usr/sbin/chown "$targetUser" "$targetFolderPath"
  fi
done



exit 0
