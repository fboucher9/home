# See LICENSE for license details

#
# Module: home_project.mak
#
# Description:
#       Compile and install all home folder features.
#

HOME_FEATURES := \
    home_bashrc \
    home_bg \
    home_bs \
    home_xc \
    home_ctags \
    home_dsrt \
    home_elinks \
    home_grep \
    home_gvim \
    home_inputrc \
    home_lnch \
    home_ls \
    home_manpager \
    home_profile \
    home_snckrc \
    home_v \
    home_vimrc \
    home_vip \
    home_xdefaults

HOME_INSTALL = env DESTDIR=$(HOME_DST) bash $<

.PHONY: all
all: $(HOME_FEATURES)

.PHONY: home_bashrc
home_bashrc: $(HOME_DST)/.bashrc

$(HOME_DST)/.bashrc: $(HOME_SRC)/home_bashrc.sh
	$(HOME_INSTALL)

.PHONY: home_bg
home_bg: $(HOME_DST)/bin/_

$(HOME_DST)/bin/_: $(HOME_SRC)/home_bg.sh
	$(HOME_INSTALL)

.PHONY: home_bs
home_bs: $(HOME_DST)/bin/bs

$(HOME_DST)/bin/bs: $(HOME_SRC)/home_bs.c
	$(CC) -o $(HOME_DST)/bin/bs $(HOME_SRC)/home_bs.c

.PHONY: home_xc
home_xc: $(HOME_DST)/bin/xc

$(HOME_DST)/bin/xc: $(HOME_SRC)/home_xc.c
	$(CC) -o $(HOME_DST)/bin/xc $(HOME_SRC)/home_xc.c

.PHONY: home_ctags
home_ctags: $(HOME_DST)/.ctags

$(HOME_DST)/.ctags: $(HOME_SRC)/home_ctags.sh
	$(HOME_INSTALL)

.PHONY: home_dsrt
home_dsrt: $(HOME_DST)/.dsrtrc

$(HOME_DST)/.dsrtrc: $(HOME_SRC)/home_dsrt.sh
	$(HOME_INSTALL)

.PHONY: home_elinks
home_elinks: $(HOME_DST)/.elinks/elinks.conf

$(HOME_DST)/.elinks/elinks.conf: $(HOME_SRC)/home_elinks.sh
	$(HOME_INSTALL)

.PHONY: home_grep
home_grep: $(HOME_DST)/bin/g

$(HOME_DST)/bin/g: $(HOME_SRC)/home_grep.sh
	$(HOME_INSTALL)

.PHONY: home_gvim
home_gvim: $(HOME_DST)/bin/gvim

$(HOME_DST)/bin/gvim: $(HOME_SRC)/home_gvim.sh
	$(HOME_INSTALL)

.PHONY: home_inputrc
home_inputrc: $(HOME_DST)/.inputrc

$(HOME_DST)/.inputrc: $(HOME_SRC)/home_inputrc.sh
	$(HOME_INSTALL)

.PHONY: home_lnch
home_lnch: $(HOME_DST)/.lnchrc

$(HOME_DST)/.lnchrc: $(HOME_SRC)/home_lnch.sh
	$(HOME_INSTALL)

.PHONY: home_ls
home_ls: $(HOME_DST)/bin/ls

$(HOME_DST)/bin/ls: $(HOME_SRC)/home_ls.sh
	$(HOME_INSTALL)

.PHONY: home_manpager
home_manpager: $(HOME_DST)/bin/manpager

$(HOME_DST)/bin/manpager: $(HOME_SRC)/home_manpager.sh
	$(HOME_INSTALL)

.PHONY: home_profile
home_profile: $(HOME_DST)/bin/profile

$(HOME_DST)/bin/profile: $(HOME_SRC)/home_profile.sh
	$(HOME_INSTALL)

.PHONY: home_snckrc
home_snckrc: $(HOME_DST)/.snckrc

$(HOME_DST)/.snckrc: $(HOME_SRC)/home_snckrc.sh
	$(HOME_INSTALL)

.PHONY: home_v
home_v: $(HOME_DST)/bin/v

$(HOME_DST)/bin/v: $(HOME_SRC)/home_v.sh
	$(HOME_INSTALL)

.PHONY: home_vimrc
home_vimrc: $(HOME_DST)/.vimrc

$(HOME_DST)/.vimrc: $(HOME_SRC)/home_vimrc.sh
	$(HOME_INSTALL)

.PHONY: home_vip
home_vip: $(HOME_DST)/bin/vip

$(HOME_DST)/bin/vip: $(HOME_SRC)/home_vip.sh
	$(HOME_INSTALL)

.PHONY: home_xdefaults
home_xdefaults: $(HOME_DST)/.Xdefaults

$(HOME_DST)/.Xdefaults: $(HOME_SRC)/home_xdefaults.sh
	$(HOME_INSTALL)

# end-of-file: home_project.mak
