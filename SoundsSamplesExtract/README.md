# Sound Libraries Extractor Script
Script to extract sound library installer packages from applications Logic or GarageBand.

### Source Information / Credit

This script is based on maxschlapfer/MacAdminHelpers/AppStoreExtract and has been adapted to perform the same task for capturing the sound library installers for either Logic or GarageBand.
https://github.com/maxschlapfer/MacAdminHelpers/tree/master/AppStoreExtract

Based on an idea from Tim Sutton and Rich Trouton for downloading from the AppStore:
http://derflounder.wordpress.com/2013/10/19/downloading-microsofts-remote-desktop-installer-package-from-the-app-store/

Rich although published a detailed tutorial on how to use the script:
https://derflounder.wordpress.com/2015/11/19/downloading-installer-packages-from-the-mac-app-store-with-appstoreextract/


### IMPORTANT
Before you start using this script, please make sure to have the needed licenses covered (for example by site license, Apps&Books or single licenses).

This script was tested under macOS High Sierra 10.13.1 and macOS Mojave 10.14.6. 

__Attention__:  
hdiutil will build DMGs with HFS+. This was chosen for maximum compatibility.

### How to use
This script needs the temporary download folder from either Logic or GarageBand, this different for both Logic and GarageBand. They're also a unique individual directory for each user and host. It's extracted from within the script using "getconf DARWIN_USER_CACHE_DIR".

Apple may change the paths in which the applications download to, in this event editing the variables listed below in the script accordingly is easy.
AppleLogicPath="$(getconf DARWIN_USER_CACHE_DIR)com.apple.MusicApps"
GarageBandPath="$(getconf DARWIN_USER_CACHE_DIR)com.apple.garageband10/com.apple.MusicApps"

- Open terminal and start this script (make it executable first), keep the window open.

- You'll be prompted for which product you want to collect the installers for. Apples (L)ogic or Apples (G)arageBand? Using the keyboard select either L for Logic or G for GarageBand. Keep the window open.

- The script generates and uses the directory either "/Users/Shared/Logic/Packages" or "/Users/Shared/GarageBand/Packages" as a destination depending on your chosen product. Keep the window open.

- Open Logic or GarageBand for the first time, the application will download the minimum amount of installers in order to run the application.

- When prompted for admin creds to install them, return to terminal and press any key.

	All the minimum installers needed to launch the applcation will be linked to the below directories based on the product selected to be captured for.

	/Users/Shared/Logic/Packages/
	/Users/Shared/GarageBand/Packages/

- You'll be prompted to finalise. Hit y on the keyboard to start the DMG creation process. Any other selection will exit the script and return you to the terminal prompt.

- After hitting y, you'll be promoted to type a name for the DMG filename/volume name. As an example you could use Apple_Logic_Pro_x_10.4.8_Required_Essential_Sounds_and_Loops.
	Name it something meaningful that reflect the purpose.
	You should try exclude spaces and special characters from the name you choose.

- A DMG will begin to be made of the packages directory in the product directory.

	eg /Users/Shared/Logic/Apple_Logic_Pro_x_10.4.8_Required_Essential_Sounds_and_Loops.dmg

You now have a DMG containing all the installers that are the minimum required to launch the product.

- Return to GarageBand or Logic admin creds prompt, supply creds to install the packages needed to launch the product.

- Remove all files (if any) from the below paths
	/Users/Shared/Logic/Packages/
	/Users/Shared/GarageBand/Packages/

- Using GarageBand or Logic, open Sound Libraries Manager.

- Open terminal and start this script again, keep the window open.

Rinse and repeat for each sound library you want to capture the installers for. This might mean all of them in a single package, some in a single package, or each sound library in its own package. The choice is yours.

### Things to note / known problems
* When deploying/installing the sound libraries, some of the installers require the application to be installed else they will fail.
* Some libraries overlap/are included in other libraries. Installing some but not others will result in some being marked in the GUI as incomplete
* After installing libraries

### Deployment using Jamf pro can be acheived using the script linked below
InstallPKGsfromDMG
https://www.jamf.com/jamf-nation/third-party-products/files/1048/installpkgsfromdmg
