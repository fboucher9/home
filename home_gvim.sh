#!/bin/bash

# See LICENSE for license details

#
# Module: ~/bin/gvim
#
# Description:
#       Launch a terminal window with vim
#
# Comments:
#       Configure default terminal emulator with:
#           sudo update-alternatives --install \
#               /usr/bin/x-terminal-emulator \
#               x-terminal-emulator \
#               /usr/bin/bfst \
#               100
#
#       Configure default editor with:
#           set EDITOR vim
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
echo 'x-terminal-emulator -e ${EDITOR} "${@}" 1>/dev/null 2>/dev/null </dev/null & disown'
) > "${DESTDIR}"/bin/gvim

# Make the script executable
chmod +x "${DESTDIR}"/bin/g

# end-of-file: ~/bin/gvim
