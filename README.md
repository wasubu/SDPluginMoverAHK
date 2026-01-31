# SDPluginMover (AHK)
For users of the Portable version of OBS Studio. This AHK script will check the Elgato StreamDeck Plugin and move it to your OBS Studio Portable folder.

### Features
* Checks if the directories exist in the appropriate locations within the OBS Portable directory, and if not, create them.
* Checks if the original source files exist (ie. StreamDeck Application installed) and notifies the user if not
* Checks the version number between the source version and the OBS Plugin version to only copy if an update is required.

### Usage


1. Download the [latest release](https://github.com/wasubu/SDPluginMoverAHK/releases/tag/release).
4. Right-click the **ElgatoPluginMover.ahk** file and open it with Notepad/VSCode/Your preferred text editor environment.
5. Modify the top-most variable inside the quotation marks with the filepath to the root of your OBS Portable directory.
6. Save the file and close the editor.
7. Double-click the file **ElgatoPluginMover.ahk** and run it. 

The script should error on any condition that isn't met. I've done my best to anticipate any potential issues and raise them as native dialogue boxes (I'm assuming people read, my bad) and added any corrective measures that's possible within the script.

But if something fucks up outside of that, raise an issue on this here Git repo.