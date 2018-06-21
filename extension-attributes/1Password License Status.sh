#!/bin/bash

###
#
#            Name:  1Password License Status.sh
#     Description:  Returns 1Password license info (if application is
#                   installed).
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  1.2.2
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



loggedInUser=$("/usr/bin/stat" -f%Su "/dev/console")
loggedInUserHome=$("/usr/bin/dscl" . -read "/Users/$loggedInUser" NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
onePWContainer="$loggedInUserHome/Library/Group Containers/2BUA8C4S2C.com.agilebits"
onePWCheck=$("/bin/ls" "/Applications/" | "/usr/bin/grep" "1Password")



########## main process ##########



if [[ "$onePWCheck" = "" ]]; then
  licenseStatus=""
else
  # if 1Password exists, checks for presence of either license file or Mac App Store receipt
  if [[ -e "$onePWContainer/License/License.onepassword-license" ]]; then
    licenseStatus="Licensed"
  elif [[ -e "$onePWContainer/App\ Store\ Receipts/receipt" ]]; then
    licenseStatus="Mac App Store"
  else
    licenseStatus="Trial"
  fi
fi


"/bin/echo" "<result>$licenseStatus</result>"



exit 0
