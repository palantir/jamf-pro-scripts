#!/bin/sh

###
#
#            Name:  Homebrew Binaries.sh
#     Description:  Returns list of Homebrew-installed binaries (if Homebrew is
#                   installed). Runs as currently logged-in user to avoid
#                   running in root context.
#         Created:  2020-02-10
#   Last Modified:  2020-11-02
#         Version:  1.0.2
#
#
# Copyright 2020 Palantir Technologies, Inc.
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
brewPath="/usr/local/bin/brew"



########## main process ##########



# Check for presence of Homebrew and get list of installed binaries.
if [ -e "$brewPath" ]; then
  brewBinaryList=$(sudo -u "$loggedInUser" "$brewPath" list --formula 2>&1)
else
  brewBinaryList=""
fi


# Report result.
echo "<result>$brewBinaryList</result>"



exit 0
