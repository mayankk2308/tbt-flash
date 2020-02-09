# ![Header](/resources/header.png)
![Script Version](https://img.shields.io/github/release/mayankk2308/tbt-flash.svg?style=for-the-badge)
![macOS Support](https://img.shields.io/badge/macOS-10.15+-purple.svg?style=for-the-badge) ![Github All Releases](https://img.shields.io/github/downloads/mayankk2308/tbt-flash/total.svg?style=for-the-badge) [![paypal](https://www.paypalobjects.com/digitalassets/c/website/marketing/apac/C2/logos-buttons/optimize/34_Yellow_PayPal_Pill_Button.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@icloud.com&lc=US&item_name=Development%20of%20TBTFlash&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest)

**Document Revision**: 1.0.0+

**tbt-flash.sh** enables flashing external GFX enclosures for the first time on macOS via EFI. To flash firmware, your system will restart. The script will provide directions as you execute it.

## Disclaimer
Flashing firmware inherently comes with risks and can render your eGFX enclosure inoperable. **Proceed with caution and at your risk**. I will not be responsible for any damage(s) to your system(s). By using this script, you acknowledge this disclaimer and [license](./LICENSE.md).

## Installation & Flashing
1. Ensure you are running **macOS Catalina** or newer.
2. Disable [System Integrity Protection](https://www.imore.com/how-turn-system-integrity-protection-macos).
3. Ensure you have access to a firmware (`.bin`) file for your eGFX enclosure.
4. Remove GPU from your eGFX enclosure for best results.
5. Remove the GPU from your enclosure and disconnect any other Thunderbolt devices.
6. Run the following command in **Terminal** to install:
   ```sh
   curl -qLs $(curl -qLs https://bit.ly/39lD8mJ | grep '"browser_download_url":' | cut -d'"' -f4) > tbt-flash.sh; sh tbt-flash.sh; rm tbt-flash.sh
   ```
   If Github is busy, the above command may not work. In that case, please download and execute the script from [Releases](https://github.com/mayankk2308/tbt-flash/releases). This will install the tool on your system. For future use, you only need to type:
   ```sh
   tbt-flash
   ```
7. Choose **Flash eGFX** option. Follow instructions exactly as stated in the script.
8. Script will require rebooting to flash firmware. You will see an Apple logo and progress bar while flashing occurs.

This script does not modify macOS in any way, and only executes a modified EFI application to enable firmware flashing. It is expected that most users will use this tool infrequently, hence uninstalling the tool will completely remove all of its components.

## Debugging via Manual Flash
I have not had the chance to test exhaustively with a variety of Thunderbolt boards, so there might be cases where flashing just does not work. In this case, I require EFI logs for further debugging. To generate these logs, you need access to an EFI shell and a pen drive. To set up your environment:
1. Install [rEFInd](http://www.rodsbooks.com/efi-bootloaders/installation.html).
2. Add [Tianocore's EFI shell](https://github.com/tianocore/edk2/blob/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi) to [rEFInd tools](http://www.rodsbooks.com/efi-bootloaders/refind.html).
3. Generate a patched EFI flasher with **tbt-flash.sh** using the **Debug Flash** option.
4. Format your pen drive to FAT32 using Disk Utility.
5. Connect your eGPU, go to System Information > Thunderbolt, and note down it's **UID**. **Ensure that it is the UID of the enclosure and not of the Thunderbolt controller on your Mac**.
6. Disconnect all other devices except pen drive and eGPU.
7. Copy the generated EFI flasher as well as the firmware (`.bin`) file to this drive. Rename your firmware file to `Firmware.bin`.
8. Reboot into rEFInd with pen drive plugged in and choose EFI shell.
9. To access your disk, type in:
```sh
fs2:
ls .
```
Usually the pen drive will be on `fs2:`. However, in case it is not, try different numbers instead of `2` and use `ls` to see what files are on there. If none match, reboot by `exit`ing the shell.
10. Once you have access to your pen drive in EFI, ensure eGPU is connected. To flash the eGPU:
```sh
ThorUtil.efi -u <UID> -fs \Firmware.bin -nb -noreset >a debug.log
```
Use the `UID` you noted in Step 5 and the firmware you placed on the pen drive. Logs will be generated in `debug.log`.

11. Share this log while [filing an issue](https://github.com/mayankk2308/tbt-flash/releases) on this repository.

## Credits
EFI flashing and utility patching was a combined effort, with due credit to [@asotoshpalai](https://github.com/asutoshpalai). This project would not have been possible without him.

## Support
Consider **starring** the repository or donating via:

[![paypal](https://www.paypalobjects.com/digitalassets/c/website/marketing/apac/C2/logos-buttons/optimize/34_Yellow_PayPal_Pill_Button.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@gmail.com&lc=US&item_name=Development%20of%20TBTFlash&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest)

Thank you for using **tbt-flash.sh**.
