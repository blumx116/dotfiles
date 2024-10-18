#!/bin/bash
set -o errexit # exit on error
set -o nounset # exit on access undefined variable


# ------- if DEBUG variable is set, print each command -----
if [[ -n "${DEBUG-}" ]]; then 
	set -o xtrace
fi

cleanup() {
		set +o errexit
		set +o nounset
		set +o xtrace
}

trap cleanup EXIT

# ---------- Simple Utilities ---------------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
IS_MACOS=$(uname -s | grep -q "Darwin" && echo 1 || echo 0)
IS_LINUX=$(uname -s | grep -q "Linux" && echo 1 || echo 0)

# --------- Symlink Configuration Files To Git Repo ---------------
if [[ -z "${XDG_DATA_HOME-}" ]]; then
		echo "XDG_DATA_HOME not set, setting to $HOME/.config"
		XDG_DATA_HOME="$HOME"/.config
		export XDG_DATA_HOME="$XDG_DATA_HOME"
		mkdir -p "$XDG_DATA_HOME"
fi


ln -sf "$SCRIPT_DIR"/.cfg.sh ~/.cfg.sh
mkdir -p "$XDG_DATA_HOME"/nvim
ln -sf "$SCRIPT_DIR"/init.vim "$XDG_DATA_HOME"/nvim/init.vim
ln -sf "$SCRIPT_DIR"/UltiSnips "$XDG_DATA_HOME"/nvim/UltiSnips
mkdir -p "$XDG_DATA_HOME"/kitty
ln -sf "$SCRIPT_DIR"/kitty.conf "$XDG_DATA_HOME"/kitty/kitty.conf
ln -sf "$SCRIPT_DIR"/.gitconfig "$HOME"/.gitconfig
ln -sf "$SCRIPT_DIR"/.tmux.conf "$HOME"/.tmux.conf

#-----------Make Sure Apt Up To Date if Available--------
if [[ $IS_LINUX -eq 1 ]]; then
		sudo apt update
fi

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
    read -r input_path

    if [ -n "$input_path" ]; then
        expanded_path=$(eval echo "$input_path")
        echo "export PROJECTS_HOME=\"$expanded_path\"" >> ~/.bash_profile
        mkdir -p "$expanded_path"
    else
        echo "No path received, exiting"
        exit
    fi
fi

touch ~/.zshrc
touch ~/.bashrc
touch ~/.prof.sh
touch ~/.cfg.sh
write_once "source ~/.cfg.sh" "$HOME"/.bash_profile		#~/.cfg.sh is shared configuration from github
write_once "source ~/.prof.sh" "$HOME"/.bash_profile		#~/.prof.sh is machine-specific configuration (possibly from github)e
write_once "source ~/.bash_profile" "$HOME"/.bashrc		#~/.bashrc is bash-specific, may be written by env
write_once "source ~/.bash_profile" "$HOME"/.zshrc 		#~/.zshrc is zsh-specific, may be written by env
# ~/.bash_profile may be written by env, is the 'one' file that will always be sourced but not owned by me
source "$HOME"/.bash_profile

# ---------- Simple Utilities ---------------
conditional_install() {
		# this complicated thing runs which in a subshell to avoid errexit
		install_path=$(which "$1" 2>/dev/null || echo "") 

		if [[ -z "$install_path" || "$install_path" == *"not found"* ]]; then
				sh -c "$2"
		else 
				echo "Skipping $1 install, already installed at $install_path"
		fi
}

mac_conditional_install () {
		# argument 1 is the utility name, we'll use 'which' to check if it's installed
		# argument 2 is the command to run to install the script
		if [[ $IS_MACOS -eq 1 ]]; then 
				conditional_install "$@"
		fi
}

linux_conditional_install () {
		# argument 1 is the utility name, we'll use 'which' to check if it's installed
		# argument 2 is the command to run to install the script
		if [[ $IS_LINUX -eq 1 ]]; then 
				conditional_install "$@"
		fi
}


# --------- Install Kitty (Preferred Terminal) -------------
mac_conditional_install "kitty" "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"

# --------- Install Brew (Package Manager) ----------
mac_conditional_install "brew" "/bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"

# add brew to path
if [[ $IS_MACOS -eq 1 ]]; then
	write_once 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --------- Install Neovim ---------------
mac_conditional_install nvim "brew install neovim"

if [[ $IS_LINUX -eq 1 ]]; then
		chmod +x "$SCRIPT_DIR"/nvim.appimage
		write_once "alias nvim=$SCRIPT_DIR/nvim.appimage" ~/.bash_profile
fi


# nvim package manager install
if [[ ! -e "$XDG_DATA_HOME"/nvim/site/autoload/plug.vim ]]; then
	sh -c 'curl -fLo "$XDG_DATA_HOME"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi
# ag for fzf quick search
mac_conditional_install "ag" "brew install the_silver_searcher"
mac_conditional_install "fzf" "brew install fzf"
linux_conditional_install "ag" "sudo apt install silversearcher-ag"
linux_conditional_install "fzf" "sudo apt install fzf"

# --------- Install Node, Used By Neovim ------------
mac_conditional_install "node" "brew install node"
linux_conditional_install "node" "curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash - && sudo apt-get install nodejs npm"
sudo npm install -g npm

# ---------- Install shellcheck -------------------
mac_conditional_install "shellcheck" "brew install shellcheck"
linux_conditional_install "shellcheck" "sudo apt install shellcheck"

# ---------- Install Tmux ---------------------------
mac_conditional_install "tmux" "brew install tmux"


# ------- Install Python, Set Up Neovim Env ---------
echo "Select the version of python to be used. Alternately, just hit enter to install python3.11 and use that."
read -r PYTHON_CHOICE

if [[ "$PYTHON_CHOICE" == "" ]]; then
		mac_conditional_install "python3.11" "brew install python@3.11"
		linux_conditional_install "python3.11" "sudo add-apt-repository -y ppa:deadsnakes/ppa && sudo apt install -y python3.11-venv"
		PYTHON_VERSION="python3.11"
else
		PYTHON_VERSION=$PYTHON_CHOICE
fi

echo "export DEFAULT_PYTHON=$PYTHON_VERSION" >> ~/.prof.sh
export DEFAULT_PYTHON="$PYTHON_CHOICE"


# ---------- Set Up Neovim Env ----------------------
$DEFAULT_PYTHON -m venv ~/.nvim-venv
. ~/.nvim-venv/bin/activate && $DEFAULT_PYTHON -m pip install pynvim black isort neovim
shopt -s expand_aliases
source ~/.bash_profile

linux_conditional_install "libfuse" "sudo apt-get install -y fuse libfuse2"

v +PlugInstall +qall
v -c "CocInstall coc-json coc-tsserver coc-pyright coc-sh"
v +UpdateRemotePlugins +qall

cleanup
