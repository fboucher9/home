#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.ctags
#
# Description:
#       Configuration of ctags utility.
#

# Do backup of existing file
if [ -f ~/.ctags ]; then
    cp ~/.ctags ~/.ctags.bak
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
generate-file > ~/.ctags

# end-of-file: ~/.ctags
