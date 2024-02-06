# ---------- Simple Utilities ---------------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/shared.sh

# ---------- Simple Utilities ---------------
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

# ---------- Install Tmux ---------------------------
mac_conditional_install "tmux" "brew install tmux"

source $SCRIPT_DIR/shared-post.sh
