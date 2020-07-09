#!/bin/bash

###
#
#            Name:  SSH Access - Remove User or Group.sh
#     Description:  Removes target user or group from SSH membership at
#                   $sshGroup.
#         Created:  2017-09-25
#   Last Modified:  2020-07-08
#         Version:  1.2.1
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



# Jamf Pro script parameter "Target ID"
targetID="$4"
# Jamf Pro script parameter "Target Type"
# Must be either "user" or "group".
targetType="$5"
sshGroup="com.apple.access_ssh"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
function check_jamf_pro_arguments {
  jamfProArguments=(
    "$targetID"
    "$targetType"
  )
  for argument in "${jamfProArguments[@]}"; do
    if [[ -z "$argument" ]]; then
      echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
      exit 74
    fi
  done
}



########## main process ##########



# Exit if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments


# Exit if Target Type is an incorrect value.
if [[ "$targetType" != "user" ]] && [[ "$targetType" != "group" ]]; then
  echo "❌ ERROR: Target Type $targetType is unknown value, unable to proceed. Please check Target Type parameter in Jamf policy."
  exit 1
fi


# Create com.apple.access_ssh if missing.
if [[ $(/usr/sbin/dseditgroup -o read "$sshGroup") = "Group not found." ]]; then
  /usr/sbin/dseditgroup -o create "$sshGroup"
fi


# Remove target user or group from com.apple.access_ssh.
/usr/sbin/dseditgroup -o edit \
  -d "$targetID" \
  -t "$targetType" \
  "$sshGroup"
echo "Removed $targetID from $sshGroup."



exit 0
