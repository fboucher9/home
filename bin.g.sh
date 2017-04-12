#!/bin/bash
grep \
    -n \
    -r \
    -i \
    --exclude-dir='.git' \
    --exclude=tags \
    --exclude='*.o' \
    --exclude='_obj*' \
    "${@}" \
    . > /tmp/grep.txt
vim -q /tmp/grep.txt
