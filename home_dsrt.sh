#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.dsrtrc
#
# Description:
#       Startup script for dsrt utility.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make a backup of existing file
if [ -f "${DESTDIR}"/.dsrtrc ]; then
    cp "${DESTDIR}"/.dsrtrc "${DESTDIR}"/.dsrtrc.bak
fi

# Generate the script
(
echo '#!/bin/bash'
echo '/usr/bin/dsrt -f ${HOME}/.dsrt.jpg'
) > "${DESTDIR}"/.dsrtrc

# Make script executable
chmod +x "${DESTDIR}"/.dsrtrc

# Remind the user to create a symbolic link
if [ ! -f "${DESTDIR}"/.dsrt.jpg ]; then
    echo "ln -s ... ${DESTDIR}/.dsrt.jpg"
else
    stat -c '%N' "${DESTDIR}"/.dsrt.jpg
fi

# end-of-file: ~/.dsrtrc
