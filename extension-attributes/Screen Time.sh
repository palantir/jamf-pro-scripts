#!/bin/sh

###
#
#            Name:  Screen Time.sh
#     Description:  Reports whether Screen Time is enabled or disabled.
#         Created:  2023-12-14
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUID=$(/usr/bin/id -u "$loggedInUser")
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/${loggedInUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
plistPath="${loggedInUserHome}/Library/Containers/com.apple.ScreenTimeAgent/Data/Library/Preferences/com.apple.ScreenTimeAgent.plist"
plistKey="UsageGenesisDate"



########## function-ing ##########



# Exits if root is the currently logged-in user, or no logged-in user is detected.
check_logged_in_user () {
  if [ "$loggedInUser" = "root" ] || [ -z "$loggedInUser" ]; then
    echo "Nobody is logged in."
    exit 0
  fi
}



########## main process ##########



# Checks script prerequisites.
check_logged_in_user


# Read setting key and report enabled vs disabled.
currentKey=$(/bin/launchctl asuser "$loggedInUID" /usr/bin/defaults read "$plistPath" "$plistKey" 2>"/dev/null")
if [ -z "$currentKey" ]; then
  settingValue="disabled"
else
  settingValue="enabled"
fi


echo "<result>${settingValue}</result>"



exit 0
