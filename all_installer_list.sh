#!/bin/bash
set -e
#
#
# Checking if the user is root or nah!
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
}
#Check complete

#--------------Variables------------------------------#
DIST_CODENAME=$(lsb_release --codename | cut -f2)
DISTRO_NAME=$(lsb_release -i | cut -f2)
DATE=(date +%F_%T)
SCRIPT_VERSION=(0)
MACHINE_VIRTUAL_OR_REAL=$(sudo dmidecode -s system-manufacturer)
USERID=devk
PRESENTHOME=/home/"$USERID"

#----------------Constants-----------------------------#
IS_VIRTUALBOX_MACHINE="innotek GmbH"

#----------------Functions----------------------------#
function WAIT_FOR_SECONDS() {
    echo "Now we will wait for $1 seconds before processing"
    date=$(($(date +%s) + $1))
    while [ "$date" -ne $(date +%s) ]; do
        echo -ne "$(date -u --date @$(($date - $(date +%s))) +%H:%M:%S)\r"
        sleep 1
    done
}

function WELCOME_SCREEN() {
    echo "_______________________________________________________"
    echo "                                                       "
    echo "            Selective Installer                        "
    echo "            ~~~~~~~~~~~~~~~~~~~~~                      "
    echo "                                                       "
    echo "This install script will install commonly used tools on"
    echo "Ubuntu (or at least apt-based system).This list below  "
    echo "includes one or more of those:                         "
    echo " 1. Google Chrome                                      "
    echo " 2. Opera                                              "
    echo " 3. Chromium(flatpak)                                  "
    echo " 4. VirtualBox Guest additions                         "
    echo " 5. VirtualBox                                         "
    echo " 6. Git                                                "
    echo " 7. Variety                                            "
    echo " 8. KeepassXC                                          "
    echo " 9. Brave Browser                                      "
    echo "10. Vivaldi                                            "
    echo "11. Microsoft Edge                                     "
    echo "12. Signal(flatpak)                                    "
    echo "13. Telegram(flatpak)                                  "
    echo "14. Calibre(Install/Update)                            "
    echo "15. VSCode(flatpak)                                    "
    echo "16. Gnome-tweaks                                       "
    echo "17. VLC                                                "
    echo "18. Celluloid(flatpak)                                 "
    echo "19. Powerline fonts                                    "
    echo "20. Microsoft fonts                                    "
    echo "21. UCareSystem-core                                   "
    echo "22. Redshift                                           "
    echo "23. Neovim                                             "
    echo "24. 4K Video Downloader                                "
    echo "25. Bitwarden(flatpak)                                 "
    echo "26. Tor-Browser(flatpak)                               "
    echo "27. Foliate(flatpak)                                   "
    echo "_______________________________________________________"
    echo
    echo " Selective Installer will start immediately now        "

    # WAIT_FOR_SECONDS 6
}
function echobanner() {
    echo "+-----------------------------------------------------------------------------------------------------------+"
    echo " $1 "
    echo "+-----------------------------------------------------------------------------------------------------------+"
}
function SHUT_UNATTENDED_UPGRADES() {
    sudo apt remove unattended-upgrades -y
    sudo systemctl disable apt-daily-upgrade.timer
    sudo systemctl disable apt-daily.timer
}
function FIRST_UPGRADE() {
    echobanner "The first upgrade taking place here"
    sudo add-apt-repository universe -y
    sudo add-apt-repository multiverse -y
    sudo add-apt-repository restricted -y
    sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    echobanner "The first upgrade is now complete: and now going for software installs"

}
function FIRST_UPDATE() {
    echobanner "The first update taking place here"
    sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    echobanner "The first update is now complete: and now going for software installs"

}
function CLEAN_UPDATE() {
    echobanner "The clean update taking place here"
    sudo rm -rf /var/lib/apt/lists/partial
    sudo apt-get update -o Acquire::CompressionTypes::Order::=gz
    sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    echobanner "The clean update is now complete: and now going for software installs"

}
function INSTALL_BASIC_UTILITIES() {
    echobanner "Basic utilities installation"
    sudo apt install apt-transport-https curl wget gnupg2 gnupg unrar unzip git gconf2 dconf-cli uuid-runtime unace rar p7zip zip cabextract file-roller ubuntu-restricted-extras build-essential dkms linux-headers-$(uname -r) -y
    
}
function INSTALL_DEBGET() {
    echobanner "Deb-get installation"
    curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
    
}
#******************************The section contains individual software entries****************************************
function INSTALL_PAPIRUS_ICON_THEME() {
    echobanner "Installing Papirus icon theme"
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt install -y papirus-icon-theme
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
    echobanner "Installing Papirus icon theme done"
}
function INSTALL_DRACULA_GNOME_TERMINAL() {
    # Gnome-terminal Dracula theme install
    sudo apt-get install dconf-cli -y
    git clone https://github.com/dracula/gnome-terminal
    cd gnome-terminal/
    ./install.sh
    cd ..
}
function INSTALL_DRACULA_GEDIT() {
    wget https://raw.githubusercontent.com/dracula/gedit/master/dracula.xml
    FILE=/home/"$USERID"/.local/share/gedit/styles
    if [ ! -f "$FILE" ]; then
        mkdir "$FILE" && true
    fi
    sudo mv dracula.xml "$FILE"/
}
function INSTALL_DRACULA_GTK_THEME() {
    wget https://github.com/dracula/gtk/archive/master.zip
    unzip master.zip
    sudo mv -f gtk-master /usr/share/themes && true
    gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
    gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
    sudo rm -rf gtk-master.zip
}
function INSTALL_UCARESYSTEMCORE() {

    echobanner "uCareSystem Core download and full install"
    sudo add-apt-repository ppa:utappia/stable -y
    sudo apt update -y
    sudo apt install ucaresystem-core -y
    echobanner "uCareSystem Core install completed"
}
function INSTALL_POWERLINEFONTS() {

    echobanner "Powerline fonts download and full install"
    sudo apt install fonts-powerline -y
    echobanner "Powerline fonts install completed"
}
function INSTALL_MICROSOFT_FONTS() {

    echobanner "Microsoft Truetype fonts install"
    sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y
    echo -e "\e[31;43m***** Microsoft Fonts*****\e[0m"
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
    sudo apt-get install ttf-mscorefonts-installer -y
    sudo fc-cache -f -v
    echobanner "Microsoft Truetype fonts install completed"
}
function INSTALL_PFETCH() {

    echobanner "Pfetch installer "
    wget https://github.com/dylanaraps/pfetch/archive/master.zip
    unzip master.zip
    sudo install pfetch-master/pfetch /usr/local/bin/
    ls -l /usr/local/bin/pfetch
    echobanner "Pfetch installer completed"
}
function INSTALL_LATEST_VIRTUALBOX() {
    echobanner "Latest Virtualbox download and full install"
    if [ -n "$1" ]; then
        sudo apt-get remove virtualbox -y || true
        sudo apt-get autoremove -y
        sudo rm /etc/apt/sources.list.d/virtualbox.list && true
        vboxversion=$(wget -qO - https://download.virtualbox.org/virtualbox/LATEST.TXT)
        vboxmajorversion=$(echo $vboxversion|cut -d. -f1)
        vboxmajorversion+="."
        vboxmajorversion+=$(echo $vboxversion|cut -d. -f2)
        sudo touch /etc/apt/sources.list.d/virtualbox.list
        sudo echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $1 contrib" | sudo tee --append /etc/apt/sources.list.d/virtualbox.list
        wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
        sudo apt-get update -y
        sudo apt-get install virtualbox-6.1 dkms -y
        
        wget "https://download.virtualbox.org/virtualbox/${vboxversion}/Oracle_VM_VirtualBox_Extension_Pack-${vboxversion}.vbox-extpack"
        sudo vboxmanage extpack install --replace --accept-license=33d7284dc4a0ece381196fda3cfe2ed0e1e8e7ed7f27b9a9ebc4ee22e24bd23c Oracle_VM_VirtualBox_Extension_Pack-${vboxversion}.vbox-extpack
    else
        echobanner "No Ubuntu/Debian Codename provided for the Virtualbox install"
    fi    
    echobanner "Latest Virtualbox install completed"
}
function INSTALL_CORRETTO_JDK11() {
    sleep 4
    echobanner "Amazon JDK download and full install"
    sudo apt install java-common -y
    wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add -
    sudo add-apt-repository 'deb https://apt.corretto.aws stable main' -y
    sudo apt-get update -y
    sudo apt-get install -y java-11-amazon-corretto-jdk
    sudo update-alternatives --config java
    sudo update-alternatives --config javac
    echobanner "Amazon JDK install completed"
}
function INSTALL_NALA() {
    sleep 4
    echobanner "Nala install"
    echo "deb [arch=amd64] http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
    sudo apt update 
    #sudo apt install nala-legacy -y
    sudo apt install nala -y
    echobanner "Nala install completed"
}
function INSTALL_NEOVIM() {

    echobanner "Neovim download and full install"
    sudo apt install neovim -y
    echobanner "Neovim install completed"
}
function INSTALL_VARIETY() {

    echobanner "Variety download and full install"
    sudo apt install variety -y
    echobanner "Variety install completed"
}
function INSTALL_REDSHIFT() {

    echobanner "Redshift download and full install"
    sudo apt install redshift-gtk -y
    echobanner "Redshift install completed"
}
function INSTALL_QBITTORRENT() {

    echobanner "Qbittorrent download and full install"
    sudo apt install qbittorrent -y
    echobanner "Qbittorrent install completed"
}
function INSTALL_DELUGE() {

    echobanner "Deluge download and full install"
    sudo add-apt-repository ppa:deluge-team/stable -y
    sudo apt update -y
    sudo apt install deluge -y
    echobanner "Deluge install completed"
}
function INSTALL_MPV() {

    echobanner "MPV download and full install"
    sudo apt install mpv -y
    echobanner "MPV install completed"
}
function INSTALL_VLC() {

    echobanner "VLC download and full install"
    sudo apt install vlc -y
    echobanner "VLC install completed"
}
function INSTALL_TMUX() {

    echobanner "Tmux download and full install"
    sudo apt install tmux -y
    echobanner "Tmux install completed"
}
function INSTALL_VSCODIUM() {

    echobanner "VSCODIUM(FOSS version of VS Code) download and full install"
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update -y
    sudo apt install codium -y
    echobanner "VSCODIUM(FOSS version of VS Code) install completed"
}
function INSTALL_ULAUNCHER() {

    echobanner "Ulauncher download and full install"
    sudo add-apt-repository ppa:agornostal/ulauncher -y
    sudo apt update -y
    sudo apt install ulauncher -y
    echobanner "Ulauncher install completed"
}
function INSTALL_BPYTOP() {

    echobanner "Bpytop download and full install"
    echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
    wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
    sudo apt update -y && sudo apt install bpytop -y
    echobanner "Bpytop install completed"
}
function INSTALL_4KVIDEODOWNLOADER() {

    echobanner "4k Video Downloader installer might need version"
    wget https://dl.4kdownload.com/app/4kvideodownloader_4.17.1-1_amd64.deb
    if [[ $? -eq 0 ]]; then
        chmod +x 4k*amd64.deb
        sudo apt install ./4k*amd64.deb -y
        sudo rm -f 4k*amd64.deb
    else
        echo "4K Video Downloader install failed"
    fi
    echobanner "4k Video Downloader installer completed"
}
function INSTALL_GOOGLECHROME() {
    sleep 4
    echobanner "Google Chrome download and full install"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install ./google-chrome-stable_current_amd64.deb -y
    echobanner "Google Chrome completed"
}
function INSTALL_WATERFOX() {
    sleep 4
    echobanner "Waterfox download and full install"
    UBUNTU_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d'"' -f 2)
    echo "deb http://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/xUbuntu_$UBUNTU_VERSION/ /" | sudo tee /etc/apt/sources.list.d/home:hawkeye116477:waterfox.list
    urlreleasekey=https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/xUbuntu_$UBUNTU_VERSION/Release.key
    curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/xUbuntu_21.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_hawkeye116477_waterfox.gpg >/dev/null
    sudo apt update -y
    sudo apt install waterfox-g3-kpe -y
    echobanner "Waterfox completed"
}
function INSTALL_BRAVEBROWSER() {

    echobanner "Brave-browser install"
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update -y
    sudo apt install brave-browser -y
    echobanner "Brave-browser install done"
}
function INSTALL_VIVALDIBROWSER() {

    echobanner "Vivaldi-browser install"
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main' -y
    sudo apt update -y
    sudo apt install vivaldi-stable -y
    echobanner "Vivaldi-browser install done"
}
function INSTALL_OPERABROWSER() {

    echobanner "Opera browser install"
    wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
    echo "deb https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list
    DEBIAN_FRONTEND='noninteractive' sudo apt-get update -y && sudo apt-get install opera-stable -y
    echobanner "Opera browser install completed"
}
function INSTALL_EDGEBROWSER() {

    echobanner "microsoft-edge-dev-browser install"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
    sudo rm microsoft.gpg
    sudo apt update -y
    sudo apt install microsoft-edge-dev -y
    echobanner "microsoft-edge-dev-browser install completed"
}
function INSTALL_NORDVPN() {

    echobanner "NordVPN download and base install"
    wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
    sudo apt install ./nordvpn-release_1.0.0_all.deb -y
    sudo apt update -y
    sudo apt install nordvpn -y
    echobanner "NordVPN download and base install done"
}
function INSTALL_MULLVADVPN() {

    echobanner "Mullvad download and base install"
    wget --content-disposition https://mullvad.net/download/app/deb/latest
    MULLVADDEB=$(ls Mullvad*.deb)
    sudo dpkg -i $MULLVADDEB
    sudo rm -f $MULLVADDEB
    echobanner "Mullvad download and base install done"
}
function INSTALL_VSCODE() {

    echobanner "VSCode install"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update -y
    sudo apt install code -y
    echobanner "VSCode install completed"
}
function INSTALL_SUBLIMETEXT() {

    echobanner "Adding Sublime text"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update -y
    sudo apt install sublime-text -y
    echobanner "Adding Sublime text completed"
}
function INSTALL_CALIBRE() {

    echobanner "Calibre Ebook manager installer"
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
    echobanner "Calibre Ebook manager installer completed"
}
function INSTALL_AUDIORECORDER() {

    echobanner "Audio Recorder installer "
    sudo apt-add-repository ppa:audio-recorder/ppa -y
    sudo apt update -y
    sudo apt-get install audio-recorder -y
    echobanner "Audio Recorder installer completed"
}
function INSTALL_FIRETOOLS() {

    echobanner "Firetools installer "
    sudo apt-get install firetools -y
    echobanner "Firetools installer completed"
}
function INSTALL_ADB_AND_FASTBOOT() {

    echobanner "ADB and Fastboot installer "
    sudo apt-get install android-tools-adb android-tools-fastboot -y
    echobanner "ADB and Fastboot installer completed"
}
function ENABLE_FLATPAKS() {
    echobanner "Enabling flatpak support wherever possible "
    sudo apt update -y && sudo apt install flatpak -y
    #sudo apt install gnome-software-plugin-flatpak -y
    sudo apt update -y
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}
function INSTALL_OPENSNITCH {
    sleep 4
    echo "Opensnitch download and full install"
    versionnum=$(curl -s https://github.com/evilsocket/opensnitch/releases/ | grep tag_name | sort -r | awk 'FNR == 1' | grep -P -o '(?<=tag_name=v).*?(?=\&)')
    if [[ $versionnum == *-* ]]; then
        target1=$(echo $versionnum | cut -d '-' -f1)
        target2=$(echo $versionnum | cut -d '-' -f2 | sed 's/\.//')
        target="$target1"."$target2"
    else
        target="$target1"
    fi
    echo $versionnum
    echo $target
    wget https://github.com/evilsocket/opensnitch/releases/download/v$versionnum/opensnitch_$target-1_amd64.deb
    wget https://github.com/evilsocket/opensnitch/releases/download/v$versionnum/python3-opensnitch-ui_$target-1_all.deb
    sudo chmod +x *.deb
    sudo dpkg -i opensnitch*.deb python3-opensnitch-ui*.deb
    sudo apt -f install -y
    sudo rm -rf *github.com
    sudo rm opensnitch*.deb python3-opensnitch-ui*.deb
    sudo apt --fix-broken install
    echo "Opensnitch completed"
}
function INSTALL_BLEACHBIT {
    sleep 4
    echo "Bleachbit download and full install"
    wget -o ./urls.txt --spider -r --no-verbose --no-parent https://www.bleachbit.org/download/linux
    bleachbiturl=$(cat urls.txt | awk '{print $3}' | sed -e 's/URL://' | grep '.deb$' | grep 'ubuntu' | sort -nr | awk 'FNR == 1')
    firefox --browser "$bleachbiturl"
    sleep 30
    rm urls.txt
    rm -rf www.bleachbit.org
    cd /home/devk/Downloads
    sudo apt install -y ./bleachbit*.deb
    rm bleachbit*.deb
    echo "Bleachbit completed"
}
function INSTALL_VERACRYPT() {
    echobanner "Installing VeraCrypt"
    sudo add-apt-repository -y ppa:unit193/encryption
    sudo apt-get update -y
    sudo apt-get install veracrypt -y
    echobanner "Installing VeraCrypt done"
}
function INSTALL_KEEPASSXC_PPA() {
    echobanner "Installing KeepassXC from PPA"
    sudo add-apt-repository ppa:phoerious/keepassxc -y
    sudo apt update -y
    sudo apt install keepassxc -y
    echobanner "KeepassXC PPA installed"
}

function INSTALL_CELLULOID_PPA() {
    echobanner "Installing Celluloid from PPA"
    sudo add-apt-repository ppa:xuzhen666/gnome-mpv -y
    sudo apt-get update -y
    sudo apt install celluloid -y
    echobanner "Celluloid PPA installed"
}
function INSTALL_SIGNAL_PPA() {
    echobanner "Installing Signal app from PPA"
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
    sudo tee -a /etc/apt/sources.list.d/signal-xenial.list

    sudo apt update -y && sudo apt install signal-desktop -y
    echobanner "Signal PPA installed"
}
function INSTALL_TELEGRAM_APT() {
    echobanner "Installing Telegram desktop"
    sudo apt install telegram-desktop -y
    echobanner "Telegram installed"
}
#----------------------Flatpaks installed are below-------------------------------------------

function INSTALL_TELEGRAM_FLATPAK() {
    echobanner "Installing Telegram flatpak"
    flatpak --system install flathub org.telegram.desktop -y
    echobanner "Telegram flatpak installed"
}
function INSTALL_SIGNAL_FLATPAK() {
    echobanner "Installing Signal flatpak"
    flatpak --system install flathub org.signal.Signal -y
    echobanner "Signal flatpak installed"
}
function INSTALL_TORBROWSER_FLATPAK() {
    echobanner "Installing Tor-Browser flatpak"
    flatpak --system install flathub com.github.micahflee.torbrowser-launcher -y
    echobanner "Tor-Browser flatpak installed"
}
function INSTALL_CELLULOID_FLATPAK() {
    echobanner "Installing Celluloid flatpak"
    flatpak --system install flathub io.github.celluloid_player.Celluloid -y
    echobanner "Celluloid flatpak installed"
}
function INSTALL_BITWARDEN_FLATPAK() {
    echobanner "Installing bitwarden flatpak"
    flatpak --system install flathub com.bitwarden.desktop -y
    echobanner "bitwarden flatpak installed"
}
function INSTALL_KEEPASSXC_FLATPAK() {
    echobanner "Installing KeepassXC flatpak"
    flatpak --system install flathub org.keepassxc.KeePassXC -y
    echobanner "KeepassXC flatpak installed"
}
function INSTALL_FOLIATE_FLATPAK() {
    echobanner "Installing Foliate flatpak"
    flatpak --system install flathub com.github.johnfactotum.Foliate -y
    echobanner "Foliate flatpak installed"
}
function INSTALL_OKULAR_FLATPAK() {
    echobanner "Installing Okular flatpak"
    flatpak --system install flathub org.kde.okular -y
    echobanner "Okular flatpak installed"
}
function INSTALL_BOOKWORM_FLATPAK() {
    echobanner "Installing Bookworm flatpak"
    flatpak --system install flathub com.github.babluboy.bookworm -y
    echobanner "Bookworm flatpak installed"
}
function INSTALL_CHROMIUM_FLATPAK() {
    echobanner "Installing Chromium flatpak"
    flatpak --system install flathub org.chromium.Chromium -y
    echobanner "Chromium flatpak installed"
}
function INSTALL_KLAVARO_FLATPAK() {
    echobanner "Installing Klavaro flatpak"
    flatpak --system install flathub net.sourceforge.Klavaro -y
    echobanner "Klavaro flatpak installed"
}
function INSTALL_LIBREWOLF_FLATPAK() {
    echobanner "Installing Librewolf flatpak"
    flatpak --system install flathub io.gitlab.librewolf-community -y
    echobanner "Librewolf flatpak installed"
}
function INSTALL_VIDEO_DOWNLOADER_FLATPAK() {
    echobanner "Installing Video Downloader flatpak"
    flatpak --system install flathub com.github.unrud.VideoDownloader -y
    echobanner "Video Downloader flatpak installed"
}
function INSTALL_CLAPPER_FLATPAK() {
    echobanner "Installing Clapper flatpak"
    flatpak --system install flathub com.github.rafostar.Clapper -y
    echobanner "Clapper flatpak installed"
}
function INSTALL_VSCODIUM_FLATPAK() {
    echobanner "Installing VSCodium flatpak"
    flatpak --system install flathub com.vscodium.codium -y
    echobanner "VSCodium flatpak installed"
}
function INSTALL_OTPCLIENT_FLATPAK() {
    echobanner "Installing OTPClient flatpak"
    flatpak --system install flathub com.github.paolostivanin.OTPClient -y
    echobanner "OTPClient flatpak installed"
}
#******************************End of section contains individual software entries****************************************

function REBOOT_SYSTEM() {
    echobanner "Rebooting"
    WAIT_FOR_SECONDS 4
    sudo reboot now
    ## End of script
}
function COPY_BASHRC_AND_BASH_ALIASES() {

    echobanner "Copying the .bashrc files and deleting downloaded files"
    sudo cp ".bashrc" /home/"$USERID"/
    sudo cp ".bash_aliases" /home/"$USERID"/
    sudo chown -R "$USERID":"$USERID" /home/"$USERID"

}
function CREATE_FOLDER_SYSTEM() {
    echobanner "Creating a System of Folders"
    sleep 4
    cd /home/"$USERID"
    cd Documents
    mkdir GitRepos Locker LogBoxer CalibreLibraries
    cd GitRepos
    git clone https://github.com/manishkumarsingh9041989112/Ubuntusetup.git
    cd Ubuntusetup
    git config user.email "fun.desk0872@fastmail.com";
    git config user.name "manishkumarsingh9041989112";
    cd /home/"$USERID"
    cd Downloads
    mkdir Books
    cd Books
    mkdir Computers Miscellany Novels
    cd /home/"$USERID"
    cd Videos
    mkdir Computorials Tutorials Movies
    cd /home/"$USERID"
    mkdir SharedVMFolder
    sudo chown -R "$USERID":"$USERID" /home/"$USERID"
    ## End of script
}


