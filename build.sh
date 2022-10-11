#!/bin/bash
msg() {
	curl -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" \
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
	-F caption="$2 | <b>MD5 Checksum : </b><code>$MD5</code>"
}
docker login -u navin136 -p '#$'$PASSWORD || { echo "Docker Login failed" && msg "<b>Docker Login Failed</b>" && exit 1; }
msg "<b>Hey!! Docker Build Triggered..</b>%0A<b>Wanna see Progress: </b><a href='https://cirrus-ci.com/github/Navin136/docker'>Click Here</a>"
BUILD_START=$(date +"%s")
sudo docker build . -t navin136/builder || { echo "Docker Build failed" && msg "<b>Docker Build Failed</b>" && exit 1; }
BUILD_END=$(date +"%s")
DIFF=$((BUILD_END - BUILD_START))
docker push navin136/builder || { echo "Docker Push failed" && msg "<b>Docker Push Failed</b>" && exit 1; }
msg "<b>Docker Built and Uploaded successfully..</b>%0A<b>Link: </b><a href='https://hub.docker.com/repository/docker/navin136/builder'>Click Here</a>%0A<b>Time taken: </b><code>$((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</code>"
