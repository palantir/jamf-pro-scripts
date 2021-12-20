#!/bin/bash

###
#
#            Name:  Update macOS softwareupdate Ignore List.sh
#     Description:  Adds restricted macOS software updates to the softwareupdate
#                   ignore list, or resets the ignore list.
#         Created:  2018-01-24
#   Last Modified:  2021-11-16
#         Version:  3.1
#
#
# Copyright 2018 Palantir Technologies, Inc.
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



# Defines whether to reset the current softwareupdate ignore list.
# Expected result is "yes", anything else is interpreted as a "no".
# Jamf Pro script parameter: "Reset softwareupdate Ignore List"
resetIgnoreList="$4"
# List all desired ignored software updates here, one per variable. Blank
# variables will be skipped.
# Jamf Pro script parameters: "Ignored Update 1", "Ignored Update 2", etc.
updateIgnoreList=(
  "$5"
  "$6"
  "$7"
  "$8"
  "$9"
)
macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')



########## function-ing ##########



# Exits if Mac is running macOS 11 or later.
check_macos () {
  if [ "$macOSVersionMajor" -ge 11 ]; then
    echo "❌ ERROR: softwareupdate's ignore functionality is deprecated in macOS 10.15 Catalina and is no longer supported in macOS 11 Big Sur or later, unable to proceed."
    exit 72
  fi
}



########## main process ##########



# Verify script prerequisites.
check_macos


# Initialize softwareupdate ignore list.
if [ "$resetIgnoreList" = "yes" ]; then
  /usr/sbin/softwareupdate --reset-ignored
fi


# Add items to softwareupdate ignore list.
for update in "${updateIgnoreList[@]}"; do
  if [ -n "$update" ]; then
    /usr/sbin/softwareupdate --ignore "$update"
  fi
done



exit 0
