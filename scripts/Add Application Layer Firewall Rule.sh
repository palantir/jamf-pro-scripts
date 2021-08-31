#!/bin/sh

###
#
#            Name:  Add Application Layer Firewall Rule.sh
#     Description:  Adds a firewall rule to allow or deny a specified process.
#         Created:  2021-04-26
#   Last Modified:  2021-08-31
#         Version:  1.1.1
#
#
# Copyright 2021 Palantir Technologies, Inc.
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



# Jamf Pro script argument: "App Path"
# Full file path to target application.
appPath="$4"
# Jamf Pro script argument: "Allow or Deny"
# If not set to "deny", assumes "allow".
allowOrDeny="$5"
socketfilterfwPath="/usr/libexec/ApplicationFirewall/socketfilterfw"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$appPath" ] || [ -z "$allowOrDeny" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments


# Clear existing app rule (if present).
if "$socketfilterfwPath" --list | /usr/bin/grep -q "$appPath"; then
  "$socketfilterfwPath" --remove "$appPath"
fi


# Block or unblock specified app on application later firewall.
if [ -e "$appPath" ]; then
  "$socketfilterfwPath" --add "$appPath"
  if [ "$allowOrDeny" = "deny" ]; then
    "$socketfilterfwPath" --blockapp "$appPath"
  else
    "$socketfilterfwPath" --unblockapp "$appPath"
  fi
else
  echo "❌ ERROR: Application not found at ${appPath}, unable to proceed."
  exit 1
fi



exit 0
