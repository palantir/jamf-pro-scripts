#!/bin/sh

###
#
#            Name:  Osquery Version.sh
#     Description:  Returns Osquery version (if installed).
#         Created:  2017-07-13
#   Last Modified:  2020-01-07
#         Version:  2.2
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



osquerydPath="/usr/local/bin/osqueryd"



########## main process ##########



# Check for presence of target binary and get version.
if [ -e "$osquerydPath" ]; then
  osqueryVersion=$("$osquerydPath" --version | /usr/bin/awk '{print $3}')
else
  osqueryVersion=""
fi


# Report result.
/bin/echo "<result>$osqueryVersion</result>"



exit 0
