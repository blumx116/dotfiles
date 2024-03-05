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

if [[ -e ".venv" ]]; then
		. .venv/bin/activate
fi


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
			python3.11 -m venv .venv
			. .venv/bin/activate
			if [[ -e "requirements.txt" ]]; then
				pip install -r requirements.txt
			elif [[ -e "requirements.in" ]]; then
				pip install -r requirements.in
			fi
		fi
		. .venv/bin/activate

}

d () {
    selected_dir=$(find "$PROJECTS_HOME" -maxdepth 2 -type d | f)
    if [[ -n "$selected_dir" ]]; then
        cd "$selected_dir" && echo "$selected_dir"
    fi
}

dd () {
    d && ini && v .
}


alias re_source=". ~/.bash_profile"

alias zshrc="v ~/.zshrc && re_resource"
alias bashrc="v ~/.bashrc && re_source"
alias cfgsh="v ~/.cfg.sh && re_source"
alias bashprof="v ~/.bash_profile && re_source"
alias profsh="v ~/.prof.sh && re_source"

cleanup
