#!/bin/sh

###
#
#            Name:  Apple Security Chip.sh
#     Description:  Reports which generation of Apple Security Chip is present
#                   (if any).
#         Created:  2019-08-29
#   Last Modified:  2020-07-08
#         Version:  1.0.1
#
#
# Copyright 2019 Palantir Technologies, Inc.
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



########## main process ##########



echo "<result>$(/usr/sbin/system_profiler SPiBridgeDataType | /usr/bin/awk -F ': ' '/Model Name/ {print $NF}')</result>"



exit 0
