#!/bin/bash

# See LICENSE for license details

#
# Module: home_manpager.sh
#
# Description:
#       Custom pager for man command.
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
if [ -f "${DESTDIR}/bin/manpager" ]; then
    cp "${DESTDIR}/bin/manpager" "${DESTDIR}/bin/manpager.bak"
fi

# Create the script in the bin folder
(
echo '#!/bin/bash'
echo 'col -b -x | exec vim +"setf man" -'
) > "${DESTDIR}/bin/manpager"

# Make the script executable
chmod +x "${DESTDIR}/bin/manpager"

# end-of-file: home_manpager.sh
