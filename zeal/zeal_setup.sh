#!/bin/bash
if [ -z "$1" ]; then
    podman build -t zeal-builder -f Containerfile.zeal ../containers
else
    podman build --build-arg COMMIT=$1 -t zeal-builder -f Containerfile.zeal ../containers
fi
podman run -dt --name zeal-build zeal-builder:latest
sudo mkdir /opt/zeal
sudo chown -R <uid>:<gid> /opt/zeal
sudo chmod -R ug+w /opt/zeal
podman cp zeal-build:/export/. /opt/zeal
podman stop zeal-build && podman rm zeal-build

mkdir /opt/zeal/feed_srcs
ln -s /opt/zeal/share/applications/org.zealdocs.zeal.desktop ~/.local/share/applications/org.zealdocs.zeal.desktop
sudo dnf install qt5-qtwebengine

