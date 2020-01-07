#!/bin/sh

###
#
#            Name:  Update Jamf Pro Inventory and Set Logged-In User as Associated User.sh
#     Description:  Update Jamf Pro inventory, assigning the computer record to
#                   the currently logged-in user.
#         Created:  2016-06-08
#   Last Modified:  2020-01-07
#         Version:  1.1.4
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



loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")



########## main process ##########



# Update Jamf Pro inventory, assign to currently logged-in user.
/usr/local/bin/jamf recon -endUsername "$loggedInUser"



exit 0
