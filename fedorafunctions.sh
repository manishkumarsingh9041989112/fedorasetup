#!/bin/bash
set -e
# Checking if the user is root or nah!
function check_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root or sudouser"
		exit 1
	fi
}
function echobanner() {
	echo "+-----------------------------------------------------------------------------------------------------------+"
	echo " $1 "
	echo "+-----------------------------------------------------------------------------------------------------------+"
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
	unzip Hack-v3.003-ttf
	cd ttf
	cp *.ttf $HOME/.local/share/fonts/
	cd ../..
	sudo rm -rf Hack-v3.003-ttf.zip ttf/
	fc-cache -v

}

function INSTALL_STARSHIP() {

	sudo dnf makecache --refresh
	sudo dnf -y install starship
	echo "eval \"\$(starship init bash)\"" | sudo tee -a "/$HOME/.bashrc" >/dev/null
	starship preset pastel-powerline >~/.config/starship.toml

}
function INSTALL_PFETCH() {

	wget https://github.com/dylanaraps/pfetch/archive/master.zip
	unzip master.zip
	sudo install pfetch-master/pfetch /usr/local/bin/
	ls -l /usr/local/bin/pfetch

}
function SET_ALIASES() {

	mkdir -p "/$HOME/.bashrc.d"
	cp ./aliases.sh "/$HOME/.bashrc.d"

}
function INSTALL_SYNTHSHELL() {

	git clone --recursive https://github.com/andresgongora/synth-shell.git
	chmod +x synth-shell/setup.sh
	cd synth-shell
	printf "%s\n" i u Y Y Y Y | ./setup.sh
	rm "/home/$USER/.config/synth-shell/synth-shell-greeter.sh"
}
function SETUP_GIT_REPOS() {

	cd "/$HOME/Documents"
	mkdir -p Gitoyen && cd Gitoyen
	git clone https://github.com/manishkumarsingh9041989112/fedorasetup.git
	git clone https://github.com/manishkumarsingh9041989112/Ubuntusetup.git
	cd $HOME
}
#----------------------Flatpaks installed are below-------------------------------------------

function INSTALL_TELEGRAM_FLATPAK() {
	echobanner "Installing Telegram flatpak"
	flatpak install flathub org.telegram.desktop -y
	echobanner "Telegram flatpak installed"
}
function INSTALL_SIGNAL_FLATPAK() {
	echobanner "Installing Signal flatpak"
	flatpak install flathub org.signal.Signal -y
	echobanner "Signal flatpak installed"
}
function INSTALL_TORBROWSER_FLATPAK() {
	echobanner "Installing Tor-Browser flatpak"
	flatpak install flathub com.github.micahflee.torbrowser-launcher -y
	echobanner "Tor-Browser flatpak installed"
}
function INSTALL_CELLULOID_FLATPAK() {
	echobanner "Installing Celluloid flatpak"
	flatpak install flathub io.github.celluloid_player.Celluloid -y
	echobanner "Celluloid flatpak installed"
}
function INSTALL_BITWARDEN_FLATPAK() {
	echobanner "Installing bitwarden flatpak"
	flatpak install flathub com.bitwarden.desktop -y
	echobanner "bitwarden flatpak installed"
}
function INSTALL_KEEPASSXC_FLATPAK() {
	echobanner "Installing KeepassXC flatpak"
	flatpak install flathub org.keepassxc.KeePassXC -y
	echobanner "KeepassXC flatpak installed"
}
function INSTALL_FOLIATE_FLATPAK() {
	echobanner "Installing Foliate flatpak"
	flatpak install flathub com.github.johnfactotum.Foliate -y
	echobanner "Foliate flatpak installed"
}
function INSTALL_OKULAR_FLATPAK() {
	echobanner "Installing Okular flatpak"
	flatpak install flathub org.kde.okular -y
	echobanner "Okular flatpak installed"
}
function INSTALL_BOOKWORM_FLATPAK() {
	echobanner "Installing Bookworm flatpak"
	flatpak install flathub com.github.babluboy.bookworm -y
	echobanner "Bookworm flatpak installed"
}
function INSTALL_CHROMIUM_FLATPAK() {
	echobanner "Installing Chromium flatpak"
	flatpak install flathub org.chromium.Chromium -y
	echobanner "Chromium flatpak installed"
}
function INSTALL_KLAVARO_FLATPAK() {
	echobanner "Installing Klavaro flatpak"
	flatpak install flathub net.sourceforge.Klavaro -y
	echobanner "Klavaro flatpak installed"
}
function INSTALL_LIBREWOLF_FLATPAK() {
	echobanner "Installing Librewolf flatpak"
	flatpak install flathub io.gitlab.librewolf-community -y
	echobanner "Librewolf flatpak installed"
}
function INSTALL_VIDEO_DOWNLOADER_FLATPAK() {
	echobanner "Installing Video Downloader flatpak"
	flatpak install flathub com.github.unrud.VideoDownloader -y
	echobanner "Video Downloader flatpak installed"
}
function INSTALL_CLAPPER_FLATPAK() {
	echobanner "Installing Clapper flatpak"
	flatpak install flathub com.github.rafostar.Clapper -y
	echobanner "Clapper flatpak installed"
}
function INSTALL_VSCODIUM_FLATPAK() {
	echobanner "Installing VSCodium flatpak"
	flatpak install flathub com.vscodium.codium -y
	echobanner "VSCodium flatpak installed"
}
function INSTALL_OTPCLIENT_FLATPAK() {
	echobanner "Installing OTPClient flatpak"
	flatpak install flathub com.github.paolostivanin.OTPClient -y
	echobanner "OTPClient flatpak installed"
}

