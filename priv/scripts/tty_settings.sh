#!/bin/sh

DEVICE=$1
BIT_RATE=$2

# Open the tty device and set the bit rate using stty command
stty -F "$DEVICE" "$BIT_RATE" raw -echo -echoe -echok
