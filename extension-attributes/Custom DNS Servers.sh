#!/bin/sh

###
#
#            Name:  Custom DNS Servers.sh
#     Description:  Lists all network interfaces with custom DNS server entries.
#         Created:  2021-05-18
#   Last Modified:  2022-03-29
#         Version:  1.1.1.1
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



########## variable-ing ##########



outputPath="/tmp/dnsservers.txt"



########## main process ##########



# Initialize output file.
if [ -e "$outputPath" ]; then
  /bin/rm "$outputPath"
fi
/usr/bin/touch "$outputPath"


# Collect all custom DNS servers found in each network interface and pass to an
# output file for later reading.
/usr/sbin/networksetup -listallnetworkservices | /usr/bin/sed 1d | /usr/bin/tr -d "*" | while read -r interface; do
  dnsServerList=$(/usr/sbin/networksetup -getdnsservers "$interface")
  if [ "$dnsServerList" != "There aren't any DNS Servers set on ${interface}." ]; then
    dnsServerList=$(echo "$dnsServerList" | /usr/bin/tr '\n' ',' | /usr/bin/sed 's/,$//')
    echo "${interface}: ${dnsServerList}" >> "$outputPath"
  fi
done


# Report results.
echo "<result>$(/bin/cat "${outputPath}")</result>"


# Clean up.
/bin/rm "$outputPath"



exit 0
