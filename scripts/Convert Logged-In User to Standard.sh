#!/bin/sh

###
#
#            Name:  Convert Logged-In User to Standard.sh
#     Description:  Removes admin privileges from logged-in user.
#         Created:  2018-10-10
#   Last Modified:  2020-07-08
#         Version:  1.1.2
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



########## main process ##########



# Remove admin privileges from $loggedInUser.
if /usr/bin/dscl . -read "/groups/admin" GroupMembership | /usr/bin/grep -q "$loggedInUser"; then
  /usr/sbin/dseditgroup -o edit -d "$loggedInUser" admin
  echo "Removed $loggedInUser admin privileges."
else
  echo "$loggedInUser is already a standard user, no action required."
fi



exit 0
