#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.lnchrc
#
# Description:
#       Startup script for lnch window manager.
#

# Make a backup of existing script
if [ -f ~/.lnchrc ]; then
    cp ~/.lnchrc ~/.lnchrc.bak
fi

#
#
#
function generate-script ()
{
    # Script header
    echo '#!/bin/snck'

    # Use display :2
    echo 'set DISPLAY localhost:2.0'

    # Force use of custom shell
    echo 'set SHELL /bin/snck'

    # Login
    echo 'source ${HOME}/.snckrc'

    # Set wallpaper
    echo '/usr/bin/dsrt -f ${HOME}/.dsrt.jpg'

    # Change directory to home folder
    echo 'cd ${HOME}'

    # Launch window manager as last command
    echo 'shell /usr/bin/lnch'

}

# Create script in home folder
generate-script > ~/.lnchrc

# Make the script executable
chmod +x ~/.lnchrc

# end-of-file: ~/.lnchrc
