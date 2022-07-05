#!/bin/bash

binfolder=/usr/local/bin
visudo_path=/private/etc/sudoers.d/battery
# Visudo instructions
visudoconfig="
# Visudo settings for the autoclam utility
# intended to be placed in $visudo_path on a mac
Cmnd_Alias      BATTERYOFF = $binfolder/smc -k CH0B -w 02, $binfolder/smc -k CH0C -w 02
Cmnd_Alias      BATTERYON = $binfolder/smc -k CH0B -w 00, $binfolder/smc -k CH0C -w 00
$( whoami ) ALL = NOPASSWD: BATTERYOFF
$( whoami ) ALL = NOPASSWD: BATTERYON
"

function enable_charging() {
	sudo smc -k CH0B -w 00
	sudo smc -k CH0C -w 00
}

function disable_charging() {
	sudo smc -k CH0B -w 02
	sudo smc -k CH0C -w 02
}

function is_smc_charging_on() {
	hex_status=$( smc -k CH0B -r | awk '{print $4}' | sed s:\):: )
	if [[ "$hex_status" == "00" ]]; then
		echo "ok"
	else
		echo ""
	fi
}

function get_battery_percentage() {
	battery_percentage=`pmset -g batt | tail -n1 | awk '{print $3}' | sed s:\%\;::`
	echo "$battery_percentage"
}

if [ -z "$action" ]; then
	if [ ! -f $visudo_path ]; then
		echo "Please run battery visudo first"
		exit 1;
	fi

	while [ true ]; do
		clamshellmode=`ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState | head -1 | grep Yes`
		ischarging=$(is_smc_charging_on)
		if [[ $clamshellmode && $ischarging ]]; then
			disable_charging
		elif [[ -z $clamshellmode && -z $ischarging ]]; then
			enable_charging
		fi
		sleep 30
	done
fi

# Visudo message
if [[ "$action" == "visudo" ]]; then
	echo -e "This will write the following to $visudo_path:\n"
	echo -e "$visudoconfig"
	echo "If you would like to customise your visudo settings, exit this script and edit the file manually"
	echo -e "\nPress any key to continue\n"
	read
	echo -e "$visudoconfig" | sudo tee $visudo_path
	sudo chmod 0440 $visudo_path
	echo -e "Visudo file $visudo_path now contains: \n"
	sudo cat $visudo_path
	exit 0
fi
