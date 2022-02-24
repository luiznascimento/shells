#!/bin/bash

grub2-set-default $(awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg | egrep "3.10.0-1160" | head -1 | awk '{ print $1 }' )
grub2-editenv list
