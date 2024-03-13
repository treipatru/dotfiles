#!/bin/bash

count=$(dnf check-update -q | grep -v -e '^$' | wc -l)

if [[ $count -gt 0 ]]; then
    echo  $count
else
    echo ""
fi
