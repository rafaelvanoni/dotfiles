# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h \[\033[00m\]\[\033[01;34m\]\w \033[0;36m\]$(get_git_branch)\[\033[00m\] \n\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h\w \033[0;36m\]$(get_git_branch)\n\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h\w\n\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export GOPATH=~/go
export GO111MODULE=auto
export GOTRACEBACK=crash

export PATH=$PATH:/usr/local/go/bin:~/.local/bin:$GOPATH/bin
export CC=/usr/bin/gcc

alias less='less -R'
alias watch='watch -pn 1'
alias perms='stat -c "%a %n "'
alias findall='find . -type f -a -name ".*" -o -type f -a -name "*"'
alias findc='find . -type f -a -name "*.c" -o -type f -a -name "*.h"'
alias evalssh='eval "$(ssh-agent -s)"; ssh-add ~/.ssh/github.id_rsa'
alias clearall='clear; echo -e "\033c\e[3J"'
alias xinvert='xcalib -invert -alter'
alias removeDoubleEmptyLines="sed -i 'N;/^\n$/D;P;D;'"
alias dmesg='dmesg -Hkw'
alias xmod='xmodmap ~/.Xmodmap'

function set-title() {
	if [ ! -z "$1" ]; then
		wmctrl -r :ACTIVE: -N "$1"
	fi
}

function clone_one () {
	if [ -z "$1" ]; then
		printf ":: ${FUNCNAME[0]}() requires a repository name\n"
		return
	fi

	printf ":: cloning github.com:rafaelvanoni/$1.git into $PWD/$1\n"
	git clone git@github.com:rafaelvanoni/$1.git $1
	printf "\n"
}

function xref () {
	if [ ! -d "$PWD/.git" ]; then
		echo "no git repository found"
	fi

	file=/tmp/cscope.list

	rm -f cscope.* tags
	find . -type f -a -name '*.c' -o -type f -name '*.h' > $file

	cscope -b -i $file
	ctags -L $file
	rm -f $file
}

function gofind () {
	if [ -z "$1" ]; then
		echo ":: nothing to look for"
		return
	fi

	find . -type f -a -name ".*" -o -type f -a -name "*.go" | egrep -v 'vendor|go-pkg-cache|LOG|zz_generated' | xargs grep $1
}

function gofunc () {
	gofind $1 | grep func
}

function get_git_branch() {
	if [ -e .git/HEAD ]; then
		x=$(cat .git/HEAD); echo "${x##*/}"
	fi
}

function docker-clean () {
	for i in `docker ps -q -a | sort -R --random-source=/dev/random`; do
		echo "stopping/deleting docker $i"
		docker kill $i &> /dev/null
		docker rm $i &> /dev/null
	done
}

function docker-wipe () {
	docker rm -f $(docker ps -a -q) && docker rmi -f $(docker images -q)
}

function dump_stack(){
    local i=0
    local line_no
    local function_name
    local file_name
    while caller $i; do ((i++)) ;done | while read line_no function_name file_name;do echo -e "\t$file_name:$line_no\t$function_name" ;done >&2
}

ulimit -c unlimited
