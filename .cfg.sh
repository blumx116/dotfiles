echo "sourcing cfgsh"
set -o errexit # exit on error
set -o nounset # exit on access undefined variable

cleanup() {
		set +o errexit
		set +o nounset
		set +o xtrace
}

trap cleanup EXIT

export XDG_DATA_HOME=$HOME/.config

alias v=nvim

source_workspace() {
		if [[ -d ".venv" ]]; then
				. .venv/bin/activate
		fi
		if [[ -e ".vim/workspace.sh" ]]; then
				source .vim/workspace.sh
		fi
		if [[ -e "/opt/homebrew/bin/brew" ]]; then
				# I hate that I have to have this here, but we need to re-add all of the brew paths
				eval "$(/opt/homebrew/bin/brew shellenv)"
		fi

}
source_workspace


f () {
  # fzf with an interrupt handler
  local result

  # Use trap to capture Ctrl-C (SIGINT) and Ctrl-Z (SIGTSTP) signals
  trap 'result=""' INT TSTP

  # Run fzf and capture the selected result
  result=$(fzf)

  # Remove the trap
  trap - INT TSTP

  # Return the result or an empty string if interrupted
  echo "$result"
}

# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

ini () {
		if [[ ! -d ".venv" ]]; then
			# need to create .venv
			$DEFAULT_PYTHON -m venv .venv
			source_workspace
			if [[ -e "requirements.txt" ]]; then
				pip install -r requirements.txt
			elif [[ -e "requirements.in" ]]; then
				pip install -r requirements.in
			fi
		fi
		git init
}

d () {
    selected_dir=$(find "$PROJECTS_HOME" -mindepth 2 -maxdepth 2 -type d | f)
    if [[ -n "$selected_dir" ]]; then
        cd "$selected_dir" && echo "$selected_dir"
    fi

	source_workspace
}

dd () {
    d && ini && v .
}

alias tm="TERM='xterm-256color' tmux"

tmux_split() {
		# Check if the session exists, discarding output
		# We can check $? for the exit status (zero for success, non-zero for failure)
		# source: https://davidltran.com/blog/check-tmux-session-exists-script/
		if ! tm has-session -t "$1" 2>/dev/null; then
				tm new-session -d -s "$1"
				tm split-window -h
		fi
		tm -2 attach-session -d -t "$1"
}
alias t0="tmux_split 0"
alias t1="tmux_split 1"
alias t2="tmux_split 2"



alias re_source=". ~/.bash_profile"

alias zshrc="v ~/.zshrc && re_resource"
alias bashrc="v ~/.bashrc && re_source"
alias cfgsh="v ~/.cfg.sh && re_source"
alias bashprof="v ~/.bash_profile && re_source"
alias profsh="v ~/.prof.sh && re_source"

# from https://docs.google.com/document/d/1VH7-DlorHZFEtoa-jCSY7kSFAqsnF0oIBY-QaYTqcH8/edit?tab=t.0
# (Google internal document)
alias hlo="XLA_FLAGS=\"--xla_dump_to=./hlo\""


cleanup
