#!/bin/bash

# See LICENSE for license details

#
# Module: home_bashrc.sh
#
# Description:
#       Install ~/.bashrc
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR="${HOME}"
fi

# Make sure destination folder has been created
if [ ! -d "${DESTDIR}" ]; then
    mkdir -p "${DESTDIR}"
fi

# Backup of existing file
if [ -f "${DESTDIR}/.bashrc" ]; then
    cp "${DESTDIR}/.bashrc" "${DESTDIR}/.bashrc.bak"
fi

#
# Function: generate-file
#
# Description:
#       Generate the contents of .bashrc to stdout
#
function generate-file ()
{
    # Detect interactive shell
    echo 'case $- in'
    echo '*i*) ;;'
    echo '*) return;;'
    echo 'esac'

    # Configure permissions
    echo 'umask 022'

    # Configure history
    echo 'HISTCONTROL=ignoreboth'
    echo 'HISTSIZE=10000'
    echo 'HISTFILESIZE=10000'

    # Append history to file
    echo 'shopt -s histappend'

    # Adjust readline to window size
    echo 'shopt -s checkwinsize'

    # To cd when command is a folder name
    echo 'shopt -s autocd'

    # Correct errors in spelling for cd
    echo 'shopt -s cdspell'

    # Add color to grep
    echo "alias grep=\'grep --color=auto\'"

    # Enable bash completion
    echo '. /usr/share/bash-completion/bash_completion'

    # Select favorite editor
    echo 'export EDITOR=vim'

    # Select pager for man
    echo 'export MANPAGER=manpager'

    # Configure prompt
    echo "export PS1=\'\\u@\\h:\\w\\$ \'"

    # Add home bin folder to path
    echo 'export PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games'

}

# Create the script
generate-file > ${DESTDIR}/.bashrc

# end-of-file: home_bashrc.sh
