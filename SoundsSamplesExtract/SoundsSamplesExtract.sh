#!/bin/bash
###################################################################################################################################################
# Script to extract Installer packages that are downloaded by either Apples Logic X or GarageBand applications.
#
# last edited: 2020-02-24
#
# This script was tested under
# macOS High Sierra 10.13.1
# macOS Mojave 10.14.6
#
# WAS BASED ON APPSTOREEXTRACT by maxschlapfer / MacAdminHelpers
# https://github.com/maxschlapfer/MacAdminHelpers/tree/master/AppStoreExtract
#
# Edited and extended
# by Blake Suggett
# 
###################################################################################################################################################
# Short documentation
# - This script needs the temporary download folder from either Logic or GarageBand 'com.apple.MusicApps', this is individual by host
#   and is extracted by using "getconf DARWIN_USER_CACHE_DIR".
# - The folder /Users/Shared/GarageBand/ or /Users/Shared/Logic/ is generated and used as the scripts output folder. A subfolder will be gernerated
#	called Packages that will contain the PKGs captured.
# - Open Terminal and start this script (if needed make it executable first), keep the window open and select the product you want to capture
#	installers for.
# - Start GarageBand or Logic Application for the first time, it will download the minimum sample packages for the app to be able to run.
#	Once completed, you will be prompted for root access to install the packages. DON'T dismiss, cancel, or close the prompt.
# - Go back to the script and press any key to stop the capture. You'll be prompted to finalise and make a DMG. Select y
# - You'll be prompted to type in the name of the dmg filename which will also be the volume name. Type in a name of your desire. Its
#	recommended to exclude space and other special characters from the filename / volume name. Its suggested to use underscores in place of spaces.
# - A DMG will be created of the packages directory in the parent directory eg /Users/Shared/GarageBand/created.dmg.
#	These captured packages can now be deployed using a InstallPKGfromDMG script method.
# 
# - Rinse and repeat for each sound library or multiple libraries you wish to obtain the installers for.
#
# - Deployment using Jamf pro can be acheived using the script linked below
#	InstallPKGsfromDMG
#	https://www.jamf.com/jamf-nation/third-party-products/files/1048/installpkgsfromdmg
# 
###################################################################################################################################################

# Hardcoded values of where garageband or logic downloads its PKG installers to (this can be changed if apple changes the path at a later date)
AppleLogicPath="$(getconf DARWIN_USER_CACHE_DIR)com.apple.MusicApps"
GarageBandPath="$(getconf DARWIN_USER_CACHE_DIR)com.apple.garageband10/com.apple.MusicApps"

# Ask user which product they want to capture installers for
while [[ "${product}" != "L" && "${product}" != "G" ]]
do
	echo -e '\n\nWhich product? Apples (L)ogic or Apples (G)arageBand (L/G)?'
	read product
	if [[ "${product}" == "L" ]]
	then
		com_apple_MusicApps_dir="${AppleLogicPath}"
		SharedDirectoryProductName="Logic"
		echo "Setting capture path to...: ${com_apple_MusicApps_dir}"
		product="L"
	elif [[ "${product}" == "G" ]]
	then
		com_apple_MusicApps_dir="${GarageBandPath}"
		SharedDirectoryProductName="GarageBand"
		echo "Setting capture path to...: ${com_apple_MusicApps_dir}"
		product="G"
	elif [[ "${product}" != "L" || "${product}" != "G" ]]
	then
		echo "Incorrect selection - Please select either L for Logic or G for GarageBand"
	fi
done

# Make garageband or logic installer download path if it doesn't exist - Helpful if the product hasn't launched and created the package directory. The script won't error out. This might error out at a later date if apple chooses to download into a different directory than com.apple.MusicApps
if [[ ! -d "${com_apple_MusicApps_dir}" ]]
then
	mkdir -p "${com_apple_MusicApps_dir}"
fi

# Make the directories in the /Users/Shared/ path ready to copy the files into. It doesn't actually copy, but links the files to save disk space.
mkdir -p "/Users/Shared/$SharedDirectoryProductName/Packages"

# Sets the destinations used by the script.
Destination="/Users/Shared/$SharedDirectoryProductName/Packages/"
DMGDestination="/Users/Shared/$SharedDirectoryProductName/"

# Script runs at this point linking into the /Users/Shared/destination directory. Waiting for the user to press any key to stop the copying process
echo ""
echo "Press any key after downloading sound libraries to finish. Remember not to provide admin creds to perform the installation"
myinput=''

if [ -t 0 ]
then
	stty -echo -icanon -icrnl time 0 min 0
fi

while [ "x${myinput}" = "x" ]
do
	# The line directly below is critical as its the one performing the linking into the /Users/Shared/Destination directory.
	find "$com_apple_MusicApps_dir" -name \*.pkg  | xargs -I {} sh -c 'ln "$1" "$2$(basename $1)" 2> /dev/null ; cp -n "$1" "$2$(basename $1)" 2> /dev/null' - {} "$Destination" "$com_apple_MusicApps_dir"
	myinput="`cat -v`"
	# The line below forces the script to be slowed
	sleep 0.05
done

if [ -t 0 ]
then
	stty sane
fi

# Stops the linking and prompts the user do they want to make a DMG
echo -e '\n\nDo you want to finalize the package and make a DMG? (N/y)\n'
read -n 1 -s  myinput
if [ "$myinput" == "y" ]
then
	echo -e '\nType the name of the DMG package. This will be the DMG filename and volume name. Exclude the file extension.'
	read finaldmg
	echo -e '\nThe packages in the below directory will be added into a single dmg file. This could take a while.' 
	echo ${Destination}
hdiutil create -fs HFS+ -srcfolder "${Destination}" -volname "${finaldmg}" -format UDRO "${DMGDestination}${finaldmg}"
fi