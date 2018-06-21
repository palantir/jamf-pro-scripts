#!/bin/bash

###
#
#            Name:  Encrypt Volume.sh
#     Description:  Encrypts volume /Volumes/$volumeName with a randomized
#                   password, saves password to the System keychain.
#         Created:  2016-04-05
#   Last Modified:  2018-06-20
#         Version:  4.0.1
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



# Jamf script parameter: "Volume Name"
volumeName="$4"
# do not change these values
macOSVersion=$("/usr/bin/sw_vers" -productVersion | "/usr/bin/awk" -F. '{print $2}')
volumeInfo=$("/usr/sbin/diskutil" info "$volumeName")
volumeFileSystemPersonality=$("/bin/echo" "$volumeInfo" | "/usr/bin/awk" -F: '/File System Personality/ {print $NF}' | "/usr/bin/sed" 's/^ *//')
volumePassphrase=$("/bin/cat" "/dev/urandom" | LC_CTYPE=C tr -dc 'A-NP-Za-km-z0-9' | "/usr/bin/head" -c 20)



########## function-ing ##########



# exits if any required Jamf arguments are undefined
check_jamf_arguments () {
  jamfArguments=(
    "$volumeName"
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


# checks for presence of volume
check_volume () {
  if [[ $("/usr/sbin/diskutil" list | "/usr/bin/grep" "$volumeName") = "" ]]; then
    "/bin/echo" "Volume $volumeName missing, unable to proceed."
    exit 72
  else
    volumeIdentifier=$("/usr/sbin/diskutil" list | "/usr/bin/grep" "$volumeName" | "/usr/bin/awk" '{print $NF}')
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


# encrypt volume
# syntax differs depending on file system format of target volume
if [[ "$volumeFileSystemPersonality" =~ "APFS" ]]; then
  encryptVolumeVerb="apfs encryptVolume"
  encryptionUserString="-user disk"
  encrypt_volume
  volumeUUID=$("/usr/sbin/diskutil" info "$volumeName" | "/usr/bin/awk" '/Volume UUID/ {print $3}')
elif [[ "$volumeFileSystemPersonality" =~ "Journaled HFS+" ]]; then
  encryptVolumeVerb="coreStorage convert"
  encryptionUserString=""
  unmount_recovery_volume
  encrypt_volume
  volumeUUID=$("/usr/sbin/diskutil" info "$volumeName" | "/usr/bin/awk" '/LV UUID/ {print $3}')
else
  "/bin/echo" "Unsupported file system: $volumeFileSystemPersonality"
  exit 1
fi


# save encrypted volume password to the System keychain
save_volume_password_to_system_keychain



exit 0
