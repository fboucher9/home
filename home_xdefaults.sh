#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.Xdefaults
#
# Description:
#       Configuration of X11 utilities such as xterm and xclock
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Backup existing file
if [ -f "${DESTDIR}"/.Xdefaults ]; then
    cp "${DESTDIR}"/.Xdefaults "${DESTDIR}"/.Xdefaults.bak
fi

#
# Function: generate-file
#
# Description:
#       Generate contents of file.
#
function generate-file ()
{
    # special
    echo '*.foreground: #ffffff'
    echo '*.background: #000000'
    echo '*.cursorColor: #ffffff'

    # black
    echo '*.color0: #000000'
    echo '*.color8: #5a5a5a'

    # red
    echo '*.color1: #7e0202'
    echo '*.color9: #f55b58'

    # green
    echo '*.color2: #108100'
    echo '*.color10: #58ef41'

    # yellow
    echo '*.color3: #a78508'
    echo '*.color11: #f0c037'

    # blue
    echo '*.color4: #1125a6'
    echo '*.color12: #6b7ff0'

    # magenta
    echo '*.color5: #9f0ba4'
    echo '*.color13: #fe69ff'

    # cyan
    echo '*.color6: #069f9f'
    echo '*.color14: #62f1f1'

    # white
    echo '*.color7: #afafaf'
    echo '*.color15: #ffffff'

    # xterm options
    echo 'xterm*scrollbar: off'
    echo 'xterm*toolBar: off'
    echo 'xterm*font: ufixed'
    echo 'xterm*boldFont: ufixed'
    echo 'XTerm*allowBoldFonts: false'
    echo 'XTerm*colorBDMode: true'
    echo 'XTerm*boldMode: false'
    echo 'xterm*cursorColor:  darkGreen'
    echo 'xterm*scrollTtyOutput: true'
    echo 'xterm*metaSendsEscape: true'
    echo 'xterm*saveLines: 200'

    # xclock colors
    echo 'xclock*foreground: lightgray'
    echo 'xclock*background: black'
    echo 'xclock*majorColor: rgba:f0/f0/19/7b'
    echo 'xclock*minorColor: rgba:a0/c0/f0/c0'
    echo 'XClock*hourColor: rgba:c9/66/11/72'
    echo 'XClock*minuteColor: rgba:00/82/9f/72'
    echo 'XClock*secondColor: rgba:50/93/30/6f'
}

# Create the file in the home folder
echo "Install ${DESTDIR}/.Xdefaults"
generate-file > "${DESTDIR}"/.Xdefaults

# end-of-file: ~/.Xdefaults
