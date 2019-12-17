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

# Create symlinks to config files
make_symlink $DOTFILE_DIR/.ssh/config $HOME/.ssh/config
make_symlink $DOTFILE_DIR/.config/sway $HOME/.config/sway
