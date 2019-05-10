#!/bin/bash

###
#
#            Name:  Xcode Command Line Tools.sh
#     Description:  Returns whether Xcode Command Line Tools are installed
#                   (either standalone or as part of Xcode.app bundle).
#         Created:  2016-12-09
#   Last Modified:  2018-06-20
#         Version:  1.2.1
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



xcodeCheck=$("/usr/bin/xcode-select" -p 2>&1)



########## main process ##########



if [[ "$xcodeCheck" = "/Applications/Xcode.app/Contents/Developer" ]]; then
  xcodeCLI="Bundled with Xcode"
elif [[ "$xcodeCheck" = "/Library/Developer/CommandLineTools" ]]; then
  xcodeCLI="Standalone"
else
  xcodeCLI=""
fi


"/bin/echo" "<result>$xcodeCLI</result>"



exit 0
