#!/bin/sh

###
#
#            Name:  Java Version.sh
#     Description:  Returns Java version(s) (if installed).
#         Created:  2017-06-15
#   Last Modified:  2020-07-08
#         Version:  2.1.1
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



javaVMPath="/Library/Java/JavaVirtualMachines"
javaVersionListTempFile="/tmp/javaVersionList.txt"



########## main process ##########



# Initialize temp file.
if [ -e "$javaVersionListTempFile" ]; then
  /bin/rm "$javaVersionListTempFile"
fi
/usr/bin/touch "$javaVersionListTempFile"



# Check for presence of Java install(s) and get version(s).
if [ -d "$javaVMPath" ]; then
  /usr/bin/find "$javaVMPath" -maxdepth 1 -name "*.jdk" | /usr/bin/sort | while read -r javaInstall; do
    javaBinPath="$javaInstall/Contents/Home/bin/java"
    if [ -e "$javaBinPath" ]; then
      javaVersion=$("$javaBinPath" -version 2>&1 | /usr/bin/awk '/version/ {print}')
      echo "$javaVersion" >> "$javaVersionListTempFile"
    fi
  done
fi


# Report result.
echo "<result>$(/bin/cat $javaVersionListTempFile)</result>"



exit 0
