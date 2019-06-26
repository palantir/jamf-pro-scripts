# jamf-pro-scripts

## About
This is a collection of extension attributes and scripts intended for managing Mac workstations via Jamf Pro.

The extension attributes collect information such as:

- version of installed application or component (when normal application inventory collection does not capture the desired information)
- licensing status of installed software
- current system or user settings

The scripts perform actions such as:

- installing applications that aren't available in installer packages
- uninstalling applications (all uninstaller scripts are templated from **uninstaller-template**)
- adding or modifying user accounts
- changing user or system settings

## Usage
See [Computer Extension Attributes](http://docs.jamf.com/jamf-pro/administrator-guide/Computer_Extension_Attributes.html) and [Running Scripts](http://docs.jamf.com/jamf-pro/administrator-guide/Running_Scripts.html) in the **Jamf Pro Administrator's Guide** for instructions on using these resources in your Jamf Pro installation.

## Contributing
We welcome all contributions from the open source community to be submitted for review (in the form of GitHub pull requests). Feel free to fork this project and submit changes for approval, but please verify the following beforehand:

- All scripts in this project are intended to run from a Jamf Pro install. We encourage repurposing these scripts as needed for your own environment (under the license terms), but will not store scripts here that do not function in Jamf Pro policies or extension attributes.
- Please make every effort to follow existing conventions and style when modifying or adding scripts to maintain consistency. We realize that the code style used in this project may not exactly match what is seen in Bash scripts elsewhere, but this is in an effort to improve legibility and understanding of script functionality for educational purposes. This means verbose commenting, extra whitespace, and quote-surrounded file paths wherever possible, as well as version number iteration and Created/Last Modified labels when a change is made.

Thank you so much for taking the time to contribute!

## Reference Links
#### Jamf Pro
Apple enterprise mobility management product.
https://www.jamf.com/products/jamf-pro/

#### Jamf Pro Administrator's Guide
Official documentation on Jamf Pro.
http://docs.jamf.com/jamf-pro/administrator-guide/

#### MacAdmins Slack
A Slack channel of Mac administrators. Great way to reach out for questions about Mac management and participate in the community.
https://macadmins.herokuapp.com/

#### Jamf Nation
The official community page for users of Jamf products. Lots of Jamf Pro sample scripts and configurations for inspiration in your own projects and work environment.
https://www.jamf.com/jamf-nation/

## License
This project is made available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).
