# uninstaller-template

## What is this?

**uninstaller-template** is an example script that assists with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions.

## How does it work?

Given a list of vendor uninstaller commands and paths, process names, and/or file paths for deletion (all of these are optional), this script does the following:

1. Runs vendor uninstaller commands
2. Quits target processes
3. Unloads LaunchAgents and LaunchDaemons
4. Removes the system-immutable flag for locked files
5. Deletes all targeted files and folders

## How do I set it up?

1. Make a copy of `uninstaller-template.sh` and rename it to reflect the product you're uninstalling (e.g. `Uninstall Chess.sh`).
2. Update the `run_vendor_uninstaller`, `quit_process`, and `delete_file` function runs at the bottom of the script (in the `main process` section) to run on each respective uninstall command, process name, and file path as instructed in script comments. If multiple such objects need to be acted upon, add an additional function run for each such item.

  If you don't need to perform any particular script function (`run_vendor_uninstallers`, `quit_processes`, `delete_files`), you can comment out or delete the example lines running those functions, and the script will skip those steps.

3. Update your script copy's Version and Last Modified attributes. You should keep the template script version and append a substring unique to your environment (example scripts in this repo are appended with `pal#`, e.g. `2.0pal1`). Whenever you modify your script but retain the same content from the template script, iterate your substring (e.g. `2.0pal2`), and whenever you update your script with changes from the template, iterate the main version and revert the substring version (e.g. `2.1pal1`). This will allow you to tell if your script is out of date from template changes or if you have made multiple modifications to your custom build.

## What if I just have one file to delete and one process to kill? (e.g. Mac App Store installs)

Use `Uninstall Single Application.sh`! It matches the template workflow but lets you define one process and one file path to target for uninstallation via Jamf Pro policy script arguments. This allows reuse of a single script for multiple app uninstallation policies.

## License
This project is made available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
