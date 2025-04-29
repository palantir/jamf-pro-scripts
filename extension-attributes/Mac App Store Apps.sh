#!/bin/sh

###
#
#            Name:  Mac App Store Apps.sh
#     Description:  Lists all apps in /Applications downloaded from the Mac App Store.
#         Created:  2024-05-07
#   Last Modified:  2025-04-28
#         Version:  1.0.1
#
# Copyright 2024 Palantir Technologies, Inc.
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



# Display alpha-sorted list of all apps in /Applications with Mac App Store receipts.
echo "<result>$(/usr/bin/mdfind -onlyin "/Applications/" 'kMDItemAppStoreHasReceipt == "1"' | /usr/bin/sort)</result>"



exit 0
