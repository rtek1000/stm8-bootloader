#!/bin/bash

stm8flash -c stlinkv2 -p stm8s003?3 -s 0x83C0 -w firmware_for_bootloader-0x83C0.bin