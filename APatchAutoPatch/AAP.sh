#!/system/bin/sh
#by nya
#2024-02-06

RED="\E[1;31m"
YELLOW="\E[1;33m"
BLUE="\E[1;34m"
GREEN="\E[1;32m"
RESET="\E[0m"

# Android 检测
if [[ ! -e /vendor/build.prop ]]; then
	echo -e "${RED}E: RUN THIS SCRIPT IN ANDROID!${RESET}"
	exit 1
fi
# ROOT 检测
if [[ "$(id -u)" != "0" ]]; then
	echo -e "${RED}E: RUN THIS SCRIPT WITH ROOT PERMISSION!${RESET}"
	exit 2
fi

SUPERKEY=${RANDOM}
WORKDIR=/data/adb/nyatmp

mkdir -p ${WORKDIR}
echo -e "${BLUE}I: Loading files...${RESET}"
curl -LO --progress-bar "https://github.com/nya-main/Small-Tools/raw/main/APatchAutoPatch/AAPFunction" -o ${WORKDIR}/AAPFunction || EXITSTATUS=$?
if [[ $EXITSTATUS != 0 ]]; then
	echo -e "${RED}E: SOMETHING WENT WRONG! CHECK YOUR INTERNET CONNECTION!${RESET}"
	exit 1
else
	echo -e "${GREEN}I: Done.${RESET}"
fi

while getopts ":hi:" OPT; do
	case $OPT in
	i) # 处理选项i
		BOOTPATH="${OPTARG}"
		;;
	h)
		echo -e "${GREEN}See here:https://github.com/nya-main/Small-Tools/tree/main/APatchAutoPatch${RESET}"
		;;
	v)
		echo -e "${GREEN}"
		cat <<-EOF
			        APatch Auto Patch Tool
			        Written by nya
			        Version: 0.0.1
		EOF
		;;
	:)
		echo "${YELLOW}Option -$OPTARG requires an argument..${RESET}" >&2 && exit 1
		;;

	?)
		echo "${RED}Invalid option: -$OPTARG${RESET}" >&2 && exit 1
		;;
	esac
done

get_device_boot
get_tools
patch_boot
flash_boot
