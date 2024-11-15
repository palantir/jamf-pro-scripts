#!/bin/sh

###
#
#            Name:  Wi-Fi Network.sh
#     Description:  Displays the current Wi-Fi network for the default network adapter (en0).
#         Created:  2024-10-17
#   Last Modified:  2024-11-15
#         Version:  1.0.1
#
#
# Copyright 2024 Palantir Technologies, Inc.
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
echo "<result>$(/usr/sbin/networksetup -getairportnetwork en0 2>"/dev/null" | /usr/bin/awk -F 'Current Wi-Fi Network: ' '{print $2}')</result>"



exit 0
