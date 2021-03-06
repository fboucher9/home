#!/bin/bash

# See LICENSE for license details

#
# Module: home_snckrc.sh
#
# Description:
#       Login script for snck shell.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Backup existing file
if [ -f "${DESTDIR}/.snckrc" ]; then
    cp "${DESTDIR}/.snckrc" "${DESTDIR}/.snckrc.bak"
fi

#
# Function: generate-file
#
# Description:
#       Generate contents of file to stdout
#
function generate-file ()
{
    echo '#!/bin/snck'
    echo "set PATH ${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
    echo 'set EDITOR vim'
    echo 'set MANPAGER manpager'
    echo 'set _SNCKRC +${_SNCKRC}'
}

# Create script in home folder
generate-file > "${DESTDIR}/.snckrc"

# end-of-file: home_snckrc.sh
