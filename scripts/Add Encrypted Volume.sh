#!/bin/bash

###
#
#            Name:  Add Encrypted Volume.sh
#     Description:  Creates additional volume at /Volumes/$volumeName (sharing
#                   disk space with APFS volumes, or using disk space freed up
#                   from startup disk for CoreStorage volumes), encrypts with
#                   randomly-generated password, saves password to System
#                   keychain.
#         Created:  2016-06-06
#   Last Modified:  2018-06-20
#         Version:  6.0.1
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



# Jamf script parameter "Startup Disk Name"
startupDiskName="$4"
# Jamf script parameter "Volume Name"
volumeName="$5"
# Jamf script parameter "Volume Size", should be a number in gigabytes
volumeSize="$6"
sizeSuffix="G"
# Jamf script parameter "Volume Format (APFS)" (see diskutil listFilesystems for expected formats)
volumeFormatAPFS="$7"
# Jamf script parameter "Volume Format (Classic)" (see diskutil listFilesystems for expected formats)
volumeFormatClassic="$8"
# for CoreStorage startup disks, macOS does not provide a helpful limits calculation for recommended minimum size, so we need to do the work ourselves.
# I've chosen a calculation for minimum startup disk size of:
# startupDiskMinimum = ( (10% Total Disk Size) + (Current Disk Space Used by Startup Disk) )
# feel free to change the percentage below depending on how much minimum overhead you want on disk capacity
coreStorageDiskCapacityPercent="10"
# do not change these values
macOSVersion=$("/usr/bin/sw_vers" -productVersion | "/usr/bin/awk" -F. '{print $2}')
startupDiskInfo=$("/usr/sbin/diskutil" info "$startupDiskName")
fileSystemPersonality=$("/bin/echo" "$startupDiskInfo" | "/usr/bin/awk" -F: '/File System Personality/ {print $NF}' | "/usr/bin/sed" 's/^ *//')
volumePassphrase=$("/bin/cat" "/dev/urandom" | LC_CTYPE=C "/usr/bin/tr" -dc 'A-NP-Za-km-z0-9' | "/usr/bin/head" -c 20)



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$startupDiskName"
    "$volumeName"
    "$volumeSize"
    "$volumeFormatAPFS"
    "$volumeFormatClassic"
  )
  for argument in "${jamfArguments[@]}"; do
    if [[ "$argument" = "" ]]; then
      "/bin/echo" "Undefined Jamf argument, unable to proceed."
      exit 74
    fi
  done
}


# exits if Mac is running macOS < 10.12 Sierra
check_macos () {
  if [[ $macOSVersion -lt 12 ]]; then
    "/bin/echo" "This script requires macOS 10.12 Sierra or later."
    exit 72
  fi
}


# checks for presence of $volumeName
check_volume () {
  if [[ $("/usr/sbin/diskutil" info "$volumeName") != "Could not find disk: $volumeName" ]]; then
    "/bin/echo" "Volume $volumeName already present, no action required."
    exit 0
  fi
}


# checks for presence of target startup disk
check_startup_disk () {
  if [[ $("/usr/sbin/diskutil" info "$startupDiskName") = "Could not find disk: $startupDiskName" ]]; then
    "/bin/echo" "Volume $startupDiskName missing, unable to proceed."
    exit 72
  fi
}


# determines whether there is sufficient space on the startup disk to add a volume of target size
# classic disk format workflow
check_disk_space_classic () {
  startupDiskLimits=$("/usr/sbin/diskutil" resizeVolume "$startupDiskName" limits)
  startupDiskMinimum=$("/bin/echo" "$startupDiskLimits" | "/usr/bin/awk" '/Recommended minimum size/ {print $8}')
  startupDiskMaximum=$("/bin/echo" "$startupDiskLimits" | "/usr/bin/awk" '/Maximum size/ {print $7}')
  startupDiskSize=$("/bin/echo" "$startupDiskMaximum-$volumeSize" | "/usr/bin/bc")

  if [[ $("/bin/echo" "$startupDiskMinimum < $startupDiskSize" | "/usr/bin/bc") = "0" ]]; then
    "/bin/echo" "Startup disk $startupDiskName has insufficient free space or is too small to shrink to $startupDiskSizeWithSuffix (needs to be at least $startupDiskMinimum$sizeSuffix). Please select a smaller target size for $volumeName or free up space on the startup disk."
    exit 71
  fi
}

# CoreStorage workflow
check_disk_space_corestorage () {
  startupDiskMaximum=$("/bin/echo" "$startupDiskInfo" | "/usr/bin/awk" '/Disk Size/ {print $3}')
  startupDiskUsed=$("/bin/echo" "$startupDiskInfo" | "/usr/bin/awk" '/Volume Used Space/ {print $4}')
	startupDiskMinimum=$("/bin/echo" "($startupDiskMaximum / $coreStorageDiskCapacityPercent) + $startupDiskUsed" | "/usr/bin/bc")
  startupDiskSize=$("/bin/echo" "$startupDiskMaximum-$volumeSize" | "/usr/bin/bc")

  if [[ $("/bin/echo" "$startupDiskMinimum < $startupDiskSize" | "/usr/bin/bc") = "0" ]]; then
    "/bin/echo" "Startup disk $startupDiskName has insufficient free space or is too small to shrink to $startupDiskSizeWithSuffixx (needs to be at least $startupDiskMinimum$sizeSuffix). Please select a smaller target size for $volumeName or free up space on the startup disk."
    exit 71
  fi
}


