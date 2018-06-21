#!/bin/sh

###
#
#            Name:  Install Homebrew.sh
#     Description:  Installs Homebrew as currently logged-in user.
#         Created:  2016-01-31
#   Last Modified:  2018-06-20
#         Version:  6.0.1
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
xcodeCheck=$("/usr/bin/xcode-select" -p 2>&1)
brewDirectories=(
  "/usr/local/bin"
  "/usr/local/share"
  "/usr/local/etc"
  "$loggedInUserHome/Library/Caches/Homebrew"
)
brewCLI="/usr/local/bin/brew"



########## main process ##########



# exit if Xcode Command Line Tools are missing
if [[ "$xcodeCheck" = "/Applications/Xcode.app/Contents/Developer" || "$xcodeCheck" = "/Library/Developer/CommandLineTools" ]]; then
	"/bin/echo" "✅ Verified Xcode Command Line Tools are installed."
else
  "/bin/echo" "❌ ERROR: Missing Xcode Command Line Tools. Install Xcode (via App Store) or the command line tools (via policy or manual install), then rerun this script."
  exit 1
fi


# exit if Homebrew is already installed
if [[ -e "$brewCLI" ]]; then
  "/bin/echo" "Homebrew already installed, no action required."
  exit 0
fi


# Homebrew directory creation and permissions
for dir in "${brewDirectories[@]}"; do
  if [[ ! -d "$dir" ]]; then
    "/bin/mkdir" -p "$dir"
  fi
  "/usr/sbin/chown" -R "$loggedInUser":admin "$dir"
done


# install Homebrew as user
"/usr/bin/sudo" -u "$loggedInUser" "/usr/bin/ruby" -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" <"/dev/null"
"/bin/echo" "✅ Installed Homebrew."



exit 0
