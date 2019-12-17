#!/bin/bash

DOTFILE_DIR=$(dirname $(realpath $0))

make_symlink () {
	orig_path=$(realpath $1)
	dest_path=$(realpath $2)
	echo "Making symlink from $orig_path to $dest_path"
	ln -s $orig_path $dest_path
}

make_symlink $DOTFILE_DIR/.ssh/config $HOME/.ssh/config
