#!/bin/bash

###
#
#            Name:  Install Xcode Command Line Tools.sh
#     Description:  Installs Xcode Command Line Tools.
#         Created:  2016-01-31
#   Last Modified:  2019-05-09
#         Version:  5.2.2
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



xcodeCheck=$("/usr/bin/xcode-select" -p 2>&1)



########## main process ##########



# exit if Xcode Command Line Tools are already installed
if [[ "$xcodeCheck" = "/Applications/Xcode.app/Contents/Developer" || "$xcodeCheck" = "/Library/Developer/CommandLineTools" ]]; then
  "/bin/echo" "Xcode Command Line Tools already installed, no action required."
  exit 0
fi


# install Xcode Command Line Tools via Software Update
"/usr/bin/touch" "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
xcodeCommandLineTools=$("/usr/sbin/softwareupdate" --list 2>&1 | \
  "/usr/bin/awk" -F"[*] " '/\* Command Line Tools/ {print $NF}')
while read -r update; do
  "/usr/sbin/softwareupdate" --install "$update"
  "/bin/echo" "✅ Installed $update."
done <<< "$xcodeCommandLineTools"


exit 0
