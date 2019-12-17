#!/bin/bash

DOTFILE_DIR=$(dirname $(realpath $0))

make_symlink () {
	orig_path=$(realpath $1)
	dest_path=$(realpath $2)
	if [ ! -d $(dirname $dest_path) ]; then
		mkdir -p $(dirname $dest_path)
	fi

	echo "Making symlink from $orig_path to $dest_path"
	ln -s $orig_path $dest_path
}

# Create symlinks to config files
make_symlink $DOTFILE_DIR/.ssh/config $HOME/.ssh/config
