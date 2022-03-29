#!/bin/sh

###
#
#            Name:  Printer Drivers.sh
#     Description:  Reports list of installed printer drivers.
#         Created:  2017-06-16
#   Last Modified:  2022-03-29
#         Version:  3.1.0.1
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



printerDriverList=$(/usr/sbin/lpinfo -m | \
  /usr/bin/awk -F'.gz|.ppd' '{print $NF}' | \
  /usr/bin/sed 's/^ *//' | \
  /usr/bin/grep -v "everywhere IPP Everywhere" | \
  /usr/bin/grep -v "raw Raw Queue")



########## main process ##########



# Report printer driver list.
echo "<result>${printerDriverList}</result>"



exit 0
