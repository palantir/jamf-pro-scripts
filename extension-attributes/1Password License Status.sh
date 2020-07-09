#!/bin/sh

###
#
#            Name:  1Password License Status.sh
#     Description:  Returns 1Password license info (if application is
#                   installed).
#         Created:  2016-06-06
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
onePWContainer="$loggedInUserHome/Library/Group Containers/2BUA8C4S2C.com.agilebits"



########## main process ##########



# Check for 1Password application.
if /usr/bin/find /Applications -maxdepth 1 | /usr/bin/grep -q 1Password; then
  # Check for presence of target license file or Mac App Store receipt.
  if [ -e "$onePWContainer/License/1Password 7 License.onepassword7-license-mac" ]; then
    licenseStatus="Licensed"
  elif [ -e "$onePWContainer/App Store Receipts/receipt" ]; then
    licenseStatus="Mac App Store"
  else
    licenseStatus="Trial"
  fi
else
  licenseStatus=""
fi


# Report result.
echo "<result>$licenseStatus</result>"



exit 0
