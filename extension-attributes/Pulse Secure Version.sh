#!/bin/bash

###
#
#            Name:  Pulse Secure Version.sh
#     Description:  Returns Pulse Secure or Junos Pulse version (if installed).
#         Created:  2017-09-22
#   Last Modified:  2018-06-20
#         Version:  1.1.1
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



pulsePaths=(
  "/Applications/Junos Pulse.app"
  "/Applications/Pulse Secure.app"
)



########## main process ##########



# check for presence of Junos Pulse and Pulse Secure applications and report versions from versioninfo.ini
for pulseApp in "${pulsePaths[@]}"; do
  if [[ -d "$pulseApp" ]]; then
    versionInfoIniPath="$pulseApp/Contents/Plugins/ConnectionStore/versionInfo.ini"
    if [[ -e "$versionInfoIniPath" ]]; then
      pulseVersion=$("/usr/bin/awk" -F\= '/DisplayVersion/ {print $NF}' "$versionInfoIniPath")
    else
    	pulseVersion="Unknown"
    fi
    break
  else
    pulseVersion=""
  fi
done


"/bin/echo" "<result>$pulseVersion</result>"



exit 0
