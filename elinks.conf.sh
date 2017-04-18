#!/bin/bash

# See LICENSE for license details

#
# Module: ~/.elinks/elinks.conf
#
# Description:
#       Configuration of elinks web browser.
#

(
    echo 'set config.saving_style_w = 1'
    echo 'set document.browse.images.show_as_links = 0'
    echo 'set document.browse.links.numbering = 0'
    echo 'set document.colors.background = "black"'
    echo 'set document.colors.text = "lightgrey"'
    echo 'set document.colors.use_document_colors = 0'
    echo "set document.download.directory = \"${HOME}\""
    echo 'set document.history.global.enable = 0'
    echo 'set terminal.xterm-256color.colors = 1'
    echo 'set terminal.xterm.colors = 1'
    echo 'set ui.language = "System"'
    echo 'set ui.leds.enable = 0'
    echo 'set ui.sessions.homepage = "www.google.ca"'
    echo 'set ui.show_status_bar = 0'
    echo 'set ui.show_title_bar = 0'
    echo 'set ui.tabs.show_bar = 1'
) > ~/.elinks/elinks.conf

# end-of-file: ~/.elinks/elinks.conf
