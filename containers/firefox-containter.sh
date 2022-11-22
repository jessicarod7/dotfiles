#!/bin/bash
podman run --name usecase_firefox \
	-d -p 5800:5800 \
	-e DISPLAY_WIDTH=2560 -e DISPLAY_HEIGHT=1301 \
	-v $(pwd)/usecase_firefox_configdata:/config:z \
       	--mount type=bind,src=/etc/localtime,target=/etc/localtime,readonly \
	--shm-size=2g \
	jlesage/firefox:latest
