# --------- Symlink Configuration Files To Git Repo ---------------
ln -s $SCRIPT_DIR/.cfg.sh ~/.cfg.sh
mkdir -p $XDG_DATA_HOME/nvim
ln -s $SCRIPT_DIR/init.vim $XDG_DATA_HOME/nvim/init.vim
ln -s $SCRIPT_DIR/kitty.conf $XDG_DATA_HOME/kitty/kitty.conf

# --------- Make Sure That RC Files All Source Each Other-----
write_once() {
	# writes a line if it isn't already in the file
	# means that we're not gonna' start exponentially slowing ourselves down
	# with the sources each time we run this script
	line=$1
	file=$2
	grep -qxF "$line" "$file" || (echo; echo "$line") >> "$file"
}

# add PROJECTS_HOME for usage with `dd` and `d`
if [[ -z $(grep "PROJECTS_HOME=" "$HOME/.bash_profile") ]]; then
		echo "Please input the path to be used by \`d\` and \`dd\`"
		read input_path

		if [ -n "$input_path" ]; then
				escaped_input_path=$(printf "%s\n" "$input_path" | sed 's/[\\"$]/\\&/g')
				echo "export PROJECTS_HOME=\"$escaped_input_path\"" >> ~/.bash_profile
		else 
				echo "No path received, exiting"
				exit
		fi
fi


write_once "source ~/.cfg.sh" $HOME/.bash_profile		#~/.cfg.sh is shared configuration from github
write_once "source ~/.prof.sh" $HOME/.bash_profile		#~/.prof.sh is machine-specific configuration (possibly from github)e
write_once "source ~/.bash_profile" $HOME/.bashrc		#~/.bashrc is bash-specific, may be written by env
write_once "source ~/.bash_profile" $HOME/.zshrc 		#~/.zshrc is zsh-specific, may be written by env
# ~/.bash_profile may be written by env, is the 'one' file that will always be sourced but not owned by me
source $HOME/.bash_profile

# -------------- Install Neovim -------------------
# nvim package manager install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
