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
docker login -u navin136 -p "$PASSWORD"
sudo docker build . -t navin136/builder || { echo "Docker Build failed" && msg "<b>Docker Build Failed</b>" && exit 1; }
docker push -t navin136/builder || { echo "Docker Push failed" && "msg <b>Docker Push Failed</b>" && exit 1; }
msg "<b>Docker Built and Uploaded successfully..</b>%0A<b>Link: </b><a href="https://hub.docker.com/repository/docker/navin136/builder">Click Here</a>"
