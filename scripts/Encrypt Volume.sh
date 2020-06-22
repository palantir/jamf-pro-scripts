#!/bin/bash
# shellcheck disable=SC2086

###
#
#            Name:  Encrypt Volume.sh
#     Description:  Encrypts volume /Volumes/$volumeName with a randomized
#                   password, saves password to the System keychain.
#         Created:  2016-04-05
#   Last Modified:  2020-06-22
#         Version:  4.0.4
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



# Jamf Pro script parameter: "Volume Name"
volumeName="$4"
# Do not change these values.
volumeInfo=$(/usr/sbin/diskutil info "$volumeName")
volumeFileSystemPersonality=$(/bin/echo "$volumeInfo" | /usr/bin/awk -F: '/File System Personality/ {print $NF}' | /usr/bin/sed 's/^ *//')
volumePassphrase=$(LC_CTYPE=C /usr/bin/tr -dc 'A-NP-Za-km-z0-9' < "/dev/urandom" | /usr/bin/head -c 20)



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
function check_jamf_pro_arguments {
  jamfProArguments=(
    "$volumeName"
  )
  for argument in "${jamfProArguments[@]}"; do
    if [[ -z "$argument" ]]; then
      /bin/echo "Undefined Jamf Pro argument, unable to proceed."
      exit 74
    fi
  done
}



# Exits if Mac is running macOS < 10.12 Sierra, or an OS other than macOS 10.
function check_macos {
  macOSVersionMajor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')
  macOSVersionMinor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
  if [[ $macOSVersionMajor -ne 10 || $macOSVersionMinor -lt 12 ]]; then
    /bin/echo "❌ ERROR: This script requires macOS 10 (10.12 Sierra or later) (version detected: $(/usr/bin/sw_vers -productVersion)), unable to proceed."
    exit 72
  fi
}


# Checks for presence of volume.
function check_volume {
  if /usr/sbin/diskutil list | /usr/bin/grep -q "$volumeName"; then
    volumeIdentifier=$(/usr/sbin/diskutil list | /usr/bin/grep "$volumeName" | /usr/bin/awk '{print $NF}')
  else
    /bin/echo "Volume $volumeName missing, unable to proceed."
    exit 72
  fi
}


# Unmounts Recovery volume (if mounted).
function unmount_recovery_volume {
  recoveryVolumeIdentifier=$(/usr/sbin/diskutil list | /usr/bin/awk '/Recovery HD/ {print $NF}')
  if /sbin/mount | /usr/bin/grep -q "$recoveryVolumeIdentifier"; then
    /usr/sbin/diskutil unmount "$recoveryVolumeIdentifier"
    /bin/echo "Unmounted Recovery volume."
  fi
}


# Encrypts new volume with randomly-generated password.
function encrypt_volume {
  /usr/sbin/diskutil $encryptVolumeVerb \
    "$volumeIdentifier" \
    $encryptionUserString \
    -passphrase "$volumePassphrase"
  sleep 5
  /bin/echo "Volume $volumeName is encrypting with a randomized password."
}


# Saves encrypted volume password to the System keychain.
function save_volume_password_to_system_keychain {
  /usr/bin/security add-generic-password \
    -a "$volumeUUID" \
    -l "$volumeName" \
    -s "$volumeUUID" \
    -w "$volumePassphrase" \
    -A \
    -D "encrypted volume password" \
    "/Library/Keychains/System.keychain"
  /bin/echo "$volumeName password saved to the System keychain."
}



########## main process ##########



# Verify system meets all script requirements (each function will exit if respective check fails).
check_jamf_pro_arguments
check_macos
check_volume


# Encrypt volume (syntax differs depending on file system format of target volume).
if [[ "$volumeFileSystemPersonality" = *"APFS"* ]]; then
  encryptVolumeVerb="apfs encryptVolume"
  encryptionUserString="-user disk"
  encrypt_volume
  volumeUUID=$(/usr/sbin/diskutil info "$volumeName" | /usr/bin/awk '/Volume UUID/ {print $3}')
elif [[ "$volumeFileSystemPersonality" = *"Journaled HFS+"* ]]; then
  encryptVolumeVerb="coreStorage convert"
  encryptionUserString=""
  unmount_recovery_volume
  encrypt_volume
  volumeUUID=$(/usr/sbin/diskutil info "$volumeName" | /usr/bin/awk '/LV UUID/ {print $3}')
else
  /bin/echo "Unsupported file system: $volumeFileSystemPersonality"
  exit 1
fi


# Save encrypted volume password to the System keychain.
save_volume_password_to_system_keychain



exit 0
