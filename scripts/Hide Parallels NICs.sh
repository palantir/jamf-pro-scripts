#!/bin/sh

###
#
#            Name:  Hide Parallels NICs.sh
#     Description:  Hides Parallels NICs from the system's ifconfig list.
#         Created:  2017-03-14
#   Last Modified:  2020-07-08
#         Version:  1.2.1
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



parallelsCommandLineTool="/usr/local/bin/prlsrvctl"



########## main process ##########



if [ -e "$parallelsCommandLineTool" ]; then
  "$parallelsCommandLineTool" net set Host-Only --connect-host-to-net off
  "$parallelsCommandLineTool" net set Shared --connect-host-to-net off
  echo "Removed Parallels VNICs from ifconfig list."
else
  echo "Parallels command line tool not found, unable to proceed."
  exit 1
fi



exit 0
