#!/bin/bash
# Generates a Plymouth theme with a Fedora + Fractal Design watermark
sudo cp -r /usr/share/plymouth/themes/spinner /usr/share/plymouth/themes/fractal
sudo rm /usr/share/plymouth/themes/fractal/spinner.plymouth
sudo cp ./fedora-fractal.png /usr/share/plymouth/themes/fractal/watermark.png
sudo cp ./fractal.plymouth /usr/share/plymouth/themes/fractal/fractal.plymouth

