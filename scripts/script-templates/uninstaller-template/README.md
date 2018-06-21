# uninstaller-template

## What is This?

**uninstaller-template** is an example script that assists with the uninstallation of macOS products where the vendor has missing or incomplete removal solutions. Attempts vendor uninstall by targeting all known paths for their scripts, quits all running target processes, unloads all associated launchd tasks, disables kernel extensions, then removes all associated files.

## How Do I Set It Up?

1. Copy `uninstaller-template.sh` and rename to reflect the product you're uninstalling (e.g. `Uninstall Chess.sh`).
2. Update the `vendorUninstallerPath`, `processName`, and `resourceFiles` arrays to list all respective file paths/process names as directed in script comments.
3. If running a vendor uninstaller, modify the `run_vendor_uninstaller` function to properly execute the vendor-approved uninstall workflow.
4. Optional: remove any functions and variables not required for your workflow (e.g. no vendor uninstall workflow exists).

## How Does It Work?

Given a list of vendor uninstaller commands, process names, and file paths for deletion, this script does the following:

1. Runs vendor uninstallers
2. Quits target processes and removes them from login items
3. Unloads LaunchAgents and LaunchDaemons
4. Disables kernel extensions by moving them to `/tmp/$scriptName` for deletion on next restart
5. Deletes all remaining files

## License
This project is made available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
