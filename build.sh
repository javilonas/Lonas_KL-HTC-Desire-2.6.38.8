#!/bin/bash
# Script Lonas_KL

ZB_DIR=./zipbuild

K_DIR=kernel
M_DIR=system/lib/modules

SKELETON=skeleton.zip
ZIP=Lonas_KL-Desire-2.6.38.8-$(date +%Y%m%d).zip
TOOLCHAIN="/home/lonas/android/omni/prebuilts/gcc/linux-x86/arm/arm-eabi-4.4.3/bin/arm-eabi-"

clean_kernel()
{
	make distclean
        make clean
}

clean_temp()
{
	rm -rf ${ZB_DIR}/lib
	rm -rf ${ZB_DIR}/kernel
	rm -rf ${ZB_DIR}/system
	rm -f ${ZB_DIR}/kernel*.zip
}

build_kernel()
{
	make ARCH=arm CROSS_COMPILE=$TOOLCHAIN lonas_defconfig
        make -j6 ARCH=arm CROSS_COMPILE=$TOOLCHAIN
}

build_zip()
{
	mkdir -p ${ZB_DIR}/${K_DIR}
	mkdir -p ${ZB_DIR}/${M_DIR}

	cp arch/arm/boot/zImage ${ZB_DIR}/${K_DIR}/
	make modules_install INSTALL_MOD_PATH=${ZB_DIR} INSTALL_MOD_STRIP=1
	find ${ZB_DIR}/lib/modules -type f -name "*.ko" -exec mv {} ${ZB_DIR}/${M_DIR} \;

	cd ${ZB_DIR}
	cp ${SKELETON} ${ZIP}
	zip -r ${ZIP} ${K_DIR} ${M_DIR}
	cd -
}

case $1 in
	ck)
		clean_kernel
		;;
	ct)
		clean_temp
		;;
	clean)
		clean_kernel
		clean_temp
		;;
	bk)
		build_kernel
		;;
	bz):
		build_zip
		;;
	all)
		clean_kernel
		clean_temp
		build_kernel
		build_zip
		;;
	*)
		echo "Usage: build.sh <target>"
		echo "Targets are:"
		echo "	ck	==>    Clean compiled kernel tree, calls make distclean"
		echo "	ct	==>    Clean generated zip files etc. under zipbuild directory"
		echo "	clean	==>    Clean all, run ck and ct"
		echo "	bk	==>    Build kernel using existing config"
		echo "	bz	==>    Build update zip archiave"
		echo "	all	==>    clean, bk, then bz"
esac
