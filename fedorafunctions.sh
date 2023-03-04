#!/bin/bash
set -e
# Checking if the user is root or nah!
function check_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root or sudouser"
		exit 1
	fi
}

function ADD_FASTESTMIRROR() {

	echo "max_parallel_downloads=10" | sudo tee -a '/etc/dnf/dnf.conf'
	echo "deltarpm=true" | sudo tee -a '/etc/dnf/dnf.conf'
	echo "fastestmirror=1" | sudo tee -a '/etc/dnf/dnf.conf'

}

function ENABLE_3RDPARTY_REPOS() {

	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf install redhat-lsb-core fedora-workstation-repositories -y
	#  sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
	#	sudo dnf install -y lame\* --exclude=lame-devel
	#	sudo dnf group upgrade --with-optional Multimedia -y
	sudo dnf install curl cabextract xorg-x11-font-utils fontconfig git shfmt -y
	sudo dnf group update core -y
	sudo dnf upgrade -y

}

function ENABLE_FLATHUB() {

	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

}
function UPDATE_AND_REBOOT() {

	sudo dnf clean all -y
	sudo dnf upgrade --refresh -y
	sudo dnf upgrade -y && sudo flatpak update && sudo shutdown -r 0

}

function UNINSTALL_WILD() {
	sudo dnf remove transmission-gtk hexchat pidgin libreoffice* -y
}
function INSTALL_ST4() {
	sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	sudo dnf install sublime-text -y
}
function INSTALL_CODIUM() {
	sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
	printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
	sudo dnf install codium -y

}

function INSTALL_FONTS() {

	sudo dnf install powerline-fonts -y
	sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
	git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
	cd nerd-fonts/
	git sparse-checkout add patched-fonts/CascadiaCode patched-fonts/FiraCode patched-fonts/FiraMono
	./install.sh CascadiaCode && ./install.sh FiraCode && ./install.sh FiraMono
	cd ..
	sudo rm -rf nerd-fonts/
	wget https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
	unzip Hack*.zip
	cd $(echo $(ls -d Hack*ttf))/ttf
	ls -ltr *.ttf | awk '{print $8}' | xargs cp -t ~/.local/share/fonts/
	cd ../..
	sudo rm -rf Hack*ttf/
	fc-cache -v

}

function INSTALL_STARSHIP() {

	sudo dnf makecache --refresh
	sudo dnf -y install starship
	echo "eval \"\$(starship init bash)\"" | sudo tee -a "/home/$USER/.bashrc" >/dev/null
	starship preset pastel-powerline >~/.config/starship.toml

}
function INSTALL_PFETCH() {

	wget https://github.com/dylanaraps/pfetch/archive/master.zip
	unzip master.zip
	sudo install pfetch-master/pfetch /usr/local/bin/
	ls -l /usr/local/bin/pfetch

}
function SET_ALIASES() {

	mkdir -p "/home/$USER/.bashrc.d"
	cp ./aliases.sh "/home/$USER/.bashrc.d"

}
