#!/bin/sh

###
#
#            Name:  Homebrew Shallow Clones.sh
#     Description:  Reports whether any Homebrew taps are shallow clones.
#         Created:  2021-07-29
#   Last Modified:  2022-3-29
#         Version:  1.0.1.1
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
# Determine Homebrew directory based on platform architecture,
# use to define Homebrew binary paths.
architectureCheck=$(/usr/bin/arch)
if [ "$architectureCheck" = "arm64" ]; then
  brewPrefix="/opt/homebrew/bin"
else
  brewPrefix="/usr/local/bin"
fi
brewPath="${brewPrefix}/brew"
tmpFilePath="/tmp/brewTapPaths.txt"



########## main process ##########



# Skip check if Homebrew is not installed.
if [ ! -e "$brewPath" ]; then
  brewShallowClones=""
else
  # Get file paths of all Homebrew taps.
  sudo -u "$loggedInUser" "$brewPath" tap-info --installed | /usr/bin/awk -F'[(]' '/\(/ {print $1}' | /usr/bin/sed 's/ *$//' > "$tmpFilePath"

  # Determine if any Homebrew taps are shallow clones.
  if [ -n "$(/bin/cat "$tmpFilePath")" ]; then
    while read -r tapPath; do
      cd "$tapPath" || exit
      if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
        brewShallowClones="true"
        break
      else
        brewShallowClones="false"
      fi
    done < "$tmpFilePath"
  else
    brewShallowClones="no taps found"
  fi

  # Clean up temp resources.
  /bin/rm "$tmpFilePath"
fi


# Report results.
echo "<result>${brewShallowClones}</result>"



exit 0
