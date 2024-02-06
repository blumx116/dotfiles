# --------- Install Brew (Package Manager) ----------
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# add brew to path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/carterblum/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"
