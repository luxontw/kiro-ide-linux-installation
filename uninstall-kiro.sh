echo -e "${YELLOW}Uninstalling Kiro...${NC}"

INSTALL_DIR="/usr/share/kiro"
SYMLINK_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/share/applications"
NEED_SUDO=true
CLEAN_USER_DATA=false

# Check if a clean removal was requested
if [ "$2" == "--clean" ]; then
    CLEAN_USER_DATA=true
    echo -e "${YELLOW}Clean removal requested. User configuration will also be removed.${NC}"
fi

# Check if installation exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Kiro is not installed at $INSTALL_DIR.${NC}"
    
    # Check alternative installation
    if [ "$1" == "--user" ] && [ -d "$DEFAULT_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Kiro might be installed at $DEFAULT_INSTALL_DIR. Use the script without the --user flag to uninstall.${NC}"
    elif [ "$1" != "--user" ] && [ -d "$USER_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Kiro might be installed at $USER_INSTALL_DIR. Use the --user flag to uninstall.${NC}"
    else
        echo -e "${RED}Kiro installation not found.${NC}"
    fi
    
    return 1
fi

# Remove installation directory
echo -e "${YELLOW}Removing installation directory...${NC}"
if [ "$NEED_SUDO" = true ]; then
    sudo rm -rf "$INSTALL_DIR"
else
    rm -rf "$INSTALL_DIR"
fi

# Remove symbolic link
echo -e "${YELLOW}Removing symbolic link...${NC}"
if [ -L "$SYMLINK_DIR/kiro" ]; then
    if [ "$NEED_SUDO" = true ]; then
        sudo rm "$SYMLINK_DIR/kiro"
    else
        rm "$SYMLINK_DIR/kiro"
    fi
fi

# Remove desktop file
echo -e "${YELLOW}Removing desktop entry...${NC}"
if [ -f "$DESKTOP_DIR/kiro.desktop" ]; then
    if [ "$NEED_SUDO" = true ]; then
        sudo rm "$DESKTOP_DIR/kiro.desktop"
    else
        rm "$DESKTOP_DIR/kiro.desktop"
    fi
    
    # Update desktop database if command exists
    if command -v update-desktop-database &> /dev/null; then
        if [ "$NEED_SUDO" = true ]; then
            sudo update-desktop-database "$DESKTOP_DIR"
        else
            update-desktop-database "$DESKTOP_DIR"
        fi
    fi
fi

# Remove user configuration data if clean removal was requested
if [ "$CLEAN_USER_DATA" = true ]; then
    echo -e "${YELLOW}Removing user configuration data...${NC}"
    
    # Common locations for user configuration data
    local USER_CONFIG_DIRS=(
        "$HOME/.config/kiro"
        "$HOME/.kiro"
        "$HOME/.local/state/kiro"
        "$HOME/.local/share/kiro-extensions"
        "$HOME/.cache/kiro"
        "$HOME/.vscode-kiro"
    )
    
    for dir in "${USER_CONFIG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${YELLOW}Removing $dir${NC}"
            rm -rf "$dir"
        fi
    done
    
    echo -e "${GREEN}All user configuration data has been removed.${NC}"
else
    echo -e "${BLUE}Note: User configuration data has been preserved.${NC}"
    echo -e "${BLUE}To remove user data, rerun with the --clean flag.${NC}"
fi

echo -e "${GREEN}Kiro has been successfully uninstalled!${NC}"