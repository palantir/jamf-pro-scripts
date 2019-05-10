#!/bin/bash

###
#
#            Name:  Git Homebrew Version.sh
#     Description:  Returns Git Homebrew version (if installed).
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  1.3.1
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



gitPath="/usr/local/bin/git"



########## main process ##########



if [[ -f "$gitPath" ]]; then
  gitVersion=$("$gitPath" --version | "/usr/bin/awk" '{print $NF}')
else
  gitVersion=""
fi


"/bin/echo" "<result>$gitVersion</result>"



exit 0
