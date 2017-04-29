#!/bin/bash

# See LICENSE for license details

#
# Module: home_vimrc.sh
#
# Description:
#       Install vimrc and other vim configuration files
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure folder has been created
if [ ! -d "${DESTDIR}/.vim" ]; then
    mkdir -p "${DESTDIR}/.vim"
fi

# Backup of existing file
if [ -d "${DESTDIR}/.vim" ]; then
    cp -r "${DESTDIR}/.vim" "/tmp/"
fi

# Copy file(s)
cp -r vim/* "${DESTDIR}/.vim/"

# Create symbolic link
(
    cd "${DESTDIR}"
    ln -s -f .vim/_vimrc .vimrc
)

# end-of-file: home_vimrc.sh
