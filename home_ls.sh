#!/bin/bash

# See LICENSE for license details

#
# Module: ~/bin/ls
#
# Description:
#       Customized version of 'ls' command.
#
# Comments:
#     - Add -F to suffix file names with a type.
#
#     - Add --color option to enable local
#
#     - Add --group-directories-first to sort with directories listed first.
#
#     - Specify full path to ls to avoid recursion and infinite loop.
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
    echo 'exec /bin/ls \'
    echo '    -F \'
    echo '    --color=auto \'
    echo '    --group-directories-first \'
    echo '"${@}"'
) > "${DESTDIR}"/bin/ls

# Make the script executable
chmod +x "${DESTDIR}"/bin/ls

# end-of-file: ~/bin/ls
