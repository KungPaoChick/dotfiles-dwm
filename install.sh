#!/bin/env bash
set -e

set_color() {
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

main() {
    set_color
    
    # copies dwm.desktop file to xsessions directory
    if [[ ! -d /usr/share/xsessions/ ]]; then
        sudo mkdir /usr/share/xsessions/
        sudo cp dwm.desktop /usr/share/xsessions/
    else
        sudo cp dwm.desktop /usr/share/xsessions/
    fi

    # make srcs folder
    if [[ ! -d $HOME/.srcs ]]; then
        mkdir -p $HOME/.srcs
    fi

    reset
    echo "${BLUE}"
    echo "▄▄      ▄▄ ▄▄▄▄▄▄▄▄  ▄▄           ▄▄▄▄     ▄▄▄▄    ▄▄▄  ▄▄▄  ▄▄▄▄▄▄▄▄  ▄▄"; sleep 0.1
    echo "██      ██ ██▀▀▀▀▀▀  ██         ██▀▀▀▀█   ██▀▀██   ███  ███  ██▀▀▀▀▀▀  ██"; sleep 0.1
    echo "▀█▄ ██ ▄█▀ ██        ██        ██▀       ██    ██  ████████  ██        ██"; sleep 0.1
    echo " ██ ██ ██  ███████   ██        ██        ██    ██  ██ ██ ██  ███████   ██"; sleep 0.1
    echo " ███▀▀███  ██        ██        ██▄       ██    ██  ██ ▀▀ ██  ██        ▀▀"; sleep 0.1
    echo " ███  ███  ██▄▄▄▄▄▄  ██▄▄▄▄▄▄   ██▄▄▄▄█   ██▄▄██   ██    ██  ██▄▄▄▄▄▄  ▄▄"; sleep 0.1
    echo " ▀▀▀  ▀▀▀  ▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀     ▀▀▀▀     ▀▀▀▀    ▀▀    ▀▀  ▀▀▀▀▀▀▀▀  ▀▀"
    echo "${RESET}"

    #
    # choose video driver
    #
    echo "${BOLD}##########################################################################${RESET}

${RED}1.) xf86-video-amdgpu     ${GREEN}2.) nvidia     ${BLUE}3.) xf86-video-intel${RESET}     4.) Skip

${BOLD}##########################################################################${RESET}"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Choose your video card driver. ${YELLOW}(Default: 1)${RESET}: " vidri

    #
    # select an aur helper to install
    #

    HELPER="yay"
    echo "${BOLD}####################${RESET}

${RED}1.) yay     ${BLUE}2.) paru${RESET}

${BOLD}####################${RESET}"
    printf  "\n\n${YELLOW}${BOLD}[!] ${RESET}An AUR helper is essential to install required packages.\n"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Select an AUR helper. ${YELLOW}(Default: yay)${RESET}: " sel

    #
    #
    # post prompt process
    #
    #
    
    # aur helper set to paru if sel var is eq to 2
    if [ $sel -eq 2 ]; then
        HELPER="paru"
    fi

    # clones specifies aur helper
    if ! command -v $HELPER &> /dev/null; then
        git clone https://aur.archlinux.org/$HELPER.git $HOME/.srcs/$HELPER
    fi    

    # video driver card case
    case $vidri in
    [1])
            DRIVER='xf86-video-amdgpu xf86-video-ati xf86-video-fbdev'
            ;;

    [2])
            DRIVER='nvidia nvidia-settings nvidia-utils'
            ;;

    [3])
            DRIVER='xf86-video-intel xf86-video-nouveau'
            ;;

    [4])
            DRIVER="xorg-xinit"
            ;;

    *)
            DRIVER='xf86-video-amdgpu xf86-video-ati xf86-video-fbdev'
            ;;
    esac

    # full upgrade
    clear
    printf "${GREEN}${BOLD}[*] ${RESET}Performing System Upgrade and Installation...\n\n"
    sudo pacman -Syu --noconfirm

    # installing selected video driver
    sudo pacman -S --needed --noconfirm $DRIVER

    # install system packages
    sudo pacman -S --needed --noconfirm - < pkgs.txt

    # aur installer
    if [[ -d $HOME/.srcs/$HELPER ]]; then
        printf "\n\n${YELLOW}${BOLD}[!] ${RESET}We'll be installing ${GREEN}${BOLD}$HELPER${RESET} now.\n\n"
        (cd $HOME/.srcs/$HELPER/; makepkg -si --noconfirm)
    fi

    # install aur packages
    $HELPER -S --needed --noconfirm - < aur.txt

    # enable display manager
    sudo systemctl enable lxdm.service

    # writes grub menu entries, copies grub, themes and updates it
    sudo bash -c "cat >> '/etc/grub.d/40_custom' <<-EOF

    menuentry 'Reboot System' --class restart {
        reboot
    }

    menuentry 'Shutdown System' --class shutdown {
        halt
    }"
    sudo cp -f grubcfg/grubd/* /etc/grub.d/
    sudo cp -f grubcfg/grub /etc/default/
    sudo cp -rf grubcfg/themes/default /boot/grub/themes/
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # create user directories
    xdg-user-dirs-update

    # lxdm theme
    sudo cp -f lxdm/lxdm.conf /etc/lxdm/
    sudo cp -rf lxdm/lxdm-theme/* /usr/share/lxdm/themes/
    
    # copy scripts to /usr/local/bin
    sudo cp -f scripts/* /usr/local/bin    

    # copy home dots
    cp -rf dots/.vimrc \
           dots/.dwm   \
           dots/.dmrc  \
           dots/.xinitrc $HOME

    # copies all dwm configs to .config directory
    if [[ ! -d $HOME/.config ]]; then
        mkdir -p $HOME/.config
        cp -rf configs/* $HOME/.config
    else
        cp -rf configs/* $HOME/.config
    fi

    # compiles dwm configs
    if [[ -d $HOME/.dwm ]]; then
        (cd $HOME/.dwm; sudo make clean install)
    fi

    # clones compiles dmenu configs
    if [[ ! -d $HOME/.config/dmenu ]]; then
        git clone https://github.com/KungPaoChick/dmenu-kungger.git $HOME/.config/dmenu
        (cd $HOME/.config/dmenu; sudo make clean install)
    fi

    # installs fish as default shell environmenti
    if ! command -v fish &> /dev/null; then
        sudo pacman -S --noconfirm fish
        curl -L https://get.oh-my.fish/ > $HOME/.srcs/install.fish; chmod +x $HOME/.srcs/install.fish

        clear
        echo "${YELLOW}${BOLD}[!] ${RESET}oh-my-fish install script has been downloaded. You can execute the installer later on in ${YELLOW}$HOME/.srcs/install.fish${RESET}"; sleep 3
        
        # copies fish configurations
        if [[ ! -d $HOME/.config/fish/ ]]; then
            mkdir -p $HOME/.config/fish
            cp -f shells/fish/config.fish $HOME/.config/fish/
        else
            cp -f shells/fish/config.fish $HOME/.config/fish/
        fi
    fi

    # installs fonts for bar
    FDIR="$HOME/.local/share/fonts"
    echo -e "\n${GREEN}${BOLD}[*] ${RESET}Installing fonts..."
    if [[ -d "$FDIR" ]]; then
        cp -rf fonts/* "$FDIR"
    else
        mkdir -p "$FDIR"
        cp -rf fonts/* "$FDIR"
    fi

    clear
    echo "${GREEN}${BOLD}[*] ${RESET}Everything has been set up for you, ${GREEN}$USER${RESET}"
}

main "@"
