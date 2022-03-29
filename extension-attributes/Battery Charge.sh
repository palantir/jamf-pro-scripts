#!/bin/sh

###
#
#            Name:  Battery Charge.sh
#     Description:  Reports current battery charge as a percentage.
#         Created:  2021-04-12
#   Last Modified:  2022-02-29
#         Version:  1.0.0.1
#
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
#
###



########## main process ##########



# Get battery charge percentage.
batteryChargePercentage=$(/usr/bin/pmset -g batt | /usr/bin/awk '/%/ {print $3}' | /usr/bin/tr -d '%;' | /usr/bin/bc)


# Report results.
echo "<result>${batteryChargePercentage}</result>"



exit 0
