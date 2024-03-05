# --------- TODO: this stuff is duplicated with the main setup.sh --------------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
IS_LINUX=$(uname -s | grep -q "Linux" && echo 1 || echo 0)

if [[ $IS_LINUX -eq 1 ]]; then
		mkdir -p "$XDG_DATA_HOME/pip"
		ln -s "$SCRIPT_DIR/pip.conf" "$XDG_DATA_HOME/pip/pip.conf"
fi
