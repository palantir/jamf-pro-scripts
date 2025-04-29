#!/bin/sh

###
#
#            Name:  User Applications.sh
#     Description:  Lists any applications installed in ~/Applications, ~/Desktop, ~/Documents, or ~/Downloads (searches up to three levels deep).
#         Created:  2022-03-11
#   Last Modified:  2025-04-28
#         Version:  1.0.3
#
# Copyright 2022 Palantir Technologies, Inc.
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
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/${loggedInUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
userApps=""



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


# List all applications found in ~/Applications, ~/Desktop, ~/Documents, or ~/Downloads (if any).
userApps=$(/usr/bin/find "${loggedInUserHome}/Applications" "${loggedInUserHome}/Desktop" "${loggedInUserHome}/Documents" "${loggedInUserHome}/Downloads" -maxdepth 3 -name "*.app" 2>"/dev/null")


# Report results.
echo "<result>${userApps}</result>"



exit 0
