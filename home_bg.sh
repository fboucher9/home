#!/bin/bash

# See LICENSE for license details

#
# Module: home_bg.sh
#
# Description:
#       Install ~/bin/_ which launches an application in the background
#
# Comments:
#       All inputs and outputs are redirected to null device.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure bin folder has been created
if [ ! -d "${DESTDIR}/bin" ]; then
    mkdir -p "${DESTDIR}/bin"
fi

# Backup of existing file
if [ -f "${DESTDIR}/bin/_" ]; then
    cp "${DESTDIR}/bin/_" "${DESTDIR}/bin/_.bak"
fi

# Create the script in the bin folder
(
    echo '#!/bin/bash'
    echo '"${@}" 1>/dev/null 2>/dev/null </dev/null & disown'
) > "${DESTDIR}/bin/_"

# Make the script executable
chmod +x "${DESTDIR}/bin/_"

# end-of-file: home_bg.sh
