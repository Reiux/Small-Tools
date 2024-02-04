#!/system/bin/sh
#by nya
#2024-02-04

if [[ $(uname -o) == "Android" ]]; then
	echo -e "${RED}E: RUN THIS SCRIPT IN ANDROID!"
	exit 2
fi

RED="\E[1;31m"
YELLOW="\E[1;33m"
RESET="\E[0m"

BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
WORKDIR=/data/adb/nyatmp

mkdir -p ${WORKDIR}
cd ${WORKDIR}

get_boot() {
	echo "I: While getting boot image..."
	echo "I: Current boot slot: ${BOOTSUFFIX}"
	dd if=/dev/block/by-name/boot${BOOTSUFFIX} of=${WORKDIR}/boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: GET BOOT IMAGE FAILED${RESET}"
		echo -e "Maybe the boot path I prepared in advance is wrong. You can contact me through Telegram@nya_main"
		exit 1
	fi
	echo "I: Done."
}

get_tools() {
	echo "I: Downloading the latest kptool-android..."
	curl -LO "https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-android"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	echo "I: Done."
	echo "I: Downloading the latest kpimg-android..."
	curl -LO "https://github.com/bmax121/KernelPatch/releases/latest/download/kpimg-android"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	echo "I: Done."
}

patch_boot() {}

flash_boot() {
	dd if=${WORKDIR}/patched_boot${BOOTSUFFIX}.img of=/dev/block/by-name/boot${BOOTSUFFIX}
	EXITSTATUS=$?
	if [[ ${EXITSTATUS} != 0 ]]; then
		echo -e "${RED}E: WARNING!!! IMAGE FLASH FAILED${RESET}"
		echo -e "${YELLOW}I: Now restoring...${RESET}"
		dd if=${WORKDIR}/boot${BOOTSUFFIX}.img of=/dev/block/by-name/boot${BOOTSUFFIX}
		EXITSTATUS=$?
		if [[ ${EXITSTATUS} != 0 ]]; then
			echo -e "${RED}E: WARNING!!! RESTORE FAILED"
			echo "I: Even I can't help you now. You can try to restore boot manually.${RESET}"
			exit 1
		fi
		echo "${YELLOW}I: Restore Sucessfully.${RESET}"
	fi
	echo "I: Flash done."
}
