#!/bin/sh

# tbt-flash.sh
# Author(s): Mayank Kumar  (mayankk2308, github.com / mac_editor, egpu.io)
#            Asutosh Palai (asutoshpalai, github.com)
# License: Specified in LICENSE.md.
# Version: 1.0.0

# ----- Environment

(
# Script reference
script="$0"

# Toggle case-insensitive comparisons
shopt -s nocasematch

# Text modes
bold="$(tput bold)"
normal="$(tput sgr0)"
underline="$(tput smul)"

# User interface artifacts
gap=" "
mark=">>"

# Script binary
local_bin="/usr/local/bin"
script_bin="${local_bin}/tbt-flash"
tmp_script="${local_bin}/tbt-flash-new"
is_bin_call=0
call_script_file=""

# Script version
script_major_ver="1" && script_minor_ver="0" && script_patch_ver="0"
script_ver="${script_major_ver}.${script_minor_ver}.${script_patch_ver}"
latest_script_data=""
latest_release_dwld=""

# User input
userinput=""

# System information
macos_ver="$(sw_vers -productVersion)"
macos_build="$(sw_vers -buildVersion)"

# Patch references
log_base_hex="8B0D2F7F01000FA3F1733D488D4D2048894DE0"
log_patch_hex="8B0D2F7F01000FA3F19090488D4D2048894DE0"

ace_base_hex="837F2403741C837F280174164889F94C89F24D89F8E80DC1FFFF"
ace_patch_hex="837F2403741C837F2801EB164889F94C89F24D89F8E80DC1FFFF"

drom_base_hex="4C8B55308A453884C04C89E775230FB74F10410FB75210"
drom_patch_hex="4C8B55308A453884C04C89E7EB230FB74F10410FB75210"

version_base_hex="4439EB7E6B418A52158A4F15EB74488B1D92050200"
version_patch_hex="4439EBEB7D418A52158A4F15EB74488B1D92050200"

# ThorUtil.efi access path
thorutil_loc="/System/Library/AccessoryUpdaterBundles/ThunderboltAccessoryFirmwareUpdater.bundle/Contents/Resources/ThorUtil.efi"

# Firmware binary location
firmware_loc=""

# Working directory
workdir="/Library/Application Support/TBTFlash/"
thorutil_bak="${workdir}ThorUtil.efi"

# ----- APIs

## -- UI + Utilities

### Printf newline
printfn() {
  printf '%b\n' "${@}"
}

### Clear print
printfc() {
  printf "\033[2K\r"
  printfn "${@}"
}

### Prompt for a yes/no action
yesno_action() {
  local prompt="${1}"
  local yesaction="${2}"
  local noaction="${3}"
  local no_newline="${4}"
  [[ -z "${no_newline}" ]] && printfn
  read -n1 -p "${prompt} [Y/N]: " userinput
  printf "\033[2K\r"
  [[ ${userinput} == "Y" ]] && eval "${yesaction}" && return
  [[ ${userinput} == "N" ]] && eval "${noaction}" && return
  printfn "Invalid choice. Please try again."
  yesno_action "${prompt}" "${yesaction}" "${noaction}"
}

### Generalized args processor
autoprocess_args() {
  local choice="${1}" && shift
  local caller="${2}" && shift
  local actions=("${@}")
  printf "\033[2K\r"
  if [[ ${choice} =~ ^[0-9]+$ && (( ${choice} > 0 && ${choice} -le ${#actions[@]} )) ]]
  then
    eval "${actions[(( ${choice} - 1 ))]}"
    return
  fi
  printfn "Invalid choice."
  return
}

### Generalized input request
autoprocess_input() {
  local message="${1}" && shift
  local caller="${1}" && shift
  local exit_action="${1}" && shift
  local prompt_back="${1}" && shift
  local actions=("${@}")
  local readonce=""
  (( ${#actions[@]} < 10 )) && readonce="-n1"
  read ${readonce} -p "${bold}${message}${normal} [1-${#actions[@]}]: " userinput
  autoprocess_args "${userinput}" "${caller}" "${actions[@]}"
  [[ "${prompt_back}" == true ]] && yesno_action "${bold}Back to menu?${normal}" "${caller}" "${exit_action}"
}

### Generalized menu generator
generate_menu() {
  local header="${1}" && shift
  local indent_level="${1}" && shift
  local gap_after="${1}" && shift
  local should_clear="${1}" && shift
  local items=("${@}")
  local indent=""
  for (( i = 0; i < ${indent_level}; i++ ))
  do
    indent="${indent} "
  done
  [[ ${should_clear} == 1 ]] && clear
  printfn "${indent}${mark}${gap}${bold}${header}${normal}\n"
  for (( i = 0; i < ${#items[@]}; i++ ))
  do
    num=$(( i + 1 ))
    printfn "${indent}${gap}${bold}${num}${normal}. ${items[${i}]}"
    (( ${num} == ${gap_after} )) && printfn
  done
  printfn
}

## -- Binary Patching Mechanism (P1 -> P2 -> P3)

### OP: Check binary patchability
check_bin_patchability() {
  local target_binary="${1}"
  local find="${2}"
  local dump="$(hexdump -ve '1/1 "%.2X"' "${target_binary}")"
  [[ "${dump}" == *"${find}"* ]] && return 0 || return 1
}

### P1: Create hex representation for target binary
create_hexrepresentation() {
  local target_binary="${1}"
  local scratch_hex="${target_binary}.hex"
  hexdump -ve '1/1 "%.2X"' "${target_binary}" > "${scratch_hex}"
}

### P2: Primary binary patching mechanism
patch_binary() {
  local target_binary="${1}"
  local find="${2}"
  local replace="${3}"
  local scratch_hex="${target_binary}.hex"
  sed -i "" -e "s/${find}/${replace}/g" "${scratch_hex}" 2>/dev/null 1>&2
}

### P3: Generic binary generator for given hex file
create_patched_binary() {
  local target_binary="${1}"
  local scratch_hex="${target_binary}.hex"
  local scratch_binary="${scratch_hex}.bin"
  xxd -r -p "${scratch_hex}" "${scratch_binary}"
  rm "${target_binary}" "${scratch_hex}" && mv "${scratch_binary}" "${target_binary}"
}

# ----- Software Updates

perform_software_update() {
  printfn "${bold}Downloading...${normal}"
  curl -qLs -o "${tmp_script}" "${latest_release_dwld}"
  [[ "$(cat "${tmp_script}")" == "404: Not Found" ]] && printfn "Download failed.\n${bold}Continuing without updating...${normal}" && rm "${tmp_script}" && return
  printfn "Download complete.\n${bold}Updating...${normal}"
  chmod 700 "${tmp_script}" && chmod +x "${tmp_script}"
  rm "${script}" && mv "${tmp_script}" "${script}"
  chown "${SUDO_USER}" "${script}"
  printfn "Update complete."
  "${script}"
  exit 0
}

### Check Github for newer version + prompt update
fetch_latest_release() {
  mkdir -p -m 775 "${local_bin}"
  [[ "${is_bin_call}" == 0 ]] && return
  latest_script_data="$(curl -q -s "https://api.github.com/repos/mayankk2308/tbt-flash/releases/latest")"
  latest_release_ver="$(printfn "${latest_script_data}" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
  latest_release_dwld="$(printfn "${latest_script_data}" | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/')"
  latest_major_ver="$(printfn "${latest_release_ver}" | cut -d '.' -f1)"
  latest_minor_ver="$(printfn "${latest_release_ver}" | cut -d '.' -f2)"
  latest_patch_ver="$(printfn "${latest_release_ver}" | cut -d '.' -f3)"
  if [[ $latest_major_ver > $script_major_ver || ($latest_major_ver == $script_major_ver && $latest_minor_ver > $script_minor_ver)\
   || ($latest_major_ver == $script_major_ver && $latest_minor_ver == $script_minor_ver && $latest_patch_ver > $script_patch_ver) && ! -z "${latest_release_dwld}" ]]
  then
    printfn "${mark}${gap}${bold}Software Update${normal}\n\nSoftware updates are available.\n\nOn Your System    ${bold}${script_ver}${normal}\nLatest Available  ${bold}${latest_release_ver}${normal}"
    yesno_action "${bold}Update now?${normal}" "perform_software_update" "echo \"${bold}Proceeding without updating...${normal}\" && sleep 0.4"
  fi
}

### Binary first-time setup
first_time_setup() {
  [[ $is_bin_call == 1 ]] && return
  script_sha="$(shasum -a 512 -b "${script}" | awk '{ print $1 }')"
  bin_sha=""
  [[ -s "${script_bin}" ]] && bin_sha="$(shasum -a 512 -b "${script_bin}" | awk '{ print $1 }')"
  [[ "${bin_sha}" == "${script_sha}" ]] && return
  rsync "${script}" "${script_bin}"
  chown "${SUDO_USER}" "${script_bin}"
  chmod 755 "${script_bin}"
}

# ----- Execution Management

### Check caller
validate_caller() {
  [[ -z "${script}" ]] && printfn "\n${bold}Cannot execute${normal}.\nPlease see the README for instructions.\n" && exit
  [[ "${script}" == "${script_bin}" ]] && is_bin_call=1
}

### Elevate privileges
elevate_privileges() {
  if [[ $(id -u) != 0 ]]
  then
    sudo /bin/sh "${script}"
    exit
  fi
}

### System integrity protection check
check_sip() {
  if [[ ! -z "$(csrutil status | grep -i enabled)" ]]
  then
    printfn "\nPlease disable ${bold}System Integrity Protection${normal}.\n"
    exit
  fi
}

### macOS compatibility check
check_macos_version() {
  local macos_major_ver="$(printfn "${macos_ver}" | cut -d '.' -f2)"
  [[ (${macos_major_ver} < 15) ]] && printfn "\n${bold}macOS 10.15 or later${normal} required.\n" && exit
}

### Ensure presence of ThorUtil.efi
check_environment() {
  [[ ! -s "${thorutil_loc}" ]] && printfn "\nUnexpected system configuration. Cannot proceed.\n" && exit
}

### Pre-clean working directory
pre_clean_workdir() {
  rm -rf "${workdir}"
  mkdir -p "${workdir}"
}

### Cumulative system check
perform_sys_check() {
  check_macos_version
  check_environment
  check_sip
  elevate_privileges
  pre_clean_workdir
}

# ----- Flash eGFX protocols

# Step 1: User acknowledgement
acknowledge_disclaimer() {
  printf
}

# Step 2: Pre-setup instructions
pre_setup_inst() {
  printf
}

# Step 3: Thunderbolt device selection
select_thunderbolt_device() {
  printf
}

# Step 4: Request firmware binary
request_firmware_binary() {
  printf
  # verify with `file -b == data` command
}

# Step 5: Prepare ThorUtil.efi
prepare_thorutil() {
  printfn "${bold}Preparing EFI patcher...${normal}"
  rsync -rt "${thorutil_loc}" "${thorutil_bak}"
  check_bin_patchability "${thorutil_bak}" "${log_base_hex}"
  local log_patchable=$?
  check_bin_patchability "${thorutil_bak}" "${ace_base_hex}"
  local ace_patchable=$?
  check_bin_patchability "${thorutil_bak}" "${drom_base_hex}"
  local drom_patchable=$?
  check_bin_patchability "${thorutil_bak}" "${version_base_hex}"
  local version_patchable=$?
  if [[ $(expr ${log_patchable} + ${ace_patchable} + ${drom_patchable} + ${version_patchable}) != 0 ]]; then
    printfn "Preparation failed. Unable to patch EFI flasher."
    return -1
  fi
  create_hexrepresentation "${thorutil_bak}"
  patch_binary "${thorutil_bak}" "${log_base_hex}" "${log_patch_hex}"
  patch_binary "${thorutil_bak}" "${ace_base_hex}" "${ace_patch_hex}"
  patch_binary "${thorutil_bak}" "${drom_base_hex}" "${drom_patch_hex}"
  patch_binary "${thorutil_bak}" "${version_base_hex}" "${version_patch_hex}"
  create_patched_binary "${thorutil_bak}"
  printfn "Preparations complete."
  return 0
}

# Step 6: Flash confirmation
initiate_flash() {
  printf  
}

# Step 7: Flash execution
bless_flash() {
  printf
}

# ----- Actions

### Flash eGFX
flash_egfx() {
  printfn "${mark}${gap}${bold}Flash eGFX${normal}\n"
}

### Manual flash for debugging
debug_flash() {
  printfn "${mark}${gap}${bold}Debug Flash${normal}\n"
  printfn "${bold}Generating EFI patcher...${normal}"
  prepare_thorutil
  [[ $? != 0 ]] && printfn "Failed to generate EFI patcher." && return
  rsync -rt "${thorutil_bak}" "/Users/${SUDO_USER}/Desktop/ThorUtil.efi"
  printfn "${bold}ThorUtil.efi${normal} generated on the Desktop.\n"
  printfn "Please follow ${bold}README${normal} for debug flash instructions."
}

### Check last flash
last_flash() {
  printfn "${mark}${gap}${bold}Last Flash Results${normal}\n"
  result="$(nvram ThorUpdateResult 2>/dev/null | awk '{ print $2 }')"
  case "${result}" in
    "")
    printfn "No flash executed or NVRAM results deleted.";;
    "%00%00%00%00%00%00%00%00")
    printfn "Previous flash completed ${bold}without errors${normal} per NVRAM results.";;
    *)
    printfn "Previous flash ${bold}failed${normal} per NVRAM results.";;
  esac
}

### Uninstall
uninstall() {
  printfn "${mark}${gap}${bold}Uninstall${normal}\n"
  printfn "${bold}Uninstalling...${normal}"
  pre_clean_workdir
  rm -rf "${script_bin}"
  printfn "Uninstallation complete.\n"
  exit
}

### Donations
donate() {
  open "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@icloud.com&lc=US&item_name=Development%20of%20TBTFlash&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest"
  printfn "See your ${bold}web browser${normal}."  
}

# ----- User Interface

### Script menu
present_menu() {
  local menu_items=("Flash eGFX" "Last Flash Results" "Debug Flash" "Uninstall" "Donate" "Quit")
  local menu_actions=("flash_egfx" "last_flash" "debug_flash" "uninstall" "donate" "exit")
  generate_menu "TBTFlash (${script_ver})" "0" "4" "1" "${menu_items[@]}"
  autoprocess_input "What next?" "perform_sys_check && present_menu" "exit" "true" "${menu_actions[@]}"
}


begin() {
  validate_caller
  perform_sys_check
  fetch_latest_release
  first_time_setup
  present_menu
}

begin
)