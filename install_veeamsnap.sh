#!/bin/bash

cp veeamsnap.ko /lib/modules/$(uname -a | awk '{ print $3 }')/extra/
depmod -a
modprobe veeamsnap
yum install https://download2.veeam.com/veeam-release-el7-1.0.8-1.x86_64.rpm -y
yum install veeam -y
