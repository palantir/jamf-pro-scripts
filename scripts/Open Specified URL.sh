#!/bin/sh

###
#
#            Name:  Open Specified URL.sh
#     Description:  Opens specified URL in system default browser.
#         Created:  2016-06-06
#   Last Modified:  2020-07-08
#         Version:  2.1.1
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



# Jamf Pro script parameter "URL"
targetURL="$4"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetURL" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}



########## main process ##########



# Exit if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments


# Opens specified URL.
/usr/bin/open "$targetURL"



exit 0
