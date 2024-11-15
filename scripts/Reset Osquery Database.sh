#!/bin/sh

###
#
#            Name:  Reset Osquery Database.sh
#     Description:  Runs osqueryctl clean to reset the local database, then restarts the service.
#         Created:  2020-08-19
#   Last Modified:  2024-11-15
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



########## variable-ing ##########



binaryPath="/usr/local/bin/osqueryctl"



########## main process ##########



# Reset Osquery database.
if [ -e "$binaryPath" ]; then
  "$binaryPath" stop
  "$binaryPath" clean
  "$binaryPath" start
  echo "Ran osqueryctl clean to reset the local database and restarted the service."
else
  echo "❌ ERROR: osqueryctl binary not found at ${binaryPath}, unable to proceed."
  exit 1
fi



exit 0
