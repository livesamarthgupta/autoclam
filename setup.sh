#!/bin/bash

# Get smc source and build it
tempfolder=~/.battery-tmp
binfolder=/usr/local/bin
mkdir -p $tempfolder

smcfolder="$tempfolder/smc"
echo -e "\nCloning fan control version of smc"
git clone --depth 1 https://github.com/hholtmann/smcFanControl.git $smcfolder &> /dev/null
cd $smcfolder/smc-command
echo -e "\nMaking smc from source"
make &> /dev/null

# Move built file to bin folder
echo -e "\nMove smc to executable folder"
sudo mkdir -p $binfolder
sudo mv $smcfolder/smc-command/smc $binfolder
sudo chmod u+x $binfolder/smc

# Write battery function as executable
autoclamfolder="$tempfolder/battery"
echo -e "\nCloning autoclam repository"
git clone --depth 1 https://github.com/livesamarthgupta/autoclam.git $autoclamfolder &> /dev/null
echo "Writing script to $binfolder/battery"
sudo cp $autoclamfolder/battery.sh $binfolder/battery
sudo cp $autoclamfolder/battery.sh ~/Applications/autoclam
# sudo cp -R $autoclamfolder/autoclam.app ~/Applications/autoclam.app
sudo chmod 755 $binfolder/battery
sudo chmod u+x $binfolder/battery
sudo chmod 755 ~/Applications/autoclam
sudo chmod u+x ~/Applications/autoclam

# Run visudo
battery visudo

# Remove tempfiles
cd ../..
echo -e "\nRemoving temp folder $tempfolder"
rm -rf $tempfolder
echo -e "\nSmc binary built"

echo -e "\n🎉 autoclam app installed. Add autoclam app to login items"