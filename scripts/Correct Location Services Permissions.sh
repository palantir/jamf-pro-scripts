#!/bin/sh

###
#
#            Name:  Correct Location Services Permissions.sh
#     Description:  Corrects permissions on the plist controlling Location
#                   Services settings.
#         Created:  2017-08-04
#   Last Modified:  2020-07-08
#         Version:  1.1.1
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



locationdUser="_locationd"
locationdPath="/var/db/locationd"
locationdByHost="$locationdPath/Library/Preferences/ByHost/"
locationdPermissionsCheck=$(/bin/ls -l $locationdByHost | \
  /usr/bin/sed 1d | \
  /usr/bin/grep -v "$locationdUser.*$locationdUser")



########## main process ##########



if [ -z "$locationdPermissionsCheck" ]; then
  echo "All locationd settings files owned by $locationdUser, no action required."
else
  echo "Incorrect permissions found in locationd settings files."
  echo "$locationdPermissionsCheck"
  /usr/sbin/chown -R "$locationdUser":"$locationdUser" "$locationdPath"
  echo "Repaired permissions, all settings files now owned by $locationdUser."
fi



exit 0
