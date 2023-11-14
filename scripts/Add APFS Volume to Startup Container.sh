#!/bin/sh

###
#
#            Name:  Add APFS Volume to Startup Container.sh
#     Description:  Creates additional APFS volume at /Volumes/$newVolumeName (sharing space with other volumes in the startup volume container), using either predefined script parameters or responses from user-facing prompts for any undefined required values.
#         Created:  2016-06-06
#   Last Modified:  2023-11-13
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



### Jamf Pro script parameter: "New Volume Name"
# If undefined, script will prompt user to enter a desired name.
newVolumeName="${4}"

### Jamf Pro script parameter: "New Volume APFS Format"
# If undefined, script will prompt user to optionally select a desired format. See 'diskutil listFilesystems' for expected formats.
newVolumeAPFSFormat="${5}"

### Volume Quota Parameters
# If both quota parameters are defined, the larger of the two will be used (unless it exceeds the target container's size). If both parameters are undefined, script will prompt user to optionally enter a desired quota in GB.

### Jamf Pro script parameter: "Remove Quota"
# If set to "yep", creates volume without a quota, sharing all available space with other volumes in the target container and ignoring any values provided for volume quota sizes.
removeQuota="${6}"

### Jamf Pro script parameter: "New Volume Quota (GB)"
# A number of gigabytes to set the quota for the new volume. If set to a size equal to or larger than the target container, the volume will be created without a quota.
newVolumeQuotaGB="${7}"

### Jamf Pro script parameter: "New Volume Quota (Percent)"
# A percentage of total container space to set the quota for the new volume. If set to 100, the volume will be created without a quota.
newVolumeQuotaPercent="${8}"

startupVolumeInfo=$(/usr/sbin/diskutil info "/")
startupVolumeName=$(echo "$startupVolumeInfo" | /usr/bin/awk -F: '/Volume Name/ {print $NF}' | /usr/bin/sed 's/^ *//')
startupContainerDevice=$(echo "$startupVolumeInfo" | /usr/bin/awk '/Part of Whole/ {print $4}')



########## function-ing ##########



# Confirms whether a value was found when checking startup container size. If this check fails, the script will likely need to be updated to account for a change to how macOS reports this value via 'diskutil info /'.
check_startup_container_size () {

  startupContainerSizeBytes=$(echo "$startupVolumeInfo" | /usr/bin/awk -F '[( )]' '/Container Total Space/ {print $14}')
  if [ "$startupContainerSizeBytes" -gt 0 ]; then
    # Convert to gigabytes.
    startupContainerSizeGB=$(echo "${startupContainerSizeBytes}/1024/1024/1024" | /usr/bin/bc)
    echo "Startup container size: ${startupContainerSizeGB}GB"
  else
    echo "❌ ERROR: Unable to determine startup container size, unable to proceed. Check output of 'diskutil info /' and update script as needed to capture the number value of Container Total Space."
    exit 74
  fi

}


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


# Checks for presence of a target quota (either in GB, as a percentage of total container size, or "all" for using all available container space), prompts for optional entry if missing. If both values are defined, the greater valid value of the two will be used.
check_volume_quota () {

  # If no volume quota parameters are defined, prompt for manual entry in gigabytes.
  if [ -z "$removeQuota" ] && [ -z "$newVolumeQuotaGB" ] && [ -z "$newVolumeQuotaPercent" ]; then
    newVolumeQuotaGB=$(/usr/bin/osascript -e "set new_volume_quota to text returned of (display dialog \"Please enter new volume quota as a number of gigabytes:\" default answer \"\")")
    # If user returns empty prompt, exit with error.
    if [ -z "$newVolumeQuotaGB" ]; then
      echo "❌ ERROR: New volume quota undefined, unable to proceed."
      exit 74
    fi
  fi

  # If Remove Quota is set to "yep" or target quota meets or exceeds container capacity, skip remaining quota checks.
  if [ "$removeQuota" = "yep" ] || [ "$newVolumeQuotaGB" -ge "$startupContainerSizeGB" ] || [ "$newVolumeQuotaPercent" -ge 100 ]; then
    echo "Script has been configured to create volume without a quota."
    removeQuota="yep"
  elif [ "$newVolumeQuotaPercent" -gt 0 ]; then
    # Convert volume quota percentage to GB based on target container size.
    newVolumeQuotaPctAsGB=$(echo "${startupContainerSizeGB}*${newVolumeQuotaPercent}/100" | /usr/bin/bc)
    echo "Converted new volume quota percentage to GB, got ${newVolumeQuotaPctAsGB}GB."
    if [ -n "$newVolumeQuotaGB" ] && [ "$newVolumeQuotaGB" -gt 0 ]; then
      echo "Values were provided for new volume quota both in GB and as a percentage. Comparing values and taking the larger of the two..."
      if [ "$newVolumeQuotaPctAsGB" -gt "$newVolumeQuotaGB" ]; then
        echo "Quota percentage was larger than quota GB, set the target size: ${newVolumeQuotaPctAsGB}GB (${newVolumeQuotaPercent}%)"
        newVolumeQuotaGB="$newVolumeQuotaPctAsGB"
      else
        echo "Quota GB was larger than quota percentage, set the target size: ${newVolumeQuotaGB}GB"
      fi
    else
      echo "Quota GB undefined or invalid (${newVolumeQuotaGB}), using converted quota percentage, set the target size: ${newVolumeQuotaPctAsGB}GB (${newVolumeQuotaPercent}%)"
      newVolumeQuotaGB="$newVolumeQuotaPctAsGB"
    fi
  elif [ "$newVolumeQuotaGB" -gt 0 ]; then
    echo "Quota percentage undefined or invalid (${newVolumeQuotaPercent}), set the target size: ${newVolumeQuotaGB}GB)"

  else
    echo "❌ ERROR: Invalid values for both volume quota GB (${newVolumeQuotaGB}) and volume quota percentage (${newVolumeQuotaPercent}), unable to proceed."
    exit 1
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


# Creates volume with specified name, format, and quota size (if defined), sharing space with other volumes in the startup volume container.
add_volume () {

  if [ "$removeQuota" = "yep" ]; then
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
      -quota "${newVolumeQuotaGB}G"
    echo "Volume ${3} created (${newVolumeQuotaGB} GB), formatted as ${2}."
  fi

}



########## main process ##########



# Verify system meets all script requirements (each function will exit if respective check determines that the script cannot run or does not need to be run).
check_startup_container_size
check_volume_name
check_volume_apfs_format
check_volume_quota
check_file_system_personality


# Add APFS volume.
add_volume "$startupContainerDevice" "$newVolumeAPFSFormat" "$newVolumeName"



exit 0
