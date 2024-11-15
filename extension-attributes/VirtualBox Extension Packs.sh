#!/bin/sh

###
#
#            Name:  VirtualBox Extension Packs.sh
#     Description:  Reports whether any VirtualBox extension packs are installed.
#         Created:  2019-12-17
#   Last Modified:  2024-11-15
#         Version:  1.0.3
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



########## variable-ing ##########



VBoxManagePath="/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
extpackCheck=""



########## main process ##########



if [ -e "$VBoxManagePath" ]; then
  if [ "$("$VBoxManagePath" list extpacks | /usr/bin/awk '/Extension Packs/ {print $NF}')" -gt 0 ]; then
    extpackCheck="installed"
  fi
fi




echo "<result>${extpackCheck}</result>"



exit 0
