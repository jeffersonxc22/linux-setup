#!/bin/bash

# Script de configuração para Fedora
# Criado por Jefferson Xenofonte


### --- Funções de verificação --- ###
is_installed() {
    rpm -q "$1" &>/dev/null || flatpak list | grep -q "$1"
}

### --- Configuração do DNF --- ###
echo -e "\n>>> Configurando DNF para melhor desempenho..."
if ! grep -q "max_parallel_downloads=10" /etc/dnf/dnf.conf; then
    sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bak 2>/dev/null
    sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOL
[main]
max_parallel_downloads=10
fastestmirror=true
deltarpm=true
EOL
    echo "Configuração do DNF atualizada."
else
    echo "Configurações do DNF já existem."
fi

### --- RPM Fusion --- ###
echo -e "\n>>> Verificando RPM Fusion..."
if ! is_installed rpmfusion-free-release; then
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    echo "RPM Fusion já instalado."
fi

### --- Codecs Multimídia --- ###
echo -e "\n>>> Verificando codecs multimídia..."
if ! sudo dnf group list installed | grep -q "Multimedia"; then
    sudo dnf group install -y Multimedia
else
    echo "Codecs multimídia já instalados."
fi

### --- Atualização do sistema --- ###
echo -e "\n>>> Atualizando o sistema..."
sudo dnf update -y

### --- Firmware (fwupdmgr) --- ###
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

### --- Zsh --- ###
echo -e "\n>>> Configurando Zsh..."
if ! is_installed zsh; then
    sudo dnf install -y zsh
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh) $(whoami)
    echo "Shell padrão alterado para Zsh."
fi

if [ ! -f ~/.zshrc ]; then
    touch ~/.zshrc
fi


### --- Git --- ###
echo -e "\n>>> Verificando Git..."
if ! is_installed git; then
    sudo dnf install -y git
    git config --global user.name "Jefferson Xenofonte"
    git config --global user.email "jeffersonxc.22@gmail.com"
else
    echo "Git já instalado."
fi

### --- Oh My Zsh --- ###
echo -e "\n>>> Verificando Oh My Zsh..."
if [ ! -d ~/.oh-my-zsh ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://install.ohmyz.sh/)" "" --unattended
else
    echo "Oh My Zsh já instalado."
fi

### --- Plugins Zsh --- ###
echo -e "\n>>> Verificando plugins Zsh..."
plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$plugins_dir"

declare -A zsh_plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
)

for plugin in "${!zsh_plugins[@]}"; do
    if [ ! -d "$plugins_dir/$plugin" ]; then
        git clone "${zsh_plugins[$plugin]}" "$plugins_dir/$plugin"
    fi
done

if ! grep -q "plugins=(" ~/.zshrc; then
    cat >> ~/.zshrc <<EOL

# Plugins customizados
plugins=(
    git
    docker
    docker-compose
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)
EOL
fi

if ! grep -q "alias zshconfig" ~/.zshrc; then
    echo "alias zshconfig='code ~/.zshrc'" >> ~/.zshrc
fi

### --- Neofetch --- ###
echo -e "\n>>> Verificando Neofetch..."
if ! is_installed neofetch; then
    sudo dnf install -y neofetch
else
    echo "Neofetch já instalado."
fi

### --- DNFDragora --- ###
echo -e "\n>>> Verificando DNFDragora..."
if ! is_installed dnfdragora; then
    sudo dnf install -y dnfdragora
else
    echo "DNFDragora já instalado."
fi

### --- Visual Studio Code --- ###
echo -e "\n>>> Verificando VS Code..."
if ! is_installed code; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<EOL
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOL
    sudo dnf install -y code
else
    echo "VS Code já instalado."
fi


### --- GNOME Tweaks --- ###
echo -e "\n>>> Verificando GNOME Tweaks..."
if ! flatpak list | grep -q org.gnome.tweaks; then
    flatpak install -y flathub org.gnome.tweaks
    echo "alias gtweaks='flatpak run org.gnome.tweaks'" | sudo tee -a /etc/bashrc > /dev/null
else
    echo "GNOME Tweaks já instalado."
fi

### --- Extension Manager --- ###
echo -e "\n>>> Verificando Extension Manager..."
if ! flatpak list | grep -q com.mattjakeman.ExtensionManager; then
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    echo "alias extensions='flatpak run com.mattjakeman.ExtensionManager'" | sudo tee -a /etc/bashrc > /dev/null
else
    echo "Extension Manager já instalado."
fi

### --- Finalização --- ###
echo -e "\n\u001b[32mConfiguração concluída com sucesso!\u001b[0m"
echo -e "\nRecomendações:"
echo -e "1. Reinicie o terminal ou execute: exec zsh"
echo -e "2. Para GNOME Tweaks use: gtweaks"
echo -e "3. Para Extension Manager use: extensions\n"
