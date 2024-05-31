#!/bin/sh

###
#
#            Name:  Kernel Extensions (Third-Party).sh
#     Description:  Displays all third-party kernel extensions installed.
#         Created:  2016-08-17
#   Last Modified:  2024-05-30
#         Version:  2.0
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



########## main process ##########



# Report results.
echo "<result>$(/usr/bin/kmutil showloaded --list-only 2>"/dev/null" | /usr/bin/grep -v 'com.apple' | /usr/bin/awk '{print $6}' | /usr/bin/sort)</result>"



exit 0
