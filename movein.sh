#!/bin/bash
#
# movein.sh
#
# Move in script developed with Linux Mint 17 KDE.
#
# NOTE: this script should be called directly using the following command:
#       sudo ./movein.sh
#
# set -x

#---------------------------------------------------------
# Constants
#---------------------------------------------------------
BACKUP_EXT=.orig


#---------------------------------------------------------
# Functions
#---------------------------------------------------------
# Backup original files by copying to a new file with a backup extension appended to filename
# TODO can sudo be used to call this function instead of using from within?
function backup_file()
    {
    local FILE="$1"
    
    local BACKUP_FILE="${FILE}${BACKUP_EXT}"
    
    # Verify backup file does not exist
    if [ -e "$BACKUP_FILE" ]; then
    
        echo "WARNING: Not backing up $FILE as $BACKUP_FILE already exists"
    else
        # Using sudo in vain, hence the preservation of ownership
        sudo cp --preserve=all "$FILE" "$BACKUP_FILE"
    fi
    }
    

# #---------------------------------------------------------
# # Get install command for the Linux system
# #---------------------------------------------------------
# if [ $( which "apt-get" ) ]; then
# 
#     INSTALL_CMD='apt-get'
# elif [ $( which "yum" ) ]; then
# 
#     INSTALL_CMD='yum install'
# else
#     echo "Error: no installer found."
#     exit 1
# fi
# 
# #---------------------------------------------------------
# # Save a backup of original install list
# #---------------------------------------------------------
# if [ $( which "dpkg" ) ]; then
# 
#     dpkg -l > ~/.dpkg_-l.orig
# fi
# 
# #---------------------------------------------------------
# # Install desired packages
# #---------------------------------------------------------
# # TODO consider declaring list of packages to install and looping through in section to install desired packages
# # TODO may need to pipe to yes or use no-prompt flags
# sudo $INSTALL_CMD git
# sudo $INSTALL_CMD meld
# sudo $INSTALL_CMD synergy
# 
# 
# #---------------------------------------------------------
# # Install scripts and config files from git repository
# #---------------------------------------------------------
# # TODO setup git repo on github
# # TODO install scripts to ~/bin
# # TODO install .gitconfig and .bash_aliases to ~ (could make install interactive to ask for git username and email)


#---------------------------------------------------------
# Setup hotkeys
#---------------------------------------------------------
# TODO create function to create custom hotkey given:
#       1. custom hotkey #
#       2. binding
#       3. command
#       4. name
# NOTE don't put ~ in keybindings as these won't work, make sure these are expanded in this shell instead
# TODO create the following keybinding:
# $ gsettings get org.cinnamon.keybindings.custom-keybinding:/org/cinnamon/keybindings/custom-keybindings/custom0/ name
#       'Open directory "programming"'
# $ gsettings get org.cinnamon.keybindings.custom-keybinding:/org/cinnamon/keybindings/custom-keybindings/custom0/ binding
#       '<Alt><Super>p'
# $ get org.cinnamon.keybindings.custom-keybinding:/org/cinnamon/keybindings/custom-keybindings/custom0/ command
#       'gnome-open /home/jeremy/Documents/programming/'
# TODO modify hotkey for moving monitor to alternate window (implemented using KDE specific hotkey)


# #---------------------------------------------------------
# # Setup meld_two context menu entry
# #---------------------------------------------------------
# # Local variables
# # TODO may need to use /usr/share/applications files instead as this is verified working
# LIST_FILE=$HOME/.local/share/applications/mimeapps.list
# # LIST_FILE=/usr/share/applications/mimeapps.list
# LIST_FILE_SIZE=$(cat $LIST_FILE | wc -l)
# # TODO may also need to update text/plain feild
# FILE_TYPE_FIELD=application/x-shellscript
# 
# # Create .desktop file
# sudo echo "[Added Associations]
# Name=meld_two
# Comment=meld_two
# Exec=meld_two %f
# Icon=/usr/share/icons/Mint-X/apps/scalable/meld.svg
# Type=Application
# StartupNotify=true
# MimeType=text/plain;
# Terminal=false
# Categories=TextTools;Viewer;Graphics;Qt;" > /usr/share/applications/meld_two.desktop
# #Categories=TextTools;Viewer;Graphics;Qt;" > ~/.local/share/applications/meld_two.desktop
# 
# # Backup the original .list file
# cp $LIST_FILE $LIST_FILE.orig
# 
# # Get line number of the Added Associations field
# LINE_NUMBER=$(grep -n -A $LIST_FILE_SIZE '\[Added Associations\]' $LIST_FILE | grep -m 1 "$FILE_TYPE_FIELD=" | sed 's,\(^[0-9]\).*,\1,')
# 
# # Update .list file to use .desktop file
# sed -i $LINE_NUMBER"s,\(.*$FILE_TYPE_FIELD=.*\),\1;meld_two.desktop," $LIST_FILE


#---------------------------------------------------------
# Setup synergy client
#---------------------------------------------------------
# Prompt the user to setup synergy client
read -p "Setup synergy client? (Y/n): " CONFIRM

if [ "$CONFIRM" == "" ] || [ "$CONFIRM" == "Y" ] || [ "$CONFIRM" == "y" ]; then

    # Get name of display manager
    DISP_MGR_NAME=$(basename $(cat /etc/X11/default-display-manager))

    case $DISP_MGR_NAME in

        mdm)
            echo "Installing synergy client for use with display manager $DISP_MGR_NAME"
            
            # TODO install synergy_client from online git repo to $HOME/bin/synergy_client
            
            # Configure synergy_client for server IP address
            read -p "Enter synergy server IP address: " SYN_SRV_IP_ADDR

            sed -i "s,^IP_ADDR=.*$,IP_ADDR=$SYN_SRV_IP_ADDR," "$HOME/bin/synergy_client"

            # Update /etc/mdm/Init/Default to restart synergy client at end of script (before exit call)
            FILE=/etc/mdm/Init/Default
            backup_file "$FILE"
            FILE_SIZE=$(cat "$FILE" | wc -l)
            LINE_NUM=$(( $FILE_SIZE - 1 ))
            sudo sed -i "${LINE_NUM}s,^,\n$HOME/bin/synergy_client start\n," "$FILE"
            
            # Create /etc/mdm/PostLogin/Default to stop the synergy client
            FILE=/etc/mdm/PostLogin/Default
            sudo echo -e "#!/bin/sh\n$HOME/bin/synergy_client stop\n" > "$FILE"
            sudo chmod +x "$FILE"
            
            # Create synergy_client symlink in local KDE autostart directory for post login startup
            ln -s $HOME/bin/synergy_client $HOME/.kde/Autostart/synergy_client
            ;;
        *)
            echo "WARNING: No functionality to install synergy client for display manager $DISP_MGR_NAME"
            ;;
    esac
else
    echo "Synergy client installation skipped..."
fi




