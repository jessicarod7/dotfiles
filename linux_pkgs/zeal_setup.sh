#!/bin/bash
podman build -t --build-arg VERSION=$1 zeal-builder -f Containerfile.zeal ../containers
podman run -d -n zeal-build zeal-builder:latest
sudo podman cp zeal-build:/export /opt/zeal
sudo chown -R :camrod /opt/zeal
sudo chmod -R g+w /opt/zeal
podman stop zeal-build && podman rm zeal-build

mkdir /opt/zeal/feed_srcs
ln -s /opt/zeal/share/applications/zeal.desktop ~/.local/share/applications/org.zeal.zeal.desktop
