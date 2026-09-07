#!/bin/bash

NIXDROID_OPT_DIR="/opt/NixDroid"
NIXDROID_ENV_FILE="$NIXDROID_OPT_DIR/.env"
NIXDROID_DESKTOP_SRC="$NIXDROID_OPT_DIR/NixDroid.desktop"
NIXDROID_DESKTOP_DEST="/usr/share/applications/NixDroid.desktop"

USER_HOME_DIR="$HOME"
USER_CONFIG_DIR="$USER_HOME_DIR/.config"
AOSP_CONFIG_DIR="$USER_CONFIG_DIR/Android Open Source Project"
USER_ANDROID_DIR="$USER_HOME_DIR/.android"

ZSHRC_FILE="$USER_HOME_DIR/.zshrc"
BASHRC_FILE="$USER_HOME_DIR/.bashrc"

install()
{
        echo "Installing required packages"
        sudo apt update -y
        sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils cpu-checker unzip wget curl

        echo "Checking KVM Support"
        if sudo kvm-ok > /dev/null 2>&1;
        then
                sudo usermod -aG kvm "$USER"
                sudo usermod -aG libvirt "$USER"
                echo -e "KVM Support enabled\nRestart computer after installation is complete"
        else
                echo "Confirm that your CPU virtualization extensions (Intel VT-x or AMD-V) are enabled in BIOS/UEFI and that KVM is accessible"
                read -r -p "Press enter to exit"
                exit 1
        fi

        echo "Configuring emulator"
        sudo mkdir -p "$NIXDROID_OPT_DIR"
        sudo chown -R "$USER:$USER" "$NIXDROID_OPT_DIR"
        mkdir -p "$USER_CONFIG_DIR"
        cp -r "Android Open Source Project" "$USER_CONFIG_DIR/"
        tar -xvf NixDroid.tar.xz -C "$NIXDROID_OPT_DIR"

        if [[ -f "$ZSHRC_FILE" ]];
        then
                echo "Adding variables to zshrc";
                echo "# NixDroid Configuration Start" >> "$ZSHRC_FILE";
                echo "[ -f $NIXDROID_ENV_FILE ] && source $NIXDROID_ENV_FILE" >> "$ZSHRC_FILE";
                echo "# NixDroid Configuration End" >> "$ZSHRC_FILE";
        fi

        if [[ -f "$BASHRC_FILE" ]];
        then
                echo "Adding variables to .bashrc";
                echo "# NixDroid Configuration Start" >> "$BASHRC_FILE";
                echo "[ -f $NIXDROID_ENV_FILE ] && source $NIXDROID_ENV_FILE" >> "$BASHRC_FILE";
                echo "# NixDroid Configuration End" >> "$BASHRC_FILE";
        fi

        sudo cp -r "$NIXDROID_DESKTOP_SRC" "$NIXDROID_DESKTOP_DEST"
        echo -e "Restart required.\nWould you like to restart now? [y/n]"
        read -r -p "Input: " RESTART
        if [[ "$RESTART" == "y" || "$RESTART" == "Y" ]];
        then
                sudo reboot;
        else
                echo "Please restart manually"
        fi
}

uninstall()
{
        echo "Uninstalling Emulator"
        sudo rm -vrf "$USER_ANDROID_DIR" "$AOSP_CONFIG_DIR" "$NIXDROID_OPT_DIR" "$NIXDROID_DESKTOP_DEST"

        if [[ -f "$ZSHRC_FILE" ]];
        then
                echo "Removing variables from .zshrc"
                sed -i '/# NixDroid Configuration Start/,/# NixDroid Configuration End/d' "$ZSHRC_FILE"
        fi

        if [[ -f "$BASHRC_FILE" ]];
        then
                echo "Removing variables from .bashrc"
                sed -i '/# NixDroid Configuration Start/,/# NixDroid Configuration End/d' "$BASHRC_FILE"
        fi

        echo "Uninstallation complete. Please restart your terminal."
}

echo -e "[1] Install\n[2] Uninstall\n[3] Exit"
read -r -p "Input: " SELECT_OPTION

if [[ ! "$SELECT_OPTION" =~ ^[0-9]+$ ]];
then
    echo "Invalid input: Please enter a number."
    exit 1
fi

if [[ "$SELECT_OPTION" -eq 1 ]];
then
    install
elif [[ "$SELECT_OPTION" -eq 2 ]];
then
    uninstall
else
    exit 0
fi
