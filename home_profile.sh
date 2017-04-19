#!/bin/bash

# See LICENSE for license details

#
# Module: home_profile.sh
#
# Description:
#       Install ~/.profile
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR="${HOME}"
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Backup of existing file
if [ -f "${DESTDIR}/.profile" ]; then
    cp "${DESTDIR}/.profile" "${DESTDIR}/.profile.bak"
fi

#
# Function: generate-file
#
# Description:
#       Generate the contents of .profile to stdout
#
function generate-file ()
{
    echo 'umask 022'
    echo 'if [ -n "$BASH_VERSION" ]; then'
    echo '    if [ -f "$HOME/.bashrc" ]; then'
    echo '        . "$HOME/.bashrc"'
    echo '    fi'
    echo 'fi'
}

# Create the script
generate-file > "${DESTDIR}/.profile"

# end-of-file: home_profile.sh
