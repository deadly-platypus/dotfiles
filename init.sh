#!/bin/bash

DOTFILE_DIR=$(dirname $(realpath $0))
PACKAGE_INSTALL_CMD="pamac install"
PACKAGE_UPDATE_CMD="pamac update -a"

# Usage: exit_fail "Something happened" 1
exit_fail() {
	echo $1
	exit $2
}

# Usage: run_cmd "cmd" 
run_cmd() {
	eval "$*" || exit_fail "Failed command: $*" 1
}

# Usage: make_symlink "original_path" "destination_path"
make_symlink () {
	orig_path=$(realpath $1)
	dest_path=$(realpath $2)
	if [ ! -d $(dirname $dest_path) ]; then
		run_cmd mkdir -p $(dirname $dest_path)
	fi
	if [[ -f $dest_path || -d $dest_path ]]; then
		echo "$dest_path already exists. Skipping symlink creation"
		return 0
	fi

	echo "Making symlink from $orig_path to $dest_path"
	run_cmd ln -s $orig_path $dest_path
}

# Usage: get_latest_release "repo_name" "install_dir"
get_latest_release() {
	gh_release=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
	if [ -z $gh_release ]; then
		gh_release="master"
	fi	

	echo "Fetching release $gh_release from $1"
	if [ -d $2/$1 ]; then
		run_cmd cd $2/$1
		run_cmd git fetch origin
		run_cmd git checkout $gh_release
	else
		if [ ! -d $2/$1 ]; then
			run_cmd mkdir -p $2/$1
		fi

		run_cmd git clone git@github.com:$1.git $2/$1
		run_cmd cd $2/$1
		run_cmd git checkout $gh_release
	fi
}

# Create symlinks to config files
# symlinks.txt should have one path per line
for sym in $(cat $DOTFILE_DIR/symlinks.txt); do
	make_symlink $DOTFILE_DIR/$sym $HOME/$sym
done

echo "Updating packages"
run_cmd sudo $PACKAGE_UPDATE_CMD

# packages.txt should have one package per line
packages=$(cat $DOTFILE_DIR/packages.txt | tr -s "\n" " ")
run_cmd sudo $PACKAGE_INSTALL_CMD $packages

if [ ! -f $HOME/.ssh/id_rsa ]; then
	run_cmd ssh-keygen
fi

clear
echo "System successfully set up!"
