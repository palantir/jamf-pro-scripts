#!/bin/sh

###
#
#            Name:  Active Directory Computer Trust Account Password Interval.sh
#     Description:  Gets the computer trust account password interval via dsconfigad for Macs bound to Active Directory.
#         Created:  2022-04-07
#   Last Modified:  2025-04-28
#         Version:  1.0.2
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



########## main process ##########



echo "<result>$(/usr/sbin/dsconfigad -show | /usr/bin/awk '/Password change interval/ {print $NF}')</result>"



exit 0
