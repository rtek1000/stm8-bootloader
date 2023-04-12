#!/bin/bash

stm8flash -c stlinkv2 -p stm8s003?3 -s 0x8000 -w stm8_bootloader_eclipse_for_app_at_0x83C0.bin