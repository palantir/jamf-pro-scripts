#!/bin/bash

###
#
#            Name:  Active Directory Computer Account.sh
#     Description:  Reports Computer Account name for Active Directory record
#                   (if computer is bound to domain).
#         Created:  2016-08-22
#   Last Modified:  2018-06-20
#         Version:  2.0.1
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



adComputerAccountName=$("/usr/sbin/dsconfigad" -show | "/usr/bin/awk" -F[=$] '/Computer Account/ {print $2}' | "/usr/bin/sed" 's/^ *//')



########## main process ##########



"/bin/echo" "<result>$adComputerAccountName</result>"



exit 0