# unmounts Recovery volume if mounted
unmount_recovery_volume () {
  recoveryVolumeIdentifier=$("/usr/sbin/diskutil" list | "/usr/bin/awk" '/Recovery HD/ {print $NF}')
  if [[ $("/sbin/mount" | "/usr/bin/grep" "$recoveryVolumeIdentifier") != "" ]]; then
    "/usr/sbin/diskutil" unmount "$recoveryVolumeIdentifier"
    "/bin/echo" "Unmounted Recovery volume."
  fi
}


# create volume with specified name, format, and size in gigabytes (resizes startup disk for older filesystems)
add_volume () {
  "/usr/sbin/diskutil" $addVolumeVerb \
    "$startupDiskDevice" \
    $startupDiskSizeWithSuffix \
    "$volumeFormat" \
    "$volumeName" \
    $quotaString
  "/bin/echo" "Volume $volumeName created ($volumeSize$sizeSuffix), formatted as $volumeFormat."
  if [[ "$startupDiskSizeWithSuffix" != "" ]]; then
    "/bin/echo" "Startup disk $startupDiskName resized ($startupDiskSizeWithSuffix)."
  fi
  sleep 5
  volumeIdentifier=$("/usr/sbin/diskutil" list | "/usr/bin/grep" "$volumeName" | "/usr/bin/awk" '{print $NF}')
}


# encrypts new volume with randomly-generated password
encrypt_volume () {
  "/usr/sbin/diskutil" $encryptVolumeVerb \
    "$volumeIdentifier" \
    $encryptionUserString \
    -passphrase "$volumePassphrase"
  sleep 5
  "/bin/echo" "Volume $volumeName is encrypting with a randomized password."
}


# saves encrypted volume password to the System keychain
save_volume_password_to_system_keychain () {
  "/usr/bin/security" add-generic-password \
    -a "$volumeUUID" \
    -l "$volumeName" \
    -s "$volumeUUID" \
    -w "$volumePassphrase" \
    -A \
    -D "encrypted volume password" \
    "/Library/Keychains/System.keychain"
  "/bin/echo" "$volumeName password saved to the System keychain."
}



########## main process ##########



# verify system meets all script requirements (each function will exit if respective check fails)
check_jamf_arguments
check_macos
check_volume
check_startup_disk


# create new volume (resize startup disk as necessary) and encrypt with randomized password
# syntax differs depending on file system format of startup disk
if [[ "$fileSystemPersonality" =~ "APFS" ]]; then
  startupDiskDevice=$("/bin/echo" "$startupDiskInfo" | "/usr/bin/awk" '/Part of Whole/ {print $4}')
  startupDiskSizeWithSuffix=""
  addVolumeVerb="apfs addVolume"
  volumeFormat="$volumeFormatAPFS"
  quotaString="-quota $volumeSize$sizeSuffix"
  encryptVolumeVerb="apfs encryptVolume"
  encryptionUserString="-user disk"
  add_volume
  encrypt_volume
  volumeUUID=$("/usr/sbin/diskutil" info "$volumeName" | "/usr/bin/awk" '/Volume UUID/ {print $3}')
elif [[ "$fileSystemPersonality" =~ "Journaled HFS+" ]]; then
  startupDiskDevice="$startupDiskName"
  startupDiskSizeWithSuffix="$startupDiskSize$sizeSuffix"
  volumeFormat="$volumeFormatClassic"
  quotaString="$volumeSize$sizeSuffix"
  encryptVolumeVerb="coreStorage convert"
  encryptionUserString=""
  # get addVolumeVerb (different for CoreStorage vs classic), verify sufficient disk space for new volume
  if [[ $("/usr/sbin/diskutil" coreStorage info "$startupDiskName" 2>&1 >/dev/null) = "$startupDiskName is not a CoreStorage disk" ]]; then
    addVolumeVerb="resizeVolume"
    check_disk_space_classic
  else
    addVolumeVerb="coreStorage resizeStack"
    check_disk_space_corestorage
  fi
  unmount_recovery_volume
  add_volume
  encrypt_volume
  volumeUUID=$("/usr/sbin/diskutil" info "$volumeName" | "/usr/bin/awk" '/LV UUID/ {print $3}')
else
  "/bin/echo" "Unsupported file system: $fileSystemPersonality"
  exit 1
fi


# save encrypted volume password to the System keychain
save_volume_password_to_system_keychain



exit 0
