#!/bin/bash

###
#
#            Name:  Convert Admin Account to Standard.sh
#     Description:  Removes admin privileges from target account.
#         Created:  2017-08-17
#   Last Modified:  2018-06-20
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



# Jamf script parameter "Target Account"
targetAccount="$4"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$targetAccount"
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


# remove admin privileges from $targetAccount
if [[ $("/usr/bin/dscl" . list "/Users" | "/usr/bin/grep" "$targetAccount") = "" ]]; then
  "/bin/echo" "$targetAccount does not exist, no action required."
else
  "/usr/sbin/dseditgroup" -o edit -d "$targetAccount" admin
  "/bin/echo" "Removed $targetAccount admin privileges."
fi



exit 0
