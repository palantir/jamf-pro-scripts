#!/bin/sh

###
#
#            Name:  Update User Picture.sh
#     Description:  Removes existing Picture value for target user, then replaces Picture with a new file path.
#         Created:  2023-10-30
#   Last Modified:  2025-04-28
#         Version:  1.0.1
#
# Copyright 2023 Palantir Technologies, Inc.
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



# Jamf Pro script parameter: "Target User"
targetUser="${4}"
# Jamf Pro script parameter: "Picture Path"
picturePath="${5}"



########## function-ing ##########



# Exits with error if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {

  if [ -z "$targetUser" ] || [ -z "$picturePath" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi

}


# Exits with error if specified user does not exist.
user_exists () {

  if /usr/bin/id "${1}" >"/dev/null" 2>&1; then
    echo "Verified user exists: ${1}"
  else
    echo "❌ ERROR: User not found, unable to proceed: ${1}"
    exit 1
  fi

}


# Exits with error if specified file does not exist.
file_path_exists () {

  if [ -e "${1}" ]; then
    echo "Verified file exists: ${1}"
  else
    echo "❌ ERROR: File not found, unable to proceed: ${1}"
    exit 1
  fi

}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments
user_exists "$targetUser"
file_path_exists "$picturePath"


# Remove existing Picture and JPEGPhoto attributes from target user (send stderr to /dev/null as these objects are not always present in a user account but must be removed prior to defining a new user picture).
/usr/bin/dscl . -delete "/Users/${targetUser}" Picture 2>"/dev/null"
/usr/bin/dscl . -delete "/Users/${targetUser}" JPEGPhoto 2>"/dev/null"


# Add Picture attribute to target user.
/usr/bin/dscl . -create "/Users/${targetUser}" Picture "$picturePath"



exit 0
