#!/bin/bash

DOTFILE_DIR=$(dirname $(realpath $0))

make_symlink () {
	orig_path=$(realpath $1)
	dest_path=$(realpath $2)
	if [ ! -d $(dirname $dest_path) ]; then
		mkdir -p $(dirname $dest_path)
	fi
	if [[ -f $dest_path || -d $dest_path ]]; then
		echo "$dest_path already exists. Skipping symlink creation"
		return 0
	fi

	echo "Making symlink from $orig_path to $dest_path"
	ln -s $orig_path $dest_path
}

# Usage: get_latest_release "repo_name" "install_dir"
get_latest_release() {
	gh_release=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
	if [ -z $gh_release ]; then
		gh_release="master"
	fi	

	echo "Fetching release $gh_release from $1"
	if [ -d $2/$1 ]; then
		cd $2/$1
		git fetch origin
		git checkout $gh_release
	else
		if [ ! -d $2/$1 ]; then
			mkdir -p $2/$1
		fi

		git clone git@github.com:$1.git $2/$1
		cd $2/$1
		git checkout $gh_release
	fi
}

# Create symlinks to config files
for sym in $(cat $DOTFILE_DIR/symlinks.txt); do
	make_symlink $DOTFILE_DIR/$sym $HOME/$sym
done

source $HOME/.bashrc

echo "Updating packages"
sudo apt update
sudo apt upgrade

packages=$(cat $DOTFILE_DIR/packages.txt | tr -s "\n" " ")
sudo apt install $packages

if [ ! -f $HOME/.ssh/id_rsa ]; then
	ssh-keygen
fi

for repo in $(cat repos.txt); do
	get_latest_release "$repo" "$DOTFILE_DIR/code"
done
