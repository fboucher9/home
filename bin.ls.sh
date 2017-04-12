#!/bin/bash
/bin/ls \
    -F \
    --color=auto \
    --group-directories-first \
    "${@}"
