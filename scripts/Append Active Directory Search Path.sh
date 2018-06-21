#!/bin/sh

###
#
#            Name:  Append Active Directory Search Path.sh
#     Description:  Adds domain search path.
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  1.1.1
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



# Jamf script parameter "Domain"
# Should be in all-caps with no domain extensions.
DOMAIN="$5"



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$DOMAIN"
  )
  for argument in "${jamfArguments[@]}"; do
    if [[ "$argument" = "" ]]; then
      "/bin/echo" "Undefined Jamf argument, unable to proceed."
      exit 74
    fi
  done
}



########## main process ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments


# appends domain search path
"/usr/bin/dscl" /Search -append / CSPSearchPath "/Active Directory/$DOMAIN/All Domains"



exit 0
