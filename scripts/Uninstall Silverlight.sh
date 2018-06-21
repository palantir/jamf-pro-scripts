#!/bin/bash

###
#
#            Name:  Uninstall Silverlight.sh
#     Description:  Uninstalls Silverlight. Quits all running processes,
#                   unloads all associated launchd tasks, then removes all
#                   associated files.
#                   Based on uninstaller-template (see script-templates).
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  3.1.1
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
loggedInUserHome=$("/usr/bin/dscl" . -read "/Users/$loggedInUser" NFSHomeDirectory | "/usr/bin/awk" '{print $NF}')
loggedInUserUID=$("/usr/bin/id" -u "$loggedInUser")
# a list of full file paths to target for launchd unload and deletion
resourceFiles=(
  "/Library/Internet Plug-Ins/Silverlight.plugin"
  "/Library/Internet Plug-Ins/WPFe.plugin"
  "$loggedInUserHome/Library/Application Support/Microsoft/Silverlight"
  "/var/db/receipts/com.microsoft.SilverlightInstaller.bom"
  "/var/db/receipts/com.microsoft.SilverlightInstaller.plist"
)
launchAgentCheck=$("/bin/launchctl" asuser "$loggedInUserUID" "/bin/launchctl" list)
launchDaemonCheck=$("/bin/launchctl" list)



########## function-ing ##########



# remove all remaining resource files
delete_files () {
  "/bin/echo" "Removing files..."
  for targetFile in "${resourceFiles[@]}"; do
    # if file exists
    if [[ -e "$targetFile" ]]; then
      # if file is a plist
      if [[ "$targetFile" == *".plist" ]]; then
        # if plist is loaded as LaunchAgent or LaunchDaemon, unload it
        justThePlist=$("/usr/bin/basename" "$targetFile" | "/usr/bin/awk" -F.plist '{print $1}')
        if [[ "$launchAgentCheck" =~ "$justThePlist" ]]; then
          "/bin/launchctl" asuser "$loggedInUserUID" "/bin/launchctl" unload "$targetFile"
          "/bin/echo" "Unloaded LaunchAgent at $targetFile."
        elif [[ "$launchDaemonCheck" =~ "$justThePlist" ]]; then
          "/bin/launchctl" unload "$targetFile"
          "/bin/echo" "Unloaded LaunchDaemon at $targetFile."
        fi
      fi
      # disable kexts, delete all other file types
      if [[ "$targetFile" == *".kext" ]]; then
        appKextKillPath="/tmp/$scriptName"
        "/bin/mkdir" -p "$appKextKillPath"
        "/bin/mv" "$targetFile" "$appKextKillPath"
        "/bin/echo" "Moved $targetFile to $appKextKillPath. File will be deleted on subsequent restart."
      else
        "/bin/rm" -rf "$targetFile"
        "/bin/echo" "Removed $targetFile."
      fi
    fi
  done
}



########## main process ##########



if [[ "$resourceFiles" != "" ]]; then
  delete_files
fi



exit 0
