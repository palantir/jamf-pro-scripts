#!/bin/bash

###
#
#            Name:  Custom Resolver Domains.sh
#     Description:  Returns list of custom domains configured in /etc/resolver/.
#         Created:  2017-10-09
#   Last Modified:  2018-06-20
#         Version:  1.1.1
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



macosResolverPath="/etc/resolver"



########## main process ##########



if [[ -d "$macosResolverPath" ]]; then
  resolverDomains=$("/bin/ls" -1 "$macosResolverPath")
else
  resolverDomains=""
fi


"/bin/echo" "<result>$resolverDomains</result>"



exit 0
