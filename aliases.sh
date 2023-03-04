alias changeowner='sudo chown -R $USER:$USER $HOME'
alias fulldnfupgrade='sudo dnf update -y && sudo dnf upgrade -y && flatpak update -y'
alias dnfclean='sudo dnf clean all'
alias bbitsudo='sudo bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs bleachbit --clean'
alias bbit='bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs bleachbit --clean'
alias shutitdown='sudo shutdown now'
alias rebootit='sudo reboot now'
alias dnfcleanupgrade='sudo dnf clean all && sudo dnf update -y && sudo dnf upgrade -y && flatpak update -y'
alias calibreupgrade='sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin'
alias updateandreboot='sudo dnf update -y && sudo dnf upgrade -y && flatpak update -y && sudo reboot now'

EXPORT_ALL_VM() {
	vmlist=$(vboxmanage list vms | cut -d'"' -f 2);
	IFS=$'\n'$'\r';
	for vm in $vmlist;do vboxmanage export "$vm" -o "$vm".ova;done;
	mv -vf *.ova /media/devk/FileRepository/VirtualMachineImages/UsableImages/
}
IMPORT_ALL_VM() {
	ovafilelist=$(ls -1 *.ova);
	IFS=$'\n'$'\r';
	for vm in $ovafilelist;do vboxmanage import "$vm";done;
}
SNAPSHOT_EVERY_VM() {
	vmlist=$(vboxmanage list vms | cut -d'"' -f 2);
	IFS=$'\n'$'\r';
	for vm in $vmlist;do vboxmanage snapshot "$vm" delete "CleanSnap";done;
	for vm in $vmlist;do vboxmanage snapshot "$vm" take "CleanSnap";done;
}
DELETE_ALL_SNAPSHOTS() {
    uuidregex="^[^\W_]{8}(-[^\W_]{4}){3}-[^\W_]{12}$"
    mapfile -t vmlist < <(vboxmanage list vms | cut -d'"' -f 2);
    for vm in "${vmlist[@]}";
    do   
        mapfile -t vmsnapshotlist < <(VBoxManage snapshot "$vm" list --details);
        for snapsh in "${vmsnapshotlist[@]}";
        do
            snapsh=$(echo $snapsh | awk -F '[()]' '{print $2}')
            snapsh=${snapsh#*UUID: }
            [[ ! -z "$snapsh" ]] && echo "$snapsh"
            [[ $snapsh =~ $uuidregex ]] && vboxmanage snapshot "$vm" delete "$snapsh"
        done;
        
    done;
}

TAKE_A_NEW_SNAPSHOT(){
        DELETE_ALL_SNAPSHOTS;
        mapfile -t vmlist < <(vboxmanage list vms | cut -d'"' -f 2);
        for vm in "${vmlist[@]}";
        do   
        snapshotname=$(echo "SS_"$(date "+%d%m%Y_%H%M"))
        vboxmanage snapshot "$vm" take "$snapshotname";
        done;
}

ZIP_AND_MOVE() {
    echo "The function will zip all top-level directories in the folder it is executed"
    echo "If a path is supplied as an argument ,it will move the zips to the supplied path"
    echo "Or else only zips are created in the present subdirectory and left"
    mapfile -t dirs < <(ls -d1 */)
    for directory in "${dirs[@]}"; 
    do
        echo "$directory"
        dirwithoutslash=$(echo "$directory"|sed 's:/*$::')       
        zipname=$(echo "$dirwithoutslash".zip)        
        echo "$dirwithoutslash ----------------> $zipname"        
        echo "Removing the zip file if it already exists"
        rm -rf "$zipname" || true
        zip -9 -r "$zipname" "$dirwithoutslash"
        rm -rf "$dirwithoutslash"
        if [ -z "$1" ]
        then
        echo "No path was specified so exiting without a move"
        else
        echo "Moving the zip file to the specified path"
        mv -v "$zipname" "$1"
        fi
    done
    
}
RUN_DISOWNED() {
    "$@" & disown
}

DISOWN_SILENCE_FUNCTION() {
    # run_disowned and silenced

    run_disowned "$@" 1>/dev/null 2>/dev/null
}
RENAME_ALL_WALLPAPERS(){
    dldir="/home/$USER/Pictures/Wallpapers/"
    [ ! -d "$dldir" ] && mkdir -p "$dldir"
    picturelist=()
    while IFS=  read -r -d $'\0'; do
        picturelist+=("$REPLY")
    done < <(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
    for full_file_name in "${picturelist[@]}"; 
    do
            extension="${full_file_name##*.}"
            new_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)
            mv -v "$full_file_name" "$dldir$new_name.$extension"            
    done
    find . -type d -empty -print -delete
}
SEPARATEWALLS(){
	dir_size=2000
	dir_name="wallpaper"
	n=$((`find . -maxdepth 1 -type f | wc -l`/$dir_size+1))
	for i in `seq 1 $n`;
	do
	    mkdir -p "$dir_name$i";
	    find . -maxdepth 1 -type f | head -n $dir_size | xargs -i mv "{}" "$dir_name$i"
	done
}
