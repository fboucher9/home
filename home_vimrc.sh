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
if [ ! -d "${DESTDIR}/.vim/colors" ]; then
    mkdir -p "${DESTDIR}/.vim/colors"
fi

# Backup of existing file
if [ -f "${DESTDIR}/.vim/_vimrc" ]; then
    cp "${DESTDIR}/.vim/_vimrc" "${DESTDIR}/.vim/_vimrc.bak"
fi
if [ -f "${DESTDIR}/.vim/colors/feed.vim" ]; then
    cp "${DESTDIR}/.vim/colors/feed.vim" "${DESTDIR}/.vim/colors/feed.vim.bak"
fi

# Copy file(s)
cp vim/_vimrc "${DESTDIR}/.vim/_vimrc"
cp vim/colors/feed.vim "${DESTDIR}/.vim/colors/feed.vim"

# Create symbolic link
(
    cd "${DESTDIR}"
    ln -s -f .vim/_vimrc .vimrc
)

# end-of-file: home_vimrc.sh
