#!/bin/sh

###
#
#            Name:  Wi-Fi Network Priority.sh
#     Description:  Lists all preferred Wi-Fi networks in order of priority.
#         Created:  2016-06-06
#   Last Modified:  2021-11-03
#         Version:  2.0.1
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
###



########## variable-ing ##########



preferredWiFiNetworks="$(/usr/sbin/networksetup -listpreferredwirelessnetworks en0 | /usr/bin/sed 1d | /usr/bin/sed 's/^	*//g')"



########## main process ##########



echo "<result>${preferredWiFiNetworks}</result>"



exit 0
