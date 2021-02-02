#!/bin/sh

###
#
#            Name:  Homebrew Version.sh
#     Description:  Returns Homebrew version (if installed). Runs as currently
#                   logged-in user to avoid running in root context.
#         Created:  2016-06-06
#   Last Modified:  2021-02-02
#         Version:  2.5
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
# Determine Homebrew directory based on platform architecture,
# use to define Homebrew binary paths.
architectureCheck=$(/usr/bin/arch)
if [ "$architectureCheck" = "arm64" ]; then
  brewPrefix="/opt/homebrew/bin"
else
  brewPrefix="/usr/local/bin"
fi
brewPath="$brewPrefix/brew"



########## main process ##########



# Check for presence of target binary and get version.
if [ -e "$brewPath" ]; then
  brewCheck=$(sudo -u "$loggedInUser" "$brewPath" --version 2>&1)
else
  brewCheck=""
fi


# Report result.
echo "<result>$brewCheck</result>"



exit 0
