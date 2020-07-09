#!/bin/sh

###
#
#            Name:  Create Folder for All Users.sh
#     Description:  Creates specified folder for all users of a particular Mac
#                   at the top level of each user's home folder.
#         Created:  2016-08-22
#   Last Modified:  2020-07-08
#         Version:  1.3.1
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
targetFolder="$4"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetFolder" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}



########## main process ##########



# Exit if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments


# Iterate through all users with ID greater than 500.
for targetUser in $(/usr/bin/dscl . list "/Users" UniqueID | /usr/bin/awk '$2 > 500 {print $1}'); do
  # For each user, create $targetFolder at the top level of user's home folder
  # (if it doesn't already exist).
  targetUserHome=$(/usr/bin/dscl . -read "/Users/$targetUser" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
  if [ ! -d "$targetUserHome/$targetFolder" ]; then
    /bin/mkdir -v "$targetUserHome/$targetFolder"
    /usr/sbin/chown "$targetUser" "$targetUserHome/$targetFolder"
  fi
done



exit 0
