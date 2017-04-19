#!/bin/bash

# See LICENSE for license details

#
# Module: home_vip.sh
#
# Description:
#       Open favorite editor using stdin as input file.
#
# Comments:
#     - Parameters are passed to vim as extra options.
#
# Example:
#       git log -2 | vip
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
if [ -f "${DESTDIR}/bin/vip" ]; then
    cp "${DESTDIR}/bin/vip" "${DESTDIR}/bin/vip.bak"
fi

# Create the script in the bin folder
(
echo '#!/bin/bash'
echo 'exec ${EDITOR} "${@}" -'
) > "${DESTDIR}/bin/vip"

# Make the script executable
chmod +x "${DESTDIR}/bin/vip"

# end-of-file: home_vip.sh
