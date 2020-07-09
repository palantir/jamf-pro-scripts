#!/bin/sh

###
#
#            Name:  Vagrant Version.sh
#     Description:  Returns Vagrant version (if installed).
#         Created:  2017-06-16
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



vagrantPath="/opt/vagrant/bin/vagrant"



########## main process ##########



# Check for presence of target binary and get version.
if [ -e "$vagrantPath" ]; then
  vagrantVersion=$("$vagrantPath" version 2>"/dev/null" | /usr/bin/awk '/Installed Version/ {print $3}')
else
  vagrantVersion=""
fi


# Report result.
echo "<result>$vagrantVersion</result>"



exit 0
