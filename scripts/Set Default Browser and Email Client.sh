#!/bin/bash

###
#
#            Name:  Set Default Browser and Email Client.sh
#     Description:  Sets default browser and email client for currently logged-in user.
#         Created:  2017-09-06
#   Last Modified:  2018-06-20
#         Version:  1.4.1
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



# Jamf script parameter "Browser Agent String"
# should be in the format domain.vendor.app (e.g. com.apple.safari)
browserAgentString="$4"
# Jamf script parameter "Email Agent String"
# should be in the format domain.vendor.app (e.g. com.apple.mail)
emailAgentString="$5"
loggedInUser=$("/usr/bin/stat" -f%Su "/dev/console")
loggedInUserHome=$("/usr/bin/dscl" . -read "/Users/$loggedInUser" NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
launchServicesPlistFolder="$loggedInUserHome/Library/Preferences/com.apple.LaunchServices"
launchServicesPlist="$launchServicesPlistFolder/com.apple.launchservices.secure.plist"
plistbuddyPath="/usr/libexec/PlistBuddy"
plistbuddyPreferences=(
  "Add :LSHandlers:0:LSHandlerRoleAll string $browserAgentString"
  "Add :LSHandlers:0:LSHandlerURLScheme string http"
  "Add :LSHandlers:1:LSHandlerRoleAll string $browserAgentString"
  "Add :LSHandlers:1:LSHandlerURLScheme string https"
  "Add :LSHandlers:2:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:2:LSHandlerContentType string public.html"
  "Add :LSHandlers:3:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:3:LSHandlerContentType string public.url"
  "Add :LSHandlers:4:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:4:LSHandlerContentType string public.xhtml"
  "Add :LSHandlers:5:LSHandlerRoleAll string $emailAgentString"
  "Add :LSHandlers:5:LSHandlerURLScheme string mailto"
)
lsregisterPath="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$browserAgentString"
    "$emailAgentString"
  )
  for argument in "${jamfArguments[@]}"; do
    if [[ "$argument" = "" ]]; then
      "/bin/echo" "Undefined Jamf argument, unable to proceed."
      exit 74
    fi
  done
}



########## main process ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments


# clear out LSHandlers array data from $launchServicesPlist, or create new plist if file does not exist
if [[ -e "$launchServicesPlist" ]]; then
  "$plistbuddyPath" -c "Delete :LSHandlers" "$launchServicesPlist"
  "/bin/echo" "Reset LSHandlers array from $launchServicesPlist."
else
  "/bin/mkdir" -p "$launchServicesPlistFolder"
  "$plistbuddyPath" -c "Save" "$launchServicesPlist"
  "/bin/echo" "Created $launchServicesPlist."
fi


# add new LSHandlers array
"$plistbuddyPath" -c "Add :LSHandlers array" "$launchServicesPlist"
"/bin/echo" "Initialized LSHandlers array."


# sets handler for each URL scheme and content type to specified browser and email client
for plistbuddyCommand in "${plistbuddyPreferences[@]}"; do
  "$plistbuddyPath" -c "$plistbuddyCommand" "$launchServicesPlist"
  if [[ "$plistbuddyCommand" =~ "$browserAgentString" ]] || [[ "$plistbuddyCommand" =~ "$emailAgentString" ]]; then
    arrayEntry=$("/bin/echo" "$plistbuddyCommand" | "/usr/bin/awk" -F: '{print $2 ":" $3 ":" $4}' | "/usr/bin/sed" 's/ .*//')
    prefLabel=$("/bin/echo" "$plistbuddyCommand" | "/usr/bin/awk" '{print $4}')
    "/bin/echo" "Set $arrayEntry to $prefLabel."
  fi
done


# fix permissions on $launchServicesPlistFolder
"/usr/sbin/chown" -R "$loggedInUser" "$launchServicesPlistFolder"
"/bin/echo" "Fixed permissions on $launchServicesPlistFolder."


# reset Launch Services database
"$lsregisterPath" -kill -r -domain local -domain system -domain user
"/bin/echo" "Reset Launch Services database. A restart may also be required for these new default client changes to take effect."



exit 0
