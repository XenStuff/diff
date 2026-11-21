sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y && \
sudo dnf install -y \
vlc gimp fastfetch btop htop neovim \
p7zip p7zip-plugins gnome-tweaks \
gnome-extensions-app gnome-shell-extension-appindicator \
gstreamer1-plugins-ugly zoxide fzf eza \
gnome-shell-extension-user-theme && \
sudo dnf group install -y "Development Tools"
