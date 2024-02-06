SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --------- Install Brew (Package Manager) ----------
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# add brew to path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/carterblum/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"

# --------- Install Neovim ---------------
brew install neovim

# --------- Symlink Configuration Files To Git Repo ---------------
ln -s $SCRIPT_DIR/.cfg.sh ~/.cfg.sh
ln -s $SCRIPT_DIR/init.vim $XDG_DATA_HOME/nvim/init.vim

# --------- Make Sure That RC Files All Source Each Other-----
(echo; echo 'source ~/.cfg.sh') >> ~/.bash_profile              #~/.cfg.sh is shared configuration from github
(echo; echo 'source ~/.prof.sh') >> ~/.bash_profile             #~/.prof.sh is machine-specific configuration (possibly from github)
(echo; echo 'source ~/.bash_profile') >> ~/.bashrc              #~/.bashrc is bash-specific, may be written by env
(echo; echo 'source ~/.bash_profile') >> ~/.zshrc               #~/.zshrc is zsh-specific, may be written by env
# ~/.bash_profile may be written by env, is the 'one' file that will always be sourced but not owned by me
