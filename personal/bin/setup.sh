apt install git
apt install curl
apt install xclip
snap install alacritty
snap install clion
snap install webstorm
snap install rubymine
snap install mailspring
snap install
# install github-cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt upgrade
apt install gh
# install brave browser
sudo apt install apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
apt install tmux
apt install vim
apt install zsh
apt install fonts-powerline
apt install clang
apt install clang-tidy
apt install ruby
apt install ruby-bundler
apt install jekyll
apt install libgtest-dev
apt install octave
apt install bat
apt install tig
apt install nodejs
apt install npm
