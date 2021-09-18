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
    #
    # post prompt process
    #
    #

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
    printf "${GREEN}${BOLD}[*] ${RESET}Performing System Upgrade and Installation...\n\n"
    sudo pacman -Syu --noconfirm

    # installing selected video driver
    sudo pacman -S --needed --noconfirm $DRIVER

    # install system packages
    sudo pacman -S --needed --noconfirm - < pkgs.txt

    # copy home dots
    cp -f dots/.vimrc \
          dots/.xinitrc $HOME

    # copy scripts to /usr/local/bin
    sudo cp -f scripts/* /usr/local/bin    

    # create user directories
    xdg-user-dirs-update

    # copies all dwm configs to .config directory
    if [[ ! -d $HOME/.config ]]; then
        mkdir -p $HOME/.config
        cp -rf configs/* $HOME/.config
    else
        cp -rf configs/* $HOME/.config
    fi

    # compiles dwm configs
    if [[ -d $HOME/.config/dwm ]]; then
        (cd $HOME/.config/dwm; sudo make clean install)
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


    clear
    echo "${GREEN}${BOLD}[*] ${RESET}Everything has been set up for you, ${GREEN}$USER${RESET}"
}

main "@"
