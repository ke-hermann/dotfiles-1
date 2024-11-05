# load theme, defined in functions idr
solarized
# abbreviations
abbr -a ls 'eza --long --header --icons --git'
abbr -a aguu 'sudo apt update  && sudo apt upgrade'
abbr -a agr 'sudo apt remove'
abbr -a agi 'sudo apt install -y'

# customized prompt
# oh-my-posh init fish --config ~/.ohmyposh.json | source
starship init fish | source
# smarter cd
zoxide init fish | source
