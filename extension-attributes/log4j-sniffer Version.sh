#!/bin/sh

###
#
#            Name:  log4j-sniffer Version.sh
#     Description:  Reports version of log4j-sniffer (if installed in
#                   /usr/local/bin/).
#         Created:  2021-12-20
#   Last Modified:  2022-04-05
#         Version:  1.0.1
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
###



########## variable-ing ##########



binaryPath="/usr/local/bin/log4j-sniffer"
binaryVersion=""



########## main process ##########



# Collect binary version.
if [ -e "$binaryPath" ]; then
  binaryVersion=$("$binaryPath" --version | /usr/bin/awk '/log4j-sniffer version/ {print $NF}')
fi


# Report results.
echo "<result>${binaryVersion}</result>"



exit 0
