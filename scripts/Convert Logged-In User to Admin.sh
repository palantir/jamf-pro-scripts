#!/bin/sh

###
#
#            Name:  Convert Logged-In User to Admin.sh
#     Description:  Grants admin privileges to logged-in user.
#         Created:  2018-10-08
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



# Grant admin privileges to $loggedInUser.
if /usr/bin/dscl . -read "/groups/admin" GroupMembership | /usr/bin/grep -q "$loggedInUser"; then
  echo "$loggedInUser already has admin privileges, no action required."
else
  /usr/bin/dscl . -append "/groups/admin" GroupMembership "$loggedInUser"
  echo "Granted admin privileges to $loggedInUser."
fi



exit 0
