export SHELL="/bin/bash"
export PATH="$PATH:$APP_HOME/bin"

# load some bash utils
helpers=(/etc/bash_completion)
for src in "${helpers[@]}"; do
    [ -f "$src" ] && source "$src"
done
unset helpers

# setup prompt
echo $- | grep -q i 2>/dev/null && . /usr/share/liquidprompt/liquidprompt

# enable colored ls output
eval "$(dircolors -b)"
alias ls="ls -F --color=auto"
alias l="ls -l"
alias ll="ls -lA"
alias la="ls -la"

