#!/bin/sh

###
#
#            Name:  Reset Individual Spotlight Index Entry.sh
#      Description: Resets Spotlight index entry for target path.
#          Created: 2017-06-29
#    Last Modified: 2020-09-09
#          Version: 1.2.2
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



# Jamf Pro script parameter: "Target Path"
# Use full path to target file in the variable.
resetPath="$4"
spotlightPlist="/.Spotlight-V100/VolumeConfiguration.plist"
macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $1}')
macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F . '{print $2}')



########## function-ing ##########



# Exits with error if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$resetPath" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}


# Exits with error if running an unsupported version of macOS.
check_macos_version () {
  if [ "$macOSVersionMajor" -gt 10 ] || [ "$macOSVersionMinor" -gt 14 ]; then
    /bin/echo "❌ ERROR: macOS version ($(/usr/bin/sw_vers -productVersion)) unrecognized or incompatible, unable to proceed."
    exit 1
  fi
}


# Restarts the Spotlight service.
metadata_reset () {
  /bin/launchctl stop com.apple.metadata.mds
  /bin/launchctl start com.apple.metadata.mds
}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments
check_macos_version


# Verify $resetPath exists on the system.
if [ ! -e "$resetPath" ]; then
  echo "Target path $resetPath does not exist, unable to proceed. Please check Target Path parameter in Jamf Pro policy."
  exit 74
fi


# Add target path to Spotlight exclusions.
/usr/bin/defaults write "$spotlightPlist" Exclusions -array-add "$resetPath"
metadata_reset
echo "Added $resetPath to Spotlight exclusions."


# Remove target path from Spotlight exclusions.
/usr/bin/defaults delete "$spotlightPlist" Exclusions
metadata_reset
echo "Removed $resetPath from Spotlight exclusions. Target path should appear in Spotlight search results shortly."



exit 0
