#!/bin/bash

# See LICENSE for license details

#
# Module: home_ctags.sh
#
# Description:
#       Configuration of ctags utility.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Do backup of existing file
if [ -f "${DESTDIR}/.ctags" ]; then
    cp "${DESTDIR}/.ctags" "${DESTDIR}/.ctags.bak"
fi

#
# Function: generate-file
#
# Description:
#       Generate contents of .ctags file to stdout.
#
function generate-file ()
{
    # Recurve to subfolders
    echo '-R'

    # Use regular expressions to locate line
    echo '-N'

    # Extra entries for files
    echo '--extra=+fq'

    # Extra options for c++ files
    echo '--c++-kinds=+lpx'

}

# Create the file in the home folder
generate-file > "${DESTDIR}/.ctags"

# end-of-file: home_ctags.sh
