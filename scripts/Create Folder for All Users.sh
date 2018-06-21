#!/bin/bash

###
#
#            Name:  Create Folder for All Users.sh
#     Description:  Creates specified folder for all users of a particular Mac.
#                   Folder is placed at top level of each user's home folder,
#                   as well as the User Template folder for all future user
#                   accounts.
#         Created:  2016-08-22
#   Last Modified:  2018-06-20
#         Version:  1.2.1
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



# Jamf script parameter "Target Folder"
# Folder will be created in the top level of the current user's home folder.
targetFolder="$4"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$targetFolder"
  )
  for argument in "${jamfArguments[@]}"; do
    if [[ "$argument" = "" ]]; then
      "/bin/echo" "Undefined Jamf argument, unable to proceed."
      exit 74
    fi
  done
}



########## main process ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments


# iterate through all users with ID greater than 500
for this_user in $("/usr/bin/dscl" . list /Users UniqueID | "/usr/bin/awk" '$2 > 500 {print $1}'); do
  # For each user, create $targetFolder if one doesn't exist.
  if [[ ! -d "/Users/$this_user/$targetFolder" ]]; then
    "/bin/mkdir" -v "/Users/$this_user/$targetFolder"
    "/usr/sbin/chown" "$this_user" "/Users/$this_user/$targetFolder"
  fi
done


# Create $targetFolder in the user template if one doesn't exist.
if [[ ! -d "/System/Library/User Template/English.lproj/$targetFolder" ]]; then
  "/bin/mkdir" -v "/System/Library/User Template/English.lproj/$targetFolder"
fi



exit 0
