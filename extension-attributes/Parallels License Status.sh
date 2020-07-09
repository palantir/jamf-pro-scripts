#!/bin/sh

###
#
#            Name:  Parallels License Status.sh
#     Description:  Returns Parallels license info (if Parallels is installed).
#         Created:  2016-06-06
#   Last Modified:  2020-07-08
#         Version:  1.4.1
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



parallelsCommandLineTool="/usr/local/bin/prlsrvctl"



########## main process ##########



# Check for presence of target binary and get licensing info.
if [ -e "$parallelsCommandLineTool" ]; then
  parallelsLicenseStatusCheck=$("$parallelsCommandLineTool" info --license | /usr/bin/awk -F\" '/status/ {print $2}')
  if [ "$parallelsLicenseStatusCheck" = "ACTIVE" ]; then
    licenseStatus="Licensed"
  else
    licenseStatus="Trial"
  fi
else
  licenseStatus=""
fi


echo "<result>$licenseStatus</result>"



exit 0
