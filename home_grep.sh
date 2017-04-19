#!/bin/bash

# See LICENSE for license details

#
# Module: home_grep.sh
#
# Description:
#       Recursive grep and view results using vim quickfix list.
#
# Comments:
#     - Use of bash special input redirection operator.  Output of
#       grep is redirected to a temporary buffer and the same buffer
#       is used as filename of vim quickfix list.
#

# Select destination folder of installation
if [ -z "${DESTDIR}" ]; then
    DESTDIR=${HOME}
fi

# Make sure bin folder has been created
if [ ! -d "${DESTDIR}/bin" ]; then
    mkdir -p "${DESTDIR}/bin"
fi

# Backup of existing file
if [ -f "${DESTDIR}/bin/g" ]; then
    cp "${DESTDIR}/bin/g" "${DESTDIR}/bin/g.bak"
fi

(
echo '#!/bin/bash'
echo 'exec vim -q <( \
    grep \
        -n \
        -r \
        -i \
        --exclude-dir='\''.git'\'' \
        --exclude=tags \
        --exclude='\''*.o'\'' \
        --exclude='\''_obj*'\'' \
        "${@}" \
        . )'
) > "${DESTDIR}/bin/g"

# Make the script executable
chmod +x "${DESTDIR}/bin/g"

# end-of-file: home_grep.sh
