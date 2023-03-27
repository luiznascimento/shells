#!/bin/bash

watch -n1 -d 'sensors | egrep "fan|temp" | grep -v "0.0"'
