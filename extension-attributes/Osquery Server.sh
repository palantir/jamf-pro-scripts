#!/bin/sh

###
#
#            Name:  Osquery Server.sh
#     Description:  Returns tls_hostname attribute from osquery.flags (if present).
#         Created:  2017-09-07
#   Last Modified:  2022-06-27
#         Version:  1.1.2
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



osqueryFlagsPath="/var/osquery/osquery.flags"
osqueryServer=""



########## main process ##########



# Check for presence of target file and get server.
if [ -e "$osqueryFlagsPath" ]; then
  osqueryServer=$(/usr/bin/awk -F[=] '/tls_hostname/ {print $2}' "$osqueryFlagsPath")
fi


# Report result.
echo "<result>${osqueryServer}</result>"



exit 0
