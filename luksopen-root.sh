#! /bin/bash

source .envrc

cryptsetup luksOpen $ROOT_PARTITION cryptroot
