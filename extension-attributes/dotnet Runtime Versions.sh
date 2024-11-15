#!/bin/sh

###
#
#            Name:  dotnet Runtime Versions.sh
#     Description:  Reports versions of all .NET runtimes installed.
#         Created:  2021-08-04
#   Last Modified:  2024-11-15
#         Version:  1.1.2
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
version=""



########## function-ing ##########



# Exits if root is the currently logged-in user, or no logged-in user is detected.
check_logged_in_user () {
  if [ "$loggedInUser" = "root" ] || [ -z "$loggedInUser" ]; then
    echo "Nobody is logged in, no action required."
    exit 0
  fi
}



########## main process ##########



# Check script prerequisites.
check_logged_in_user


# List .NET runtimes and get version strings.
if [ -e "/usr/local/share/dotnet/dotnet" ]; then
  version=$(sudo -u "$loggedInUser" /usr/local/share/dotnet/dotnet --list-runtimes | /usr/bin/awk '/.NETCore.App/ {print $2}')
fi


# Report results.
echo "<result>${version}</result>"



exit 0
