#!/bin/bash
set -e
msg() {
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="$1"
}

file() {
        MD5=$(md5sum "$1" | cut -d' ' -f1)
        curl --progress-bar -F document=@"$1" "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
        -F chat_id="$CHAT_ID"  \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption=" <b>MD5 Checksum : </b><code>$MD5</code>"
}
free -h
nproc --all
WORK_PATH="$(pwd)"
cd $WORK_PATH
wget https://raw.githubusercontent.com/Navin136/WIP-CI/main/build.sh
rclone copy --drive-chunk-size 256M nk:/ccache.tar.gz $WORK_PATH/ -P
tar xvzf ccache.tar.gz > /dev/null && rm -rf ccache.tar.gz
ROM_NAME=$(grep epo $WORK_PATH/build.sh -m1 | cut -d / -f4)
echo "Building $ROM_NAME"
echo "Current dir is $WORK_PATH"
DEVICE=$(grep unch $WORK_PATH/build.sh | cut -d '-' -f1 | cut -d ' ' -f2 | cut -d '_' -f2)
mkdir $WORK_PATH/$ROM_NAME
cd $WORK_PATH/$ROM_NAME
msg "<b>Repo Sync Started</b>%0A<b>To see status: </b><a href='https://cirrus-ci.com/build/$CIRRUS_BUILD_ID'>Click here</a>"
bash -c "$(head $WORK_PATH/build.sh -n 4)"  || { echo "Failed to Init and sync repo !!!" && msg "<b>Failed to Init and sync repo !!</b>"  && exit 1; }
msg "<b>Repo Sync Completed :)</b>"
git clone https://github.com/X00T-dev/device_asus_X00T device/asus/X00T --depth=1  || { echo "Failed to clone device tree !!!" && msg "<b>Failed to clone device tree !!</b>" && exit 1; }
git clone https://github.com/X00T-dev/vendor_asus vendor/asus --depth=1 || { echo "Failed to clone vendor tree !!!" && msg "<b>Failed to clone vendor tree !!</b>" && exit 1; }
git clone https://github.com/X00T-dev/kernel_asus_sdm660_Arrow kernel/asus/sdm660 --depth=1 || { echo "Failed to clone kernel tree !!!" && msg "<b>Failed to clone kernel tree !!</b>"  && exit 1; }
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR=$WORK_PATH/ccache
export CCACHE_COMPRESS=true
ccache -o compression=true # some roms use this in envsetup
ccache -M 20G
ccache -z
pwd
bash -c "$(tail $WORK_PATH/build.sh -n 4)" || { echo "Failed to Start build !!!" && msg "<b>Failed to Start build !!</b>" && exit 1; }
comp() {
	tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
}
file $WORK_PATH/$ROM_NAME/build.log
cd $WORK_PATH
FILENAME=$WORK_PATH/$ROM_NAME/out/target/product/$DEVICE/*$DEVICE*.zip
ZIPNAME=$(echo $FILENAME | cut -d '/' -f 7)
if [ -f $WORK_PATH/$ROM_NAME/out/target/product/$DEVICE/*$DEVICE*.zip ]
then
	msg "<b>Build Completed ....</b>%0A<b>Uploading to Team drive</b>"
	rclone copy -P $WORK_PATH/$ROM_NAME/out/target/product/$DEVICE/*$DEVICE*.zip nk:/$ZIPNAME
	msg "<b>Uploaded Successfully ...</b>%0A<b>Link: </b><code>$(rclone link nk:$ZIPNAME)</code>"
	comp ccache 1
        rclone copy -P --drive-chunk-size 256M ccache.tar.gz nk: || { echo "Failed to Upload ccache !!!" && exit 1; } # Upload ccache
else
	msg "<b>Build Not Completed ....</b>%0A<b>Uploading ccache</b>"
	comp ccache 1
	rclone copy -P --drive-chunk-size 256M ccache.tar.gz nk: || { echo "Failed to Upload ccache !!!" && exit 1; } # Upload ccache
	msg "<code>ccache uploaded</code>"
	rm ccache.tar.gz
fi
