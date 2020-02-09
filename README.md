# ![Header](/resources/header.png)
![Script Version](https://img.shields.io/github/release/mayankk2308/tbt-flash.svg?style=for-the-badge)
![macOS Support](https://img.shields.io/badge/macOS-10.15+-purple.svg?style=for-the-badge) ![Github All Releases](https://img.shields.io/github/downloads/mayankk2308/tbt-flash/total.svg?style=for-the-badge) [![paypal](https://www.paypalobjects.com/digitalassets/c/website/marketing/apac/C2/logos-buttons/optimize/34_Yellow_PayPal_Pill_Button.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@icloud.com&lc=US&item_name=Development%20of%20TBTFlash&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest)

**Document Revision**: 1.0.0+

**tbt-flash.sh** enables flashing external GFX enclosures for the first time on macOS via EFI. To flash firmware, your system will restart. The script will provide directions as you execute it.

## Disclaimer
Flashing firmware inherently comes with risks and can render your eGFX enclosure inoperable. Proceed with caution and at your risk. I will not be responsible for any damage(s) to your system(s). By using this script, you acknowledge this disclaimer and [license](./LICENSE.md).

## Installation & Flashing
1. Ensure you are running **macOS Catalina** or newer.
2. Disable [System Integrity Protection](https://www.imore.com/how-turn-system-integrity-protection-macos).
3. Ensure you have access to a firmware (`.bin`) file for your eGFX enclosure.
4. Remove the GPU from your enclosure and disconnect any other Thunderbolt devices.
5. Run the following command in **Terminal** to install:
   ```
   curl -qLs $(curl -qLs https://bit.ly/2WtIESm | grep '"browser_download_url":' | cut -d'"' -f4) > tbt-flash.sh; sh tbt-flash.sh; rm tbt-flash.sh
   ```
   If Github is busy, the above command may not work. In that case, please download and execute the script from [Releases](./releases). This will install the tool on your system. For future use, you only need to type:
   ```
   tbt-flash
   ```
6. Follow instructions exactly as stated in the script.
7. Script will require rebooting to flash firmware. You will see an Apple logo and progress bar while flashing occurs.

This script does not modify macOS in any way, and only executes a modified EFI application to enable firmware flashing. It is expected that most users will use this tool infrequently, hence uninstalling the tool will completely remove all of its components.

## Credits
EFI flashing and utility patching was a combined effort, with due credit to [@asotoshpalai](https://github.com/asutoshpalai). This project would not have been possible without him.

## Support
Consider **starring** the repository or donating via:

[![paypal](https://www.paypalobjects.com/digitalassets/c/website/marketing/apac/C2/logos-buttons/optimize/34_Yellow_PayPal_Pill_Button.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mayankk2308@gmail.com&lc=US&item_name=Development%20of%20TBTFlash&no_note=0&currency_code=USD&bn=PP-DonationsBF:btn_donate_SM.gif:NonHostedGuest)

Thank you for using **tbt-flash.sh**.
