# --------- TODO: this stuff is duplicated with the main setup.sh --------------
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
IS_LINUX=$(uname -s | grep -q "Linux" && echo 1 || echo 0)

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

# ------------- Begin New Content -----------------------

if [[ $IS_LINUX -eq 1 ]]; then
		mkdir -p "$XDG_DATA_HOME/pip"
		ln -s "$SCRIPT_DIR/pip.conf" "$XDG_DATA_HOME/pip/pip.conf"
fi

# ------------- XPK Set-Up for MaxText ------------------
linux_conditional_install "kubectl" "sudo snap install kubectl --classic"

# Not sure how to make this part conditional because it's installing `auth` under gcloud, not gcloud itself
# these steps stolen directly from https://github.com/google/maxtext/blob/fac91938e2f23670ced1f6569557927d31185c9e/getting_started/Run_MaxText_via_xpk.md
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt update && sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

gcloud auth login -y
gcloud auth configure-docker -y
sudo usermod -aG docker $USER

export PROJECT_ID=tpu-prod-env-multipod
export ZONE=us-central2-b # for v5e us-west4-a
export CLUSTER_NAME=v4-bodaborg # or v5e-bodaborg
gcloud config set project tpu-prod-env-multipod


pip install xpk
