#!/bin/bash

###
#
#            Name:  Update SSH Public Key.sh
#     Description:  Adds new SSH public key to specified user account for
#                   remote access, replacing any existing keys.
#         Created:  2017-02-14
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



# Jamf script parameter "Target User"
targetUser="$4"
targetUserHome="$5"
# Jamf script parameter "Public SSH Key Path"
publicSSHKeyPath="$6"
targetUserSSHSettings="$targetUserHome/.ssh"
targetUserSSHAuthorizedKeysPath="$targetUserSSHSettings/authorized_keys"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$targetUser"
    "$targetUserHome"
    "$publicSSHKeyPath"
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


# exit if public SSH key does not exist
public_ssh_key_check () {
  if [[ ! -e "$publicSSHKeyPath" ]]; then
    "/bin/echo" "Public SSH Key not found at specified path, unable to proceed. Please check Public SSH Key Path parameter in Jamf policy."
    exit 74
  fi
}


# remove existing SSH keys if present
if [[ -e "$targetUserSSHAuthorizedKeysPath" ]]; then
  "/bin/rm" "$targetUserSSHAuthorizedKeysPath"
fi


# add .ssh/authorized_keys and populate with user's public key
"/bin/mkdir" -p "$targetUserSSHSettings"
"/usr/bin/touch" "$targetUserSSHAuthorizedKeysPath"
"/bin/echo" "$publicSSHKey" >> "$targetUserSSHAuthorizedKeysPath"
"/usr/sbin/chown" -R "$targetUser" "$targetUserSSHSettings/"
"/bin/chmod" 700 "$targetUserSSHSettings"
"/bin/chmod" 600 "$targetUserSSHAuthorizedKeysPath"



exit 0
