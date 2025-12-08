# Pajamas Runtime - Roblox:
This is the file directory for the Roblox runtime version of Pajamas.
This directory is compatible with importing directly into Roblox Studio.

### Setup:

#### Studio File sync

Roblox studio's file sync feature can read from disk and import directly into studio, so we will need to perform the following steps:
- 1: In roblox studio, go to 'File -> Beta Features -> Script Sync', enable it, close the beta window, then restart studio.
- 2: On your PC, make a copy of Pajamas/Roblox (This directory) and store it on your PC in a location that makes sense to you.
(A .zip folder is provided if you're unfamiliar with using git clone, although it will be susceptible to being out of date.)
- 3: With an open place in roblox studio, add a folder named 'Pajamas' to 'game.ReplicatedStorage'.
- 4: Right click on the 'Pajamas' folder, go to 'Script Sync -> Sync with Directory...'.
- 5: In the OS file selection popup, ensure that you have selected the 'Roblox' folder containing all the files, ie. 'Runtime.server.luau' & 'Plugins'
- 6: Roblox studio will ask which version to keep. Ensure you click on 'disk version', as we want studio to read the files from disk.
(Note that while script sync is enabled, there will be a symbol with 2 arrows in the explorer widget, symbolising that these directories are synced - Any edits made in studio will directly update the files stored on your own system.)

### Disclaimer:
This setup process requires the use of a roblox studio beta feature, and as such reliability cannot be guaranteed for using in any context beyond attempting to import the files into studio itself.

#### Rojo

Pajamas has already been setup as a Rojo project. Given the latest version of Rojo, serve in the root folder to find Pajamas in `ReplicatedStorage` under `PajamasRoblox`. You can edit the `default.project.json` file to change this behaviour.
