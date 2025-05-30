#!/bin/sh

###
#
#            Name:  Set Time Zone Automatically.sh
#     Description:  Reads whether "set time zone automatically using current location setting" is enabled.
#         Created:  2022-05-18
#   Last Modified:  2025-04-28
#         Version:  1.0.1
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



defaultsRead=$(/usr/bin/defaults read "/private/var/db/timed/Library/Preferences/com.apple.timed" TMAutomaticTimeZoneEnabled 2>"/dev/null")



########## main process ##########



# Parse output of defaults write.
if [ "$defaultsRead" = "1" ]; then
  setTimeZoneAutomatically="enabled"
else
  setTimeZoneAutomatically="disabled"
fi


# Report results.
echo "<result>${setTimeZoneAutomatically}</result>"



exit 0
