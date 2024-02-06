# ---------- Simple Utilities ---------------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mac_conditional_install () {
		# argument 1 is the utility name, we'll use 'which' to check if it's installed
		# argument 2 is the command to run to install the script
		install_path=$(which "$1")
		if [[ -z "$install_path" || "$install_path" == *"not found"* ]]; then
				$2
		else 
				echo "Skipping $1 install, already installed at $install_path"
		fi
}


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

# --------- Install Kitty (Preferred Terminal) -------------
mac_conditional_install "kitty" "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"

# --------- Install Brew (Package Manager) ----------
mac_conditional_install "brew" "/bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"

# add brew to path
write_once 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"

# --------- Install Neovim ---------------
mac_conditional_install nvim "brew install neovim"

# nvim package manager install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# ag for fzf quick search
mac_conditional_install "ag" "brew install the_silver_searcher"
mac_conditional_install "fzf" "brew install fzf"

# --------- Install Node, Used By Neovim ------------
mac_conditional_install "node" "brew install node"

# ------- Install Python, Set Up Neovim Env ---------
mac_conditional_install "python3.10" "brew install python@3.10"
python3.10 -m venv ~/.nvim-venv
. ~/.nvim-venv/bin/activate
python3.10 install pynvim black isort

# ---------- Install Tmux ---------------------------
mac_conditional_install "tmux" "brew install tmux"

# --------- Manual Instructions ---------------------
# Upon nvim bootup
#	:PlugInstall
# 	:CocInstall coc-json coc-tsserver coc-pyright