function INSTALL_JOPLIN_FLATPAK() {
	echobanner "Installing JOPLIN DESKTOP flatpak"
	flatpak install flathub net.cozic.joplin_desktop -y
	echobanner "JOPLIN DESKTOP flatpak installed"
}

function INSTALL_SHORTWAVE_FLATPAK() {
	echobanner "Installing Shortwave flatpak"
	flatpak install flathub de.haeckerfelix.Shortwave -y
	echobanner "Shortwave flatpak installed"
}
function INSTALL_BRAVEBROWSER_FLATPAK() {
	echobanner "Installing Brave flatpak"
	flatpak install flathub com.brave.Browser -y
	echobanner "Brave flatpak installed"
}

function INSTALL_GOOGLECHROME_FLATPAK() {
	echobanner "Installing Google Chrome flatpak"
	flatpak install flathub com.google.Chrome -y
	echobanner "Google Chrome flatpak installed"
}
function INSTALL_ONLYOFFICE_FLATPAK() {

	echobanner "Installing Onlyoffice DE flatpak"
	flatpak install flathub org.onlyoffice.desktopeditors -y
	echobanner "Onlyoffice DE flatpak installed"
}

#---------------other software-------------------------------#

function INSTALL_NEOVIM() {

	echobanner "Neovim download and full install"
	sudo dnf install neovim -y
	echobanner "Neovim install completed"
}
function INSTALL_VARIETY() {

	echobanner "Variety download and full install"
	sudo dnf install variety -y
	echobanner "Variety install completed"
}
function INSTALL_REDSHIFT() {

	echobanner "Redshift download and full install"
	sudo dnf install redshift-gtk -y
	echobanner "Redshift install completed"
}
function INSTALL_QBITTORRENT() {

	echobanner "Qbittorrent download and full install"
	sudo dnf install qbittorrent -y
	echobanner "Qbittorrent install completed"
}
function INSTALL_MPV() {

	echobanner "MPV download and full install"
	sudo dnf install mpv -y
	echobanner "MPV install completed"
}
function INSTALL_VLC() {

	echobanner "VLC download and full install"
	sudo dnf install vlc -y
	echobanner "VLC install completed"
}
function INSTALL_TMUX() {

	echobanner "Tmux download and full install"
	sudo dnf install tmux -y
	echobanner "Tmux install completed"
}
function INSTALL_CALIBRE() {

	echobanner "Calibre Ebook manager installer"
	sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
	echobanner "Calibre Ebook manager installer completed"
}
function INSTALL_BLEACHBIT {
	echo "Bleachbit download and full install"
	sudo dnf install bleachbit -y
	echo "Bleachbit completed"
}
