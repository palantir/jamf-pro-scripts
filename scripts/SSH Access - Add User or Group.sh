#!/bin/sh

###
#
#            Name:  SSH Access - Add User or Group.sh
#     Description:  Adds target user or group to SSH membership at $sshGroup.
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  3.1.1
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



# Jamf script parameter "Target ID"
targetID="$4"
# Jamf script parameter "Target Type"
# Must be either "user" or "group"
targetType="$5"
sshGroup="com.apple.access_ssh"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$targetID"
    "$targetType"
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


# exits if Target Type is an incorrect value
if [[ "$targetType" != "user" ]] && [[ "$targetType" != "group" ]]; then
  "/bin/echo" "Target Type $targetType is unknown value, unable to proceed. Please check Target Type parameter in Jamf policy."
  exit 1
fi


# creates com.apple.access_ssh if missing
if [[ $("/usr/sbin/dseditgroup" -o read "$sshGroup") = "Group not found." ]]; then
  "/usr/sbin/dseditgroup" -o create "$sshGroup"
fi


# adds target user or group to com.apple.access_ssh
"/usr/sbin/dseditgroup" -o edit \
  -a "$targetID" \
  -t "$targetType" \
  "$sshGroup"


"/bin/echo" "Added $targetID to $sshGroup."



exit 0
