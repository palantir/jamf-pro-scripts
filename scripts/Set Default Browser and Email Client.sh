#!/bin/sh

###
#
#            Name:  Set Default Browser and Email Client.sh
#     Description:  Sets default browser and email client for currently logged-in user by writing to the account's LaunchServices plist. In modern macOS releases, a prompt logout or restart is required to prevent these settings from being reverted by the system. This script is intended to be run during new device setup workflows; since LSHandlers is cleared out when the script is run, all user-defined default applications are reset in the process of setting these new defaults.
#         Created:  2017-09-06
#   Last Modified:  2024-01-22
#         Version:  1.5
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



# To obtain identifiers for your desired default applications, run: codesign --display --requirements - /path/to/app
# Jamf Pro script parameter "Browser Bundle Identifier"
browserBundleID="${4}"
# Jamf Pro script parameter "Email Bundle Identifier"
emailBundleID="${5}"
loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/${loggedInUser}" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
launchServicesPlistFolder="${loggedInUserHome}/Library/Preferences/com.apple.LaunchServices"
launchServicesPlist="${launchServicesPlistFolder}/com.apple.launchservices.secure.plist"
plistbuddyPath="/usr/libexec/PlistBuddy"
lsregisterPath="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {

  if [ -z "$browserBundleID" ] || [ -z "$emailBundleID" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi

}


# Exits if root is the currently logged-in user, or no logged-in user is detected.
check_logged_in_user () {

  if [ "$loggedInUser" = "root" ] || [ -z "$loggedInUser" ]; then
    echo "Nobody is logged in, so this script cannot be run."
    exit 0
  fi

}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments
check_logged_in_user


# Clear out LSHandlers array data from LaunchServices plist, or create new plist if file does not exist.
if [ -e "$launchServicesPlist" ]; then
  "$plistbuddyPath" -c "Delete :LSHandlers" "$launchServicesPlist"
  echo "Reset LSHandlers array in ${launchServicesPlist}."
else
  /bin/mkdir -p "$launchServicesPlistFolder"
  "$plistbuddyPath" -c "Save" "$launchServicesPlist"
  echo "Created ${launchServicesPlist}."
fi


# Add new LSHandlers array.
"$plistbuddyPath" -c "Add :LSHandlers array" "$launchServicesPlist"
echo "Initialized LSHandlers array."


# Set handler for each URL scheme and content type to specified browser and email client.
"$plistbuddyPath" -c "Add :LSHandlers:0:LSHandlerRoleAll string ${browserBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:0:LSHandlerURLScheme string http" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:1:LSHandlerRoleAll string ${browserBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:1:LSHandlerURLScheme string https" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:2:LSHandlerRoleViewer string ${browserBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:2:LSHandlerContentType string public.html" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:3:LSHandlerRoleViewer string ${browserBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:3:LSHandlerContentType string public.url" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:4:LSHandlerRoleViewer string ${browserBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:4:LSHandlerContentType string public.xhtml" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:5:LSHandlerRoleAll string ${emailBundleID}" "$launchServicesPlist"
"$plistbuddyPath" -c "Add :LSHandlers:5:LSHandlerURLScheme string mailto" "$launchServicesPlist"


# Fix ownership on logged-in user's LaunchServices plist folder.
/usr/sbin/chown -R "$loggedInUser" "$launchServicesPlistFolder"
echo "Set folder ownership on ${launchServicesPlistFolder} to ${loggedInUser}."


# Reset Launch Services database.
"$lsregisterPath" -kill -r -domain local -domain system -domain user
echo "Reset Launch Services database. A prompt logout or restart is required for these new default client settings to take effect."



exit 0
