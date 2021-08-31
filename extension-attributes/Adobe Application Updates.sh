#!/bin/sh

###
#
#            Name:  Adobe Application Updates.sh
#     Description:  Runs Adobe Remote Update Manager (if installed) to report
#                   any Adobe applications with pending updates.
#         Created:  2021-06-17
#   Last Modified:  2021-08-31
#         Version:  1.0.1
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



adobeRUMPath="/usr/local/bin/RemoteUpdateManager"
outputPath="/tmp/rumUpdates.txt"
rumUpdates=""



########## main process ##########


# Initialize output file.
if [ -e "$outputPath" ]; then
  /bin/rm "$outputPath"
fi
/usr/bin/touch "$outputPath"


# List all available Adobe application updates.
if [ -e "$adobeRUMPath" ]; then
  "$adobeRUMPath" --action=list > "$outputPath"
  if /usr/bin/grep -q "Following Updates are applicable" "$outputPath"; then
    rumUpdates="$(/bin/cat "$outputPath")"
  fi
fi


# Report results.
echo "<result>$rumUpdates</result>"


# Clean up.
/bin/rm "$outputPath"



exit 0
