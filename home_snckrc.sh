#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.snckrc
#
# Description:
#       Login script for snck shell.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Backup existing file
if [ -f "${DESTDIR}"/.snckrc ]; then
    cp "${DESTDIR}"/.snckrc "${DESTDIR}"/.snckrc.bak
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
generate-file > "${DESTDIR}"/.snckrc

# end-of-file: ~/.snckrc
