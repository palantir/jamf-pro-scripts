#!/bin/sh

###
#
#            Name:  Set Active Directory Computer Trust Account Password Interval.sh
#     Description:  Sets the computer trust account password interval via dsconfigad for Macs bound to Active Directory.
#         Created:  2022-04-07
#   Last Modified:  2025-04-28
#         Version:  1.0.1
#
# Copyright 2022 Palantir Technologies, Inc.
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



# Jamf Pro script parameter: "Domain Password Interval"
# Set to a positive integer, or to 0 to disable the feature.
domainPassinterval="${4}"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$domainPassinterval" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}



########## main process ##########



# Verify script prerequisites.
check_jamf_pro_arguments


# Exit if domain password interval contains any characters other than digits.
domainPassintervalTest=$(echo "$domainPassinterval" | /usr/bin/tr -d "[:digit:]")
if [ -n "$domainPassintervalTest" ]; then
  echo "❌ ERROR: Invalid value for domain password interval ($domainPassinterval), must be an integer."
  exit 1
fi


# Exit if Mac is already bound to a domain.
domainBindCheck=$(/usr/sbin/dsconfigad -show)
if [ -z "$domainBindCheck" ]; then
  echo "Mac is not bound to a domain, no action required."
  exit 0
else
  domainPassintervalCheck=$(echo "$domainBindCheck" | awk '/Password change interval/ {print $NF}')
  if [ "$domainPassintervalCheck" -eq "$domainPassinterval" ]; then
    echo "Domain password change interval already set to ${domainPassintervalCheck}, no action required."
  else
    echo "Updating password change interval..."
    /usr/sbin/dsconfigad -passinterval "$domainPassinterval"
  fi
fi



exit 0
