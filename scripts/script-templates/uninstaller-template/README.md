# uninstaller-template

## What is this?

**uninstaller-template** is an example script that assists with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions.

## How does it work?

Given a list of vendor uninstaller commands and paths, process names, and/or file paths for deletion (all of these are optional), this script does the following:

1. Runs vendor uninstaller commands
2. Quits target processes and removes them from login items
3. Unloads LaunchAgents and LaunchDaemons
4. Disables kernel extensions by moving them to `/tmp/$scriptName` for deletion on next restart
5. Deletes all remaining targeted files and folders

## How do I set it up?

1. Make a copy of `uninstaller-template.sh` and rename it to reflect the product you're uninstalling (e.g. `Uninstall Chess.sh`).
2. Update the `vendorUninstallerCommands`, `processNames`, and `resourceFiles` arrays to list all respective uninstall commands (with any required arguments), process names, and file paths as instructed in script comments.

If you don't need to perform any of the script functions (`run_vendor_uninstallers`, `quit_processes`, `delete_files`), just leave the corresponding array values blank (or comment the lines out) and the script will skip those steps.

## License
This project is made available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
