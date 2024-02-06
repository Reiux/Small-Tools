# APatch Auto Patch Tool

This script will:

- Obtain the current boot image of your phone.
- Download the latest KernelPatch and magiskboot from GitHub Release.
- Patch the extracted boot image.
- Flash the patched image.

---

## Usage

- Open Termux

- Prepare

```bash
cd ${HOME}
curl -LO https://github.com/nya-main/Small-Tools/raw/main/APatchAutoPatch/AAP.sh
chmod +x AAP.sh
```

*After this, You can directly run AAP.sh after command tsu is executed.*

- Run

Example:

```bash
# Before you run this script, grant root permission
tsu

# Directly run
./AAP.sh 

# Specify a boot **IMAGE** path (NOT BOOT PARTITION PATH)
./AAP.sh -i /sdcard/Download/boot_a.img
```

---

## TODO

- [x] User-specified boot image path.

---

If you encounter any issues, please submit a issue on github or provide feedback to me:[Telegram](https://t.me/nya_main)
