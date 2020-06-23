#!/bin/zsh

###
#
#            Name:  Add APFS Volume.zsh
#     Description:  Creates additional APFS volume at /Volumes/$newVolumeName
#                   (sharing disk space with other volumes in the startup disk
#                   container).
#         Created:  2016-06-06
#   Last Modified:  2020-06-22
#         Version:  7.0
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
startupDiskName="$4"
# Jamf Pro script parameter: "New Volume Name"
newVolumeName="$5"
# Jamf Pro script parameter: "New Volume Size"
# Enter a number of gigabytes.
newVolumeSize="$6"
sizeSuffix="G"
# Jamf Pro script parameter: "New Volume APFS Format"
# See diskutil listFilesystems for expected formats.
newVolumeAPFSFormat="$7"
# Do not change these values.
startupDiskInfo=$(/usr/sbin/diskutil info "$startupDiskName")
fileSystemPersonality=$(echo "$startupDiskInfo" | /usr/bin/awk -F: '/File System Personality/ {print $NF}' | /usr/bin/sed 's/^ *//')



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
function check_jamf_pro_arguments {
  jamfProArguments=(
    "$startupDiskName"
    "$newVolumeName"
    "$newVolumeSize"
    "$newVolumeAPFSFormat"
  )
  for argument in "${jamfProArguments[@]}"; do
    if [[ -z "$argument" ]]; then
      echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
      exit 74
    fi
  done
}


# Checks for presence of $newVolumeName.
function check_volume {
  if [[ $(/usr/sbin/diskutil info "$newVolumeName" 2>&1) != "Could not find disk: $newVolumeName" ]]; then
    echo "Volume $newVolumeName already present, no action required."
    exit 0
  fi
}


# Checks for presence of target startup disk.
function check_startup_disk {
  if [[ $(/usr/sbin/diskutil info "$startupDiskName" 2>&1) = "Could not find disk: $startupDiskName" ]]; then
    echo "❌ ERROR: Volume $startupDiskName missing, unable to proceed."
    exit 72
  fi
}


# Creates volume with specified name, format, and size in gigabytes (resizes startup disk for older filesystems).
function add_volume {
  /usr/sbin/diskutil \
    apfs addVolume \
    "$startupDiskDevice" \
    "$newVolumeAPFSFormat" \
    "$newVolumeName" \
    -quota "$newVolumeSize$sizeSuffix"
  echo "Volume $newVolumeName created ($newVolumeSize$sizeSuffix), formatted as $newVolumeAPFSFormat."
  sleep 5
  volumeIdentifier=$(/usr/sbin/diskutil list | /usr/bin/grep "$newVolumeName" | /usr/bin/awk '{print $NF}')
}



########## main process ##########



# Verify system meets all script requirements (each function will exit if
# respective check determines that the script cannot be run).
check_jamf_pro_arguments
check_volume
check_startup_disk


# Add APFS volume.
if [[ "$fileSystemPersonality" = *"APFS"* ]]; then
  startupDiskDevice=$(echo "$startupDiskInfo" | /usr/bin/awk '/Part of Whole/ {print $4}')
  add_volume
else
  echo "❌ ERROR: Unsupported file system ($volumeFileSystemPersonality), unable to proceed."
  exit 1
fi



exit 0
