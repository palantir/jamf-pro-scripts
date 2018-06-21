#!/bin/bash

###
#
#            Name:  Correct Location Services Permissions.sh
#     Description:  Corrects permissions on the plist controlling Location
#                   Services settings.
#         Created:  2017-08-04
#   Last Modified:  2018-06-20
#         Version:  1.0.2
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
locationdPermissionsCheck=$("/bin/ls" -l $locationdByHost | \
  "/usr/bin/sed" 1d | \
  "/usr/bin/grep" -v "$locationdUser.*$locationdUser")



########## main process ##########



if [[ "$locationdPermissionsCheck" = "" ]]; then
  "/bin/echo" "All locationd settings files owned by $locationdUser, no action required."
else
  "/bin/echo" "Incorrect permissions found in locationd settings files."
  "/bin/echo" "$locationdPermissionsCheck"
  "/usr/sbin/chown" -R "$locationdUser":"$locationdUser" "$locationdPath"
  "/bin/echo" "Repaired permissions, all settings files now owned by $locationdUser."
fi



exit 0
