#!/bin/bash

# See LICENSE for license details

#
# Module: ~/bin/v
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
if [ ! -d "${DESTDIR}"/bin ]; then
    mkdir "${DESTDIR}"/bin
fi

# Create the script in the bin folder
(
echo '#!/bin/bash'
echo 'exec ${EDITOR} "${@}"'
) > "${DESTDIR}"/bin/v

# Make the script executable
chmod +x "${DESTDIR}"/bin/v

# end-of-file: ~/bin/v
