#!/system/bin/sh
#by nya
#2024-02-04

RED="\E[1;31m"
YELLOW="\E[1;33m"
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
	echo "I: While getting boot image..."
	echo "I: Current boot: ${BOOTSUFFIX}(If empty: A-Only devices)"
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
	chmod +x kptools-android
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
	echo "I: Downloading magiskboot..."
	curl -LO "https://github.com/magojohnji/magiskboot-linux/raw/main/arm64-v8a/magiskboot"
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: DOWNLOAD FAILED${RESET}"
		echo "Please check your internet connection."
		exit 1
	fi
	chmod +x magiskboot
	echo "I: Done."
}

patch_boot() {
	echo "I: Unpacking image..."
	./magiskboot unpack boot${BOOTSUFFIX}.img
	EXITSTATUS=$?
	if [[ $EXITSTATUS != 0 ]]; then
		echo -e "${RED}E: UNPACK BOOT IMAGE FAILED${RESET}"
		exit 1
	fi
	echo "I: Done."
	echo "I: Patching image...Current Superkey: ${SUPERKEY}"
	./kptools-android -p -k kpimg-android -s ${SUPERKEY} -i kernel -o patchedkernel
	EXITSTATUS=$?
	if [[ ${EXITSTATUS} != 0 ]]; then
		echo -e "${RED}E: PATCH FAILED${RESET}"
		exit 1
	fi
	echo "I: Done"
	echo "I: Repacking..."
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
	dd if=${WORKDIR}/patched_boot.img of=/dev/block/by-name/boot${BOOTSUFFIX}
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
	echo "I: Cleaning temporary files..."
	rm -rf ${WORKDIR}
	echo "I: Done."
}

get_boot
get_tools
patch_boot
flash_boot
