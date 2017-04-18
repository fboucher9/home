# See LICENSE for license details

#
# Module: home_project.mak
#
# Description:
#       Compile and install all home folder features.
#

HOME_FEATURES := \
    home_bg \
    home_ctags \
    home_dsrt \
    home_elinks \
    home_grep \
    home_gvim \
    home_inputrc \
    home_lnch \
    home_ls \
    home_manpager \
    home_snckrc \
    home_v \
    home_vip \
    home_xdefaults

.PHONY: all
all: $(HOME_FEATURES)

.PHONY: home_bg
home_bg: $(HOME_DST)/bin/_

$(HOME_DST)/bin/_: $(HOME_SRC)/home_bg.sh
	env DESTDIR=$(HOME_DST) bash home_bg.sh

.PHONY: home_ctags
home_ctags: $(HOME_DST)/.ctags

$(HOME_DST)/.ctags: $(HOME_SRC)/home_ctags.sh
	env DESTDIR=$(HOME_DST) bash home_ctags.sh

.PHONY: home_dsrt
home_dsrt: $(HOME_DST)/.dsrtrc

$(HOME_DST)/.dsrtrc: $(HOME_SRC)/home_dsrt.sh
	env DESTDIR=$(HOME_DST) bash home_dsrt.sh

.PHONY: home_elinks
home_elinks: $(HOME_DST)/.elinks/elinks.conf

$(HOME_DST)/.elinks/elinks.conf: $(HOME_SRC)/home_elinks.sh
	env DESTDIR=$(HOME_DST) bash home_elinks.sh

.PHONY: home_grep
home_grep: $(HOME_DST)/bin/g

$(HOME_DST)/bin/g: $(HOME_SRC)/home_grep.sh
	env DESTDIR=$(HOME_DST) bash home_grep.sh

.PHONY: home_gvim
home_gvim: $(HOME_DST)/bin/gvim

$(HOME_DST)/bin/gvim: $(HOME_SRC)/home_gvim.sh
	env DESTDIR=$(HOME_DST) bash home_gvim.sh

.PHONY: home_inputrc
home_inputrc: $(HOME_DST)/.inputrc

$(HOME_DST)/.inputrc: $(HOME_SRC)/home_inputrc.sh
	env DESTDIR=$(HOME_DST) bash home_inputrc.sh

.PHONY: home_lnch
home_lnch: $(HOME_DST)/.lnchrc

$(HOME_DST)/.lnchrc: $(HOME_SRC)/home_lnch.sh
	env DESTDIR=$(HOME_DST) bash home_lnch.sh

.PHONY: home_ls
home_ls: $(HOME_DST)/bin/ls

$(HOME_DST)/bin/ls: $(HOME_SRC)/home_ls.sh
	env DESTDIR=$(HOME_DST) bash home_ls.sh

.PHONY: home_manpager
home_manpager: $(HOME_DST)/bin/manpager

$(HOME_DST)/bin/manpager: $(HOME_SRC)/home_manpager.sh
	env DESTDIR=$(HOME_DST) bash home_manpager.sh

.PHONY: home_snckrc
home_snckrc: $(HOME_DST)/.snckrc

$(HOME_DST)/.snckrc: $(HOME_SRC)/home_snckrc.sh
	env DESTDIR=$(HOME_DST) bash home_snckrc.sh

.PHONY: home_v
home_v: $(HOME_DST)/bin/v

$(HOME_DST)/bin/v: $(HOME_SRC)/home_v.sh
	env DESTDIR=$(HOME_DST) bash home_v.sh

.PHONY: home_vip
home_vip: $(HOME_DST)/bin/vip

$(HOME_DST)/bin/vip: $(HOME_SRC)/home_vip.sh
	env DESTDIR=$(HOME_DST) bash home_vip.sh

.PHONY: home_xdefaults
home_xdefaults: $(HOME_DST)/.Xdefaults

$(HOME_DST)/.Xdefaults: $(HOME_SRC)/home_xdefaults.sh
	env DESTDIR=$(HOME_DST) bash home_xdefaults.sh

# end-of-file: home_project.mak
