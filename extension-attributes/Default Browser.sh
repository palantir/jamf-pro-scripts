#!/bin/bash

###
#
#            Name:  Default Browser.sh
#     Description:  Returns default browser of currently logged-in user.
#                   Reformats browser agent string to full name when one of a
#                   list of common browsers.
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  1.2.1
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
loggedInUserHome=$("/usr/bin/dscl" . -read /Users/$loggedInUser NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
defaultBrowser=$("/usr/bin/defaults" read "$loggedInUserHome/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist" | "/usr/bin/grep" -B1 https | "/usr/bin/awk" -F\" '/LSHandlerRoleAll/ {print $2}')



########## main process ##########



# output default browser
if [[ $defaultBrowser = "" ]]; then
  browserResult="Undefined"
elif [[ $defaultBrowser = "com.apple.safari" ]]; then
  browserResult="Safari"
elif [[ $defaultBrowser = "com.google.chrome" ]]; then
  browserResult="Chrome"
elif [[ $defaultBrowser = "org.mozilla.firefox" ]]; then
  browserResult="Firefox"
elif [[ $defaultBrowser = "org.mozilla.aurora" ]]; then
  browserResult="Firefox Developer Edition"
elif [[ $defaultBrowser = "org.mozilla.nightly" ]]; then
  browserResult="Firefox Nightly"
elif [[ $defaultBrowser = "com.parallels.desktop.console" ]]; then
  browserResult="Parallels Desktop"
else
  browserResult="$defaultBrowser"
fi


"/bin/echo" "<result>$browserResult</result>"



exit 0
