#!/bin/bash

###
#
#            Name:  Reset Safari.sh
#     Description:  Resets all Safari user data to defaults for the currently
#                   logged-in user.
#         Created:  2016-08-18
#   Last Modified:  2020-07-08
#         Version:  2.1.4
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
userLibrary="$loggedInUserHome/Library"
uuid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/ {print $NF}')
preferencesToReset=(
  "$userLibrary/Caches/Metadata/Safari"
  "$userLibrary/Caches/com.apple.Safari"
  "$userLibrary/Caches/com.apple.WebKit.PluginProcess"
  "$userLibrary/Cookies/Cookies.binarycookies"
  "$userLibrary/Preferences/ByHost/com.apple.Safari.$uuid.plist"
  "$userLibrary/Preferences/com.apple.Safari.LSSharedFileList.plist"
  "$userLibrary/Preferences/com.apple.Safari.RSS.plist"
  "$userLibrary/Preferences/com.apple.Safari.plist"
  "$userLibrary/Preferences/com.apple.Safari.plistls"
  "$userLibrary/Preferences/com.apple.WebFoundation.plist"
  "$userLibrary/Preferences/com.apple.WebKit.PluginHost.plist"
  "$userLibrary/Preferences/com.apple.WebKit.PluginProcess.plist"
  "$userLibrary/PubSub/Database"
  "$userLibrary/Safari"
  "$userLibrary/Saved Application State/com.apple.Safari.savedState"
)



########## main process ##########



# Delete Safari preference files.
echo "Deleting Safari preference files to reset to system default..."
for safariPref in "${preferencesToReset[@]}"; do
  if [ -e "$safariPref" ]; then
    /bin/rm -rv "$safariPref"
  fi
done



exit 0
