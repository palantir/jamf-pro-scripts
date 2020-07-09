#!/bin/sh

###
#
#            Name:  Firmware Password Set.sh
#     Description:  Reports whether a firmware password is set.
#         Created:  2020-01-17
#   Last Modified:  2020-07-08
#         Version:  1.0.1
#
#
# Copyright 2020 Palantir Technologies, Inc.
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



# Display whether or not a firmware password is set.
firmwarePasswordSet=$(/usr/sbin/firmwarepasswd -check | /usr/bin/awk '/Enabled/ {print $NF}')


# Report results.
echo "<result>$firmwarePasswordSet</result>"



exit 0
