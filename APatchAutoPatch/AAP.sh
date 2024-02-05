#!/system/bin/sh
#by nya
#2024-02-04

RED="\E[1;31m"
YELLOW="\E[1;33m"
BLUE="\E[1;34m"
GREEN="\E[1;32m"
RESET="\E[0m"

if [[ "$(uname -o)" != "Android" ]]; then
	echo -e "${RED}E: RUN THIS SCRIPT IN ANDROID!${RESET}"
	exit 2
fi
if [[ ! -e /dev/block/by-name/boot ]]; then
	BOOTSUFFIX=$(getprop ro.boot.slot_suffix)
fi
SUPERKEY=${RANDOM}
WORKDIR=/data/adb/nyatmp

mkdir -p ${WORKDIR}
cd ${WORKDIR}

get_boot() {
	echo "${BLUE}I: Getting boot image...${RESET}"
	echo "${BLUE}I: Current boot: ${BOOTSUFFIX}(If empty: A-Only devices)${RESET}"
	dd if=/dev/block/by-name/boot${BOOTSUFFIX} of=${WORKDIR}/boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: GET BOOT IMAGE FAILED${RESET}"
		echo -e "Maybe the boot path I prepared in advance is wrong. You can contact me through Telegram@nya_main"
		exit 1
	fi
	echo "${GREEN}I: Done.${RESET}"
}

get_tools() {
	echo "${BLUE}I: Downloading the latest kptool-android...${RESET}"
	curl -LO "https://github.com/bmax121/KernelPatch/releases/latest/download/kptools-android"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	chmod +x kptools-android
	echo "${GREEN}I: Done.${RESET}"
	echo "${BLUE}I: Downloading the latest kpimg-android...${RESET}"
	curl -LO "https://github.com/bmax121/KernelPatch/releases/latest/download/kpimg-android"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	echo "${GREEN}I: Done.${RESET}"
	echo "${BLUE}I: Downloading magiskboot...${RESET}"
	curl -LO "https://github.com/magojohnji/magiskboot-linux/raw/main/arm64-v8a/magiskboot"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	chmod +x magiskboot
	echo "${GREEN}I: Done.${RESET}"
}

patch_boot() {
	echo "${BLUE}I: Unpacking image...${RESET}"
	./magiskboot unpack boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: UNPACK BOOT IMAGE FAILED${RESET}"
		exit 1
	fi
	echo "${GREEN}I: Done.${RESET}"
	echo "${BLUE}I: Patching image...Current Superkey: ${SUPERKEY}${RESET}"
	./kptools-android -p -k kpimg-android -s ${SUPERKEY} -i kernel -o patchedkernel
	EXITSTATUS=$?
	if [[ ${EXITSTATUS} != 0 ]]; then
		echo -e "${RED}E: PATCH FAILED${RESET}"
		exit 1
	fi
	echo "${GREEN}I: Done${RESET}"
	echo "${BLUE}I: Repacking...${RESET}"
	rm kernel
	mv patchedkernel kernel || EXITSTATUS=1
	./magiskboot repack boot${BOOTSUFFIX}.img || EXITSTATUS=1
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: REPACK FAILED${RESET}"
		exit 1
	fi
	echo "I: Done."
}

flash_boot() {
	echo -e "${BLUE}I: Flashing boot image...${RESET}"
	dd if=${WORKDIR}/new-boot.img of=/dev/block/by-name/boot${BOOTSUFFIX}
	EXITSTATUS=$?
	if [[ ${EXITSTATUS} != 0 ]]; then
		echo -e "${RED}E: WARNING!!! IMAGE FLASH FAILED${RESET}"
		echo -e "${YELLOW}I: Now trying to restore...${RESET}"
		dd if=${WORKDIR}/boot${BOOTSUFFIX}.img of=/dev/block/by-name/boot${BOOTSUFFIX}
		EXITSTATUS=$?
		if [[ ${EXITSTATUS} != 0 ]]; then
			echo -e "${RED}E: WARNING!!! RESTORE FAILED!!!"
			echo "I: Even I can't help you now. You can try to restore boot manually.${RESET}"
			exit 1
		fi
		echo "${YELLOW}I: Restore Sucessfully.${RESET}"
	fi
	echo "${GREEN}I: Flash done.${RESET}"
	echo "${BLUE}I: Cleaning temporary files...${RESET}"
	rm -rf ${WORKDIR}
	echo "${GREEN}I: Done.${RESET}"
	cat <<EOF
####################################


    YOUR SUPERKEY IS ${SUPERKEY}

    DON'T FORGET IT!!


####################################
EOF
}

get_boot
get_tools
patch_boot
flash_boot
