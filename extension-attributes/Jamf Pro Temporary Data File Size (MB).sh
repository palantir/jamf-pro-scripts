#!/bin/sh

###
#
#            Name:  Jamf Pro Temporary Data File Size (MB).sh
#     Description:  Reports the total size (in megabytes) of the contents of /Library/Application Support/JAMF/tmp/.
#         Created:  2024-12-10
#   Last Modified:  2025-04-28
#         Version:  1.0.1
#
# Copyright 2024 Palantir Technologies, Inc.
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



jamfProTmpPath="/Library/Application Support/JAMF/tmp"



########## main process ##########



# Get the size of the Jamf Pro tmp folder.
if [ -d "$jamfProTmpPath" ]; then
  totalFileSizeMB=$(/usr/bin/du -sm "$jamfProTmpPath" | /usr/bin/awk '{print $1}')
fi


# Report results.
echo "<result>${totalFileSizeMB}</result>"



exit 0
