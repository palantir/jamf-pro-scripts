#!/bin/sh

###
#
#            Name:  Google Santa Version.sh
#     Description:  Returns Google Santa version (if installed).
#         Created:  2017-12-13
#   Last Modified:  2020-07-08
#         Version:  1.2.1
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



googleSantaPath="/usr/local/bin/santactl"



########## main process ##########



# Check for presence of target binary and get version.
if [ -e "$googleSantaPath" ]; then
  googleSantaVersion=$("$googleSantaPath" version | /usr/bin/awk '/santactl/ {print $NF}')
else
  googleSantaVersion=""
fi


# Report result.
echo "<result>$googleSantaVersion</result>"



exit 0
