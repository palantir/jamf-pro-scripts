#!/bin/zsh

###
#
#            Name:  iCloud Services Enabled.zsh
#     Description:  Returns list of enabled iCloud syncing services.
#         Created:  2018-08-15
#   Last Modified:  2020-07-08
#         Version:  1.1.1
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
icloudPlist="$loggedInUserHome/Library/Preferences/MobileMeAccounts.plist"
plistbuddy="/usr/libexec/PlistBuddy"



########## main process ##########



# Check for presence of target file and get list of services.
if [[ -e "$icloudPlist" ]]; then
  servicesCount=$("$plistbuddy" -x -c "print :Accounts:0:Services" "$icloudPlist" | /usr/bin/grep -c "<dict>")
  for (( i=0;i<servicesCount;i++ )); do
    if [[ $("$plistbuddy" -c "print :Accounts:0:Services:$i:Enabled" "$icloudPlist" 2>&1) != "false" ]] && [[ $("$plistbuddy" -c "print :Accounts:0:Services:$i:status" "$icloudPlist" 2>&1) != "inactive" ]]; then
      serviceName=$("$plistbuddy" -c "print :Accounts:0:Services:$i:Name" "$icloudPlist")
      if [[ "$icloudServices" = "" ]]; then
        icloudServices="$serviceName"
      else
        icloudServices=$(echo "$icloudServices"; "echo" "$serviceName")
      fi
    fi
  done
else
  icloudServices=""
fi


# Report result.
echo "<result>$icloudServices</result>"



exit 0
