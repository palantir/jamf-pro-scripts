#!/bin/bash

###
#
#            Name:  Update Proxy Bypass Domain.sh
#     Description:  For each network interface with a proxy bypass domain entry
#                   of "*.local", changes to the target domain entry.
#         Created:  2017-05-23
#   Last Modified:  2018-10-25
#         Version:  1.3
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



# Jamf script parameter "Proxy Bypass Domain".
# Should be in the format "*.domain".
targetDomain="$4"
networkInterfaces=$("/usr/sbin/networksetup" -listallnetworkservices | "/usr/bin/sed" 1d)



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$targetDomain"
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



# replaces all instances of "*.local" in each network interface with "$targetDomain"
while IFS= read -r interface; do
  bypassDomainsCurrent=$("/usr/sbin/networksetup" -getproxybypassdomains "$interface")
  if [[ "$bypassDomainsCurrent" =~ "$targetDomain" ]]; then
    "/bin/echo" "$interface already inclues $targetDomain as proxy bypass domain, no action required."
  elif [[ "$bypassDomainsCurrent" =~ "There aren't any bypass domains set on" ]]; then
    "/bin/echo" "No proxy bypass domains defined for $interface, no action required."
  else
    bypassDomainsUpdate=$("/bin/echo" "$bypassDomainsCurrent" | "/usr/bin/sed" "s/*.local/$targetDomain/" | "/usr/bin/tr" "\n" " ")
    "/usr/sbin/networksetup" -setproxybypassdomains "$interface" $bypassDomainsUpdate
    "/bin/echo" "Updated proxy bypass domains for $interface: $bypassDomainsUpdate"
  fi
done <<< "$networkInterfaces"



exit 0
