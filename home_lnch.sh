#!/bin/bash

# See LICENSE for license details

#
# Module: home_lnch.sh
#
# Description:
#       Startup script for lnch window manager.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Make a backup of existing script
if [ -f "${DESTDIR}/.lnchrc" ]; then
    cp "${DESTDIR}/.lnchrc" "${DESTDIR}/.lnchrc.bak"
fi

#
#
#
function generate-script ()
{
    # Script header
    echo '#!/bin/snck'

    # Use display :2
    echo 'set DISPLAY localhost:2.0'

    # Force use of custom shell
    echo 'set SHELL /bin/snck'

    # Login
    echo 'source ${HOME}/.snckrc'

    # Set wallpaper
    echo '${HOME}/.dsrtrc'

    # Change directory to home folder
    echo 'cd ${HOME}'

    # Launch window manager as last command
    echo 'shell /usr/bin/lnch'

}

# Create script in home folder
generate-script > "${DESTDIR}/.lnchrc"

# Make the script executable
chmod +x "${DESTDIR}/.lnchrc"

# end-of-file: home_lnch.sh
