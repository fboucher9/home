#!/bin/bash

# See LICENSE for license details

#
# Module: home_inputrc.sh
#
# Description:
#       Configuration of readline library.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Do backup of existing file
if [ -f "${DESTDIR}/.inputrc" ]; then
    cp "${DESTDIR}/.inputrc" "${DESTDIR}/.inputrc.bak"
fi

#
# Function: generate-file
#
# Description:
#       Generate contents of file to stdout.
#
function generate-file ()
{
    echo 'set bell-style none'
}

# Create the file in the home folder
generate-file > "${DESTDIR}/.inputrc"

# end-of-file: home_inputrc.sh
