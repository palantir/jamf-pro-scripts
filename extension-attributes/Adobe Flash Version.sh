#!/bin/sh

###
#
#            Name:  Adobe Flash Version.sh
#     Description:  Returns Adobe Flash version (if plugin is installed).
#         Created:  2016-06-06
#   Last Modified:  2019-05-15
#         Version:  1.2.2
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



flashPluginPath="/Library/Internet Plug-Ins/Flash Player.plugin"



########## main process ##########



# check for presence of target plugin and report version accordingly
if [[ -e "$flashPluginPath" ]] ; then
  flashVersion=$("/usr/bin/defaults" read "$flashPluginPath/Contents/version.plist" "CFBundleVersion")
else
  flashVersion=""
fi


"/bin/echo" "<result>$flashVersion</result>"



exit 0
