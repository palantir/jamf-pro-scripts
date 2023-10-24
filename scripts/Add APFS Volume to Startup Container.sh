#!/bin/sh

###
#
#            Name:  Add APFS Volume to Startup Container.sh
#     Description:  Creates additional APFS volume at /Volumes/$newVolumeName (sharing space with other volumes in the startup volume container).
#         Created:  2016-06-06
#   Last Modified:  2023-10-24
#         Version:  8.0
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



# Jamf Pro script parameter: "New Volume Name"
# If undefined, script will prompt user to enter a desired name.
newVolumeName="${4}"
# Jamf Pro script parameter: "New Volume APFS Format"
# If undefined, script will prompt user to optionally select a desired format. See diskutil listFilesystems for expected formats.
newVolumeAPFSFormat="${5}"
# Jamf Pro script parameter: "New Volume Quota (GB)"
# A number of gigabytes to set the quota for the new volume. If set to "none", the volume shares all available space with other volumes in the target container. If undefined, script will prompt user to optionally enter a desired quota.
newVolumeQuota="${6}"
startupVolumeInfo=$(/usr/sbin/diskutil info "/")
startupVolumeName=$(echo "$startupVolumeInfo" | /usr/bin/awk -F: '/Volume Name/ {print $NF}' | /usr/bin/sed 's/^ *//')
startupVolumeDevice=$(echo "$startupVolumeInfo" | /usr/bin/awk '/Part of Whole/ {print $4}')



########## function-ing ##########



# Checks for presence of $newVolumeName, prompts for entry if missing.
check_volume_name () {

  if [ -z "$newVolumeName" ]; then
    newVolumeName=$(/usr/bin/osascript -e "set new_volume_name to text returned of (display dialog \"Please enter new volume name:\" default answer \"\")")
    if [ -z "$newVolumeName" ]; then
      echo "❌ ERROR: New volume name undefined, unable to proceed."
      exit 74
    fi
  fi
  volumeCheck=$(/usr/sbin/diskutil info "$newVolumeName" 2>&1)
  if echo "$volumeCheck" | grep -v -q "Could not find disk: ${newVolumeName}"; then
    echo "Volume ${newVolumeName} already present, no action required."
    exit 0
  fi

}


# Checks for presence of $newVolumeAPFSFormat, prompts for selection if missing.
check_volume_apfs_format () {

  if [ -z "$newVolumeAPFSFormat" ]; then
    newVolumeAPFSFormat=$(/usr/bin/osascript -e "set new_volume_apfs_format to (choose from list {\"APFS\", \"Case-sensitive APFS\"} with prompt \"Select desired volume APFS format:\")")
    if [ -z "$newVolumeAPFSFormat" ]; then
      echo "❌ ERROR: New volume APFS format undefined, unable to proceed."
      exit 74
    fi
  fi

}


# Checks for presence of $newVolumeQuota, prompts for optional entry if missing.
check_volume_quota () {

  if [ -z "$newVolumeQuota" ]; then
    newVolumeQuota=$(/usr/bin/osascript -e "set new_volume_quota to text returned of (display dialog \"Please enter new volume quota as a number of gigabytes (or enter 'none' to share all container space with your startup volume):\" default answer \"none\")")
    if [ -z "$newVolumeQuota" ]; then
      newVolumeQuota="none"
    fi
  fi

}


# Verifies that the startup volume container uses an APFS file system personality.
check_file_system_personality () {

  fileSystemPersonality=$(echo "$startupVolumeInfo" | /usr/bin/awk -F: '/File System Personality/ {print $NF}' | /usr/bin/sed 's/^ *//')
  if echo "$fileSystemPersonality" | /usr/bin/grep -q "APFS"; then
    echo "File system personality: ${fileSystemPersonality}"
  else
    echo "❌ ERROR: Unsupported file system (${fileSystemPersonality}), unable to proceed."
    exit 1
  fi

}


# Creates volume with specified name, format, and quota size in gigabytes (optional), sharing space with other volumes in the startup volume container.
add_volume () {

  if [ "${newVolumeQuota}" = "none" ]; then
    /usr/sbin/diskutil \
      apfs addVolume \
      "${1}" \
      "${2}" \
      "${3}"
    echo "Volume ${3} created (sharing all available container space with ${startupVolumeName}), formatted as ${2}."
  else
    /usr/sbin/diskutil \
      apfs addVolume \
      "${1}" \
      "${2}" \
      "${3}" \
      -quota "${newVolumeQuota}G"
    echo "Volume ${3} created (${newVolumeQuota} GB), formatted as ${2}."
  fi

}



########## main process ##########



# Verify system meets all script requirements (each function will exit if respective check determines that the script cannot be run).
check_volume_name
check_volume_apfs_format
check_volume_quota
check_file_system_personality


# Add APFS volume.
add_volume "$startupVolumeDevice" "$newVolumeAPFSFormat" "$newVolumeName"



exit 0
