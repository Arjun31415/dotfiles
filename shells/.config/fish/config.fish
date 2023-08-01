## Set values
# Hide welcome message
export EDITOR=nvim
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT 1
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set LUA_PATH '/usr/share/lua/5.4/?.lua;/usr/share/lua/5.4/?/init.lua;/usr/lib/lua/5.4/?.lua;/usr/lib/lua/5.4/?/init.lua;./?.lua;./?/init.lua;/root/.luarocks/share/lua/5.4/?.lua;/root/.luarocks/share/lua/5.4/?/init.lua'
set LUA_CPATH '/usr/lib/lua/5.4/?.so;/usr/lib/lua/5.4/loadall.so;./?.so;/root/.luarocks/lib/lua/5.4/?.so'
set NPM_PACKAGES "$HOME/.npm-global"
set PATH $PATH "~/.cargo/bin"
set PATH $PATH $SONAR_SCANNER_HOME/bin
set PATH $PATH "$HOME/.luarocks/bin/"
set SONAR_SCANNER_OPTS -server
set PATH $PATH $HOME/.sonar/build-wrapper-linux-x86
set NODE_PATH "$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
set PATH $PATH "$HOME/go/bin/"
set LC_ALL en_IN.UTF-8
set SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
# use neovim for vim when possible
command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d"
alias vim="nvim"
alias vimdiff="nvim -d"
alias rusty-man="rusty-man --viewer tui"
alias unset 'set --erase'
alias neovim="nvim"

if test -f ~/.venv/bin/activate.fish
    source ~/.venv/bin/activate.fish
end
## Export variable need for qt-theme
if type qtile >>/dev/null 2>&1
    set -x QT_QPA_PLATFORMTHEME qt5ct
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end


if test -z (pgrep ssh-agent)
    eval (ssh-agent -c | head -n2)
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end
# Add ~/.npm-packages to path
if test -d ~/.npm-packages
    set -p PATH "$HOME/.npm-packages/bin"
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end


## Starship prompt
if status --is-interactive
    source ("starship" init fish --print-full-init | psub)
end


## Advanced command-not-found hook
# source /usr/share/doc/find-the-command/ftc.fish


## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | trim-right /)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

## Useful aliases
# Replace ls with exa
alias ls='exa -al --color=always --group-directories-first --icons' # preferred listing
alias la='exa -a --color=always --group-directories-first --icons' # all files and dirs
alias ll='exa -l --color=always --group-directories-first --icons' # long format
alias lt='exa -aT --color=always --group-directories-first --icons' # tree listing
alias l.="exa -a | egrep '^\.'" # show only dotfiles
alias ip="ip -color"
alias qqq='exit'

# Replace some more things with better alternatives
alias cat='bat --style header --style snip --style changes --style header'
[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru'

# Common use
alias grubup="sudo update-grub"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -xvf '
alias wget='wget -c '
alias rmpkg="sudo pacman -Rdd"
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upd='/usr/bin/garuda-update'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short' # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size in MB



# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

## Run fastfetch if session is interactive
if status --is-interactive && type -q fastfetch
    fastfetch --load-config neofetch
else if status --is-interactive && type -q neofetch
    neofetch
end
if status --is-interactive && type -q neofetch
    neofetch
end


trap "kill $SSH_AGENT_PID > /dev/null 2> /dev/null" exit
trap "ssh-agent -k /dev/null 2> /dev/null" exit
