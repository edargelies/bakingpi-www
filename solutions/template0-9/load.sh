#!/bin/bash
make clean
make
cp kernel7.img /media/eric/boot/
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2