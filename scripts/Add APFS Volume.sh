#!/bin/sh

###
#
#            Name:  Add APFS Volume.sh
#     Description:  Creates additional APFS volume at /Volumes/$newVolumeName (sharing disk space with other volumes in the startup disk container).
#         Created:  2016-06-06
#   Last Modified:  2023-10-24
#         Version:  7.1
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



# Jamf Pro script parameter: "Startup Disk Name"
startupDiskName="${4}"
# Jamf Pro script parameter: "New Volume Name"
newVolumeName="${5}"
# Jamf Pro script parameter: "New Volume APFS Format"
# See diskutil listFilesystems for expected formats.
newVolumeAPFSFormat="${6}"
# Jamf Pro script parameter: "New Volume Quota (GB) (optional)"
# Enter a number of gigabytes to set the quota for the new volume. If no number is specified, the volume shares all available space with other volumes in the target container.
newVolumeQuota="${7}"



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {

  if [ -z "$startupDiskName" ] || [ -z "$newVolumeName" ] || [ -z "$newVolumeAPFSFormat" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi

}


# Checks for presence of target startup disk.
check_startup_disk () {

  startupDiskCheck=$(/usr/sbin/diskutil info "$startupDiskName" 2>&1)
  if echo "$startupDiskCheck" | grep -q "Could not find disk: ${startupDiskName}"; then
    echo "❌ ERROR: Volume ${startupDiskName} missing, unable to proceed."
    exit 72
  fi

}


# Checks for presence of $newVolumeName.
check_volume () {

  volumeCheck=$(/usr/sbin/diskutil info "$newVolumeName" 2>&1)
  if echo "$volumeCheck" | grep -v -q "Could not find disk: ${newVolumeName}"; then
    echo "Volume ${newVolumeName} already present, no action required."
    exit 0
  fi

}


# Creates volume with specified name, format, and quota size in gigabytes (optional).
add_volume () {

  if [ -n "${newVolumeQuota}" ]; then
    /usr/sbin/diskutil \
      apfs addVolume \
      "${1}" \
      "${2}" \
      "${3}" \
      -quota "${newVolumeQuota}G"
    echo "Volume ${3} created (${newVolumeQuota} GB), formatted as ${2}."
  else
    /usr/sbin/diskutil \
      apfs addVolume \
      "${1}" \
      "${2}" \
      "${3}"
    echo "Volume ${3} created (sharing all available container space with ${startupDiskName}), formatted as ${2}."
  fi

}



########## main process ##########



# Verify system meets all script requirements (each function will exit if respective check determines that the script cannot be run).
check_jamf_pro_arguments
check_startup_disk
check_volume


# Add APFS volume.
startupDiskInfo=$(/usr/sbin/diskutil info "$startupDiskName")
fileSystemPersonality=$(echo "$startupDiskInfo" | /usr/bin/awk -F: '/File System Personality/ {print $NF}' | /usr/bin/sed 's/^ *//')
if echo "$fileSystemPersonality" | /usr/bin/grep -q "APFS"; then
  startupDiskDevice=$(echo "$startupDiskInfo" | /usr/bin/awk '/Part of Whole/ {print $4}')
  add_volume "$startupDiskDevice" "$newVolumeAPFSFormat" "$newVolumeName"
else
  echo "❌ ERROR: Unsupported file system (${fileSystemPersonality}), unable to proceed."
  exit 1
fi



exit 0
