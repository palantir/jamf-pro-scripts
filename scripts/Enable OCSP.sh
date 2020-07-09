#!/bin/sh

###
#
#            Name:  Enable OCSP.sh
#     Description:  Enables OCSP secure authentication.
#         Created:  2016-06-06
#   Last Modified:  2020-07-08
#         Version:  2.0.4
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



# Enable OCSP for logged-in user.
sudo -u "$loggedInUser" /usr/bin/defaults write "com.apple.security.revocation" OCSPStyle -string "BestAttempt"



exit 0
