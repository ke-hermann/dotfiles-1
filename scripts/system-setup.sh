# pretty prompt
curl -sS https://starship.rs/install.sh | sh

# dotfile management 
sh -c "$(curl -fsLS get.chezmoi.io)"

git config --global user.name "Kevin Hermann"
git config --global user.email "hermannkevin@gmail.com"

# nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)

sudo update-alternatives --set editor /usr/bin/vim.basic

# better history
/bin/bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)"

# Terminal Multiplexer, modern tmux alternative
bash <(curl -L zellij.dev/launch)




