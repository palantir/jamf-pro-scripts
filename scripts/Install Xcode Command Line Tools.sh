#!/bin/bash

###
#
#            Name:  Install Xcode Command Line Tools.sh
#     Description:  Installs Xcode Command Line Tools.
#         Created:  2016-01-31
#   Last Modified:  2019-06-11
#         Version:  5.3
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



########## function-ing ##########



# Check current state of Xcode Command Line Tools installation.
function xcodeCheck {
  xcodeSelectCheck=$("/usr/bin/xcode-select" -p 2>&1)
  if [[ "$xcodeSelectCheck" = "/Applications/Xcode.app/Contents/Developer" || "$xcodeSelectCheck" = "/Library/Developer/CommandLineTools" ]]; then
    xcodeCLI="installed"
  else
    xcodeCLI="missing"
  fi
}



########## main process ##########



# Exit if Xcode Command Line Tools are already installed.
xcodeCheck
if [[ "$xcodeCLI" = "installed" ]]; then
  "/bin/echo" "Xcode Command Line Tools already installed, no action required."
  exit 0
fi


# Install Xcode Command Line Tools via softwareupdate.
"/usr/bin/touch" "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
xcodeCommandLineTools=$("/usr/sbin/softwareupdate" --list 2>&1 | \
  "/usr/bin/awk" -F"[*] " '/\* Command Line Tools/ {print $NF}')
while read -r update; do
  "/usr/sbin/softwareupdate" --install "$update"
  "/bin/echo" "✅ Installed $update."
done <<< "$xcodeCommandLineTools"


# Verify successful installation.
xcodeCheck
if [[ "$xcodeCLI" = "missing" ]]; then
  "/bin/echo" "❌ ERROR: Xcode Command Line Tool install was unsuccessful."
  exit 1
else
  "/bin/echo" "✅ Installed Xcode Command Line Tools."
fi


exit 0
