#!/bin/bash

###
#
#            Name:  Java Version.sh
#     Description:  Returns Java version (if installed).
#         Created:  2017-06-15
#   Last Modified:  2018-06-20
#         Version:  1.3.1
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



########## main process ##########



# check for presence of Java installs and report version accordingly
if [[ -d "$javaVMPath" ]]; then
  javaVMList=$("/bin/ls" "$javaVMPath")
  if [[ "$javaVMList" = "" ]]; then
    javaVersion=""
  else
  	javaVersion=$("/usr/bin/java" -version 2>&1 | "/usr/bin/awk" -F\" '/java version/ {print $2}')
  fi
else
  javaVersion=""
fi


"/bin/echo" "<result>$javaVersion</result>"



exit 0
