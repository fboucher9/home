#!/bin/bash

# See LICENSE for license details

#
# Module: home_v.sh
#
# Description:
#       Launch favorite editor.
#
# Comments:
#     - This is equivalent of 'alias v=vim'
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
if [ -f "${DESTDIR}/bin/v" ]; then
    cp "${DESTDIR}/bin/v" "${DESTDIR}/bin/v.bak"
fi

# Create the script in the bin folder
(
echo '#!/bin/bash'
echo 'exec ${EDITOR} "${@}"'
) > "${DESTDIR}/bin/v"

# Make the script executable
chmod +x "${DESTDIR}/bin/v"

# end-of-file: home_v.sh
