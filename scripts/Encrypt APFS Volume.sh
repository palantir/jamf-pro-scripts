#!/bin/sh

###
#
#            Name:  Encrypt APFS Volume.sh
#     Description:  Encrypts target APFS volume with a randomized password, then saves this password to the System keychain to allow volume to mount automatically on login.
#         Created:  2016-04-05
#   Last Modified:  2023-11-13
#         Version:  5.1
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



# Jamf Pro script parameter: "Target Volume"
targetVolume="${4}"
newVolumeInfo=$(/usr/sbin/diskutil info "$targetVolume")
volumeFileSystemPersonality=$(echo "$newVolumeInfo" | /usr/bin/awk -F: '/File System Personality/ {print $NF}' | /usr/bin/sed 's/^ *//')
targetVolumePassphrase=$(LC_CTYPE=C /usr/bin/tr -dc 'A-NP-Za-km-z0-9' < "/dev/urandom" | /usr/bin/head -c 20)



########## function-ing ##########



# Exits if any required Jamf Pro arguments are undefined.
check_jamf_pro_arguments () {
  if [ -z "$targetVolume" ]; then
    echo "❌ ERROR: Undefined Jamf Pro argument, unable to proceed."
    exit 74
  fi
}


# Checks for presence of volume.
check_volume () {
  if /usr/sbin/diskutil list | /usr/bin/grep -q "$targetVolume"; then
    volumeIdentifier=$(/usr/sbin/diskutil list | /usr/bin/grep "$targetVolume" | /usr/bin/awk '{print $NF}')
  else
    echo "❌ ERROR: Volume ${targetVolume} missing, unable to proceed."
    exit 72
  fi
}


# Encrypts new volume with randomly-generated password.
encrypt_volume () {
  /usr/sbin/diskutil \
    apfs encryptVolume \
    "$volumeIdentifier" \
    -user disk \
    -passphrase "$targetVolumePassphrase"
  sleep 5
  targetVolumeUUID=$(/usr/sbin/diskutil info "$targetVolume" | /usr/bin/awk '/Volume UUID/ {print $3}')
  echo "Volume ${targetVolume} is encrypting with a randomized password."
}


# Saves encrypted volume password to the System keychain.
save_volume_password_to_system_keychain () {
  /usr/bin/security add-generic-password \
    -a "$targetVolumeUUID" \
    -l "$targetVolume" \
    -s "$targetVolumeUUID" \
    -w "$targetVolumePassphrase" \
    -A \
    -D "encrypted volume password" \
    "/Library/Keychains/System.keychain"
  echo "${targetVolume} password saved to the System keychain."
}



########## main process ##########



# Verify system meets all script requirements (each function will exit if respective check fails).
check_jamf_pro_arguments
check_volume


# Encrypt APFS volume.
if echo "$volumeFileSystemPersonality" | /usr/bin/grep -q "APFS"; then
  encrypt_volume
else
  echo "❌ ERROR: Unsupported file system (${volumeFileSystemPersonality}), unable to proceed."
  exit 1
fi


# Save encrypted volume password to the System keychain.
save_volume_password_to_system_keychain



exit 0
