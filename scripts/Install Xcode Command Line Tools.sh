#!/bin/sh

###
#
#            Name:  Install Xcode Command Line Tools.sh
#     Description:  Installs Xcode Command Line Tools.
#         Created:  2016-01-31
#   Last Modified:  2021-08-17
#         Version:  5.6.1
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



macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')
macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')



########## function-ing ##########



# Checks current state of Xcode Command Line Tools installation.
xcode_check () {
  xcodeSelectCheck=$(/usr/bin/xcode-select --print-path 2>&1)
  if [ "$xcodeSelectCheck" = "/Library/Developer/CommandLineTools" ]; then
    xcodeCLI="installed"
  else
    xcodeCLI="missing"
  fi
}


# Exits if Mac is not running macOS 10 or later.
check_macos () {
  if [ "$macOSVersionMajor" -lt 10 ]; then
    echo "❌ ERROR: This Mac is running an incompatible operating system $(/usr/bin/sw_vers -productVersion)), unable to proceed."
    exit 72
  fi
}



########## main process ##########



# Exit if Xcode Command Line Tools are already installed.
xcode_check
if [ "$xcodeCLI" = "installed" ]; then
  echo "Xcode Command Line Tools already installed, no action required."
  exit 0
else
  /usr/bin/xcode-select --reset
fi


# Exit if Mac is not running macOS 10.
check_macos


# Get current Xcode Command Line Tools label via softwareupdate.
/usr/bin/touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
if [ "$macOSVersionMajor" -eq 10 ] && [ "$macOSVersionMinor" -lt 15 ]; then
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
  echo "❌ ERROR: Xcode Command Line Tool install was unsuccessful."
  exit 1
else
  /bin/rm -f "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  echo "✅ Installed Xcode Command Line Tools."
fi


exit 0
