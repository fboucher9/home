#!/bin/bash

# See LICENSE for license details

#
# Module: ~/bin/vip
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
if [ ! -d "${DESTDIR}"/bin ]; then
    mkdir "${DESTDIR}"/bin
fi

# Create the script in the bin folder
(
echo '#!/bin/bash'
echo 'exec ${EDITOR} "${@}" -'
) > "${DESTDIR}"/bin/vip

# Make the script executable
chmod +x "${DESTDIR}"/bin/vip

# end-of-file: ~/bin/vip
