#!/bin/sh

###
#
#            Name:  Force-Unbind from Domain.sh
#     Description:  Forces an unbind from Active Directory domain. Note that AD
#                   credentials are not required for a force-unbind.
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  1.1.1
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



########## main process ##########



"/usr/sbin/dsconfigad" -remove -username "NotReal" -password "NotReal" -force



exit 0
