sudo dnf install -y \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-45.noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-45.noarch.rpm && \
sudo dnf upgrade --refresh -y && \
sudo dnf install -y \
vlc gimp git curl wget fastfetch btop htop neovim \
unzip p7zip p7zip-plugins gnome-tweaks \
gnome-extensions-app gnome-shell-extension-appindicator \
ffmpeg gstreamer1-plugins-good gstreamer1-plugins-bad-free \
gstreamer1-plugins-ugly gstreamer1-libav \
zoxide fzf bat eza &&
sudo dnf group install -y "Development Tools"
