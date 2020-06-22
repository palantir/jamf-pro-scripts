#!/bin/bash

###
#
#            Name:  Install Xcode Command Line Tools.sh
#     Description:  Installs Xcode Command Line Tools.
#         Created:  2016-01-31
#   Last Modified:  2020-06-22
#         Version:  5.4.1
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



# Checks current state of Xcode Command Line Tools installation.
function xcode_check {
  xcodeSelectCheck=$(/usr/bin/xcode-select -p 2>&1)
  if [ "$xcodeSelectCheck" = "/Applications/Xcode.app/Contents/Developer" ] || [ "$xcodeSelectCheck" = "/Library/Developer/CommandLineTools" ]; then
    xcodeCLI="installed"
  else
    xcodeCLI="missing"
  fi
}


# Exits if Mac is not running macOS 10.
function check_macos {
  macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')
  macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
  if [[ $macOSVersionMajor -ne 10 ]]; then
    /bin/echo "❌ ERROR: This script is only supported in macOS 10 (version detected: $(/usr/bin/sw_vers -productVersion)), unable to proceed."
    exit 72
  fi
}



########## main process ##########



# Exit if Xcode Command Line Tools are already installed.
xcode_check
if [ "$xcodeCLI" = "installed" ]; then
  /bin/echo "Xcode Command Line Tools already installed, no action required."
  exit 0
fi


# Exit if Mac is not running macOS 10.
check_macos


# Get current Xcode Command Line Tools label via softwareupdate.
/usr/bin/touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
if [[ "$macOSVersionMinor" -lt 15 ]]; then
  xcodeCommandLineTools=$(/usr/sbin/softwareupdate --list 2>&1 | \
    /usr/bin/awk -F"[*] " '/\* Command Line Tools/ {print $NF}' | \
    /usr/bin/sed 's/^ *//' | \
    /usr/bin/tail -1)
else
  xcodeCommandLineTools=$(/usr/sbin/softwareupdate --list 2>&1 | \
    /usr/bin/awk -F: '/Label: Command Line Tools for Xcode/ {print $NF}' | \
    /usr/bin/sed 's/^ *//' | \
    /usr/bin/tail -1)
fi


# Install Xcode Command Line Tools via softwareupdate.
/usr/sbin/softwareupdate --install "$xcodeCommandLineTools"


# Verify successful installation.
xcode_check
if [ "$xcodeCLI" = "missing" ]; then
  /bin/echo "❌ ERROR: Xcode Command Line Tool install was unsuccessful."
  exit 1
else
  /bin/echo "✅ Installed Xcode Command Line Tools."
fi


exit 0
