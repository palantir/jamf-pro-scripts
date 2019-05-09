#!/bin/bash

###
#
#            Name:  SnagIt License Status.sh
#     Description:  Returns whether a "SnagitRegistrationKey" file is present
#                   in "/Users/Shared/TechSmith/Snagit/".
#         Created:  2018-10-09
#   Last Modified:  2019-05-09
#         Version:  1.0.1
#
#
# Copyright 2018 Palantir Technologies, Inc.
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



licensePath="/Users/Shared/TechSmith/SnagIt/SnagitRegistrationKey"



########## main process ##########



if [[ -e "$licensePath" ]]; then
  licenseStatus="Licensed"
fi


"/bin/echo" "<result>$licenseStatus</result>"



exit 0
