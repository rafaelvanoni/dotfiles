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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\] \n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h\w\n\$ '
fi

unset color_prompt force_color_prompt

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

export GOPATH=~/Work/go

export PROJCALICO=$GOPATH/src/github.com/projectcalico
export REMOTE_CALICO=https://github.com/projectcalico

export PATH=$PATH:~/.local/bin:$GOPATH/bin

export GOTRACEBACK=crash
ulimit -c unlimited

alias less='less -R'
alias perms='stat -c "%a %n "'
alias findall='find .  -name ".*" -o -name "*" -a -type f'
alias gocover='go test . -coverprofile cover.out && go tool cover -html cover.out && rm cover.out'
alias calicoctl='kubectl exec -i -n kube-system calicoctl /calicoctl -- '
alias clearall='clear; echo -e "\033c\e[3J"'

function set-title() {
	if [ ! -z "$1" ]; then
		wmctrl -r :ACTIVE: -N "$1"
	fi
}

function goimport () {
	if [ ! -d "$PWD/.git" ]; then
		echo "no git repository found"
		return
	fi
	for i in `git status -s -uno | egrep -v 'Makefile|glide' | cut -d' ' -f3`; do
		csum_pre=$(md5sum $i)
		goimports -w $i;
		csum_post=$(md5sum $i)
		if [ "$csum_pre" != "$csum_post" ]; then
			echo "..fixed $i"
		else
			echo "..no changes to $i"
		fi
	done
}

function xref () {
	if [ ! -d "$PWD/.git" ]; then
		echo "no git repository found"
	fi

	rm -f cscope.* tags
	find . -name '*.go' | egrep -v 'vendor' > /tmp/cscope.list
	cscope -b -i /tmp/cscope.list
	ctags -L /tmp/cscope.list
	rm -f /tmp/cscope.list
}

function gofind () {
	if [ -z "$1" ]; then
		echo "nothing to look for"
		return
	fi

	find . -name '*.go' -not -path '*vendor*' | xargs grep $1
}

function docker-clean () {
	for i in `docker ps -q -a`; do
		echo "stopping/deleting docker $i"
		docker kill $i &> /dev/null
		docker rm $i &> /dev/null
	done

#	echo "removing all images"
#	docker rm -f $(docker ps -a -q) && docker rmi -f $(docker images -q)
}

function aws-login () {
	(cd $PRIVATE_REPOS/calico-ready-clusters/kubeadm/aws
	$(terraform output master_connect_command))
}

complete -C '/usr/local/bin/aws_completer' aws
. <(eksctl completion bash)
