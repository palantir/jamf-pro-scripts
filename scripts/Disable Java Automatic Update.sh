#!/bin/sh

###
#
#            Name:  Disable Java Automatic Update.sh
#     Description:  Disables Java's automatic update check feature.
#         Created:  2019-04-19
#   Last Modified:  2020-07-08
#         Version:  1.1.1
#
#
# Copyright 2019 Palantir Technologies, Inc.
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



# Disable Java automatic update check.
/usr/bin/defaults write "/Library/Preferences/com.oracle.java.Java-Updater" JavaAutoUpdateEnabled -bool false
echo "Disabled Java automatic update check."



exit 0
