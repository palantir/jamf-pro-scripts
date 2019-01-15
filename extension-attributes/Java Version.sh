#!/bin/bash

###
#
#            Name:  Java Version.sh
#     Description:  Returns Java version(s) (if installed).
#         Created:  2017-06-15
#   Last Modified:  2019-01-15
#         Version:  2.0
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
javaVersionList=""



########## main process ##########



# check for presence of Java install(s) and report version(s) accordingly
if [[ -d "$javaVMPath" ]]; then
  javaVMList=$("/bin/ls" -1 "$javaVMPath")
  while read javaInstall; do
    javaBinPath="$javaVMPath/$javaInstall/Contents/Home/bin/java"
    if [[ -e "$javaBinPath" ]]; then
      javaVersion=$("$javaBinPath" -version 2>&1 | "/usr/bin/awk" '/version/ {print}')
      if [[ "$javaVersionList" = "" ]]; then
        javaVersionList="$javaVersion"
      else
        javaVersionList="$javaVersionList\n$javaVersion"
      fi
    fi
  done <<< "$javaVMList"
fi


"/usr/bin/printf" "<result>$javaVersionList</result>"



exit 0
