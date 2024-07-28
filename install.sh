#!/bin/bash

set -e

NVIM_BINARY_ARCHIVE="nvim-linux64.tar.gz"
NVIM_PLUGINS_ARCHIVE="local-share-nvim.tar.gz"
NVIM_CONFIG_FILE="init.lua"
PYTHON_DEPS_ARCHIVE="python_dependencies.tar.gz"
FZF_ARCHIVE="fzf-0.54.2-linux_amd64.tar.gz"

NVIM_INSTALL_DIR="$HOME/.local/nvim"
NVIM_BIN_DIR="$HOME/.local/bin"
NVIM_LIB_DIR="$HOME/.local/lib"
NVIM_SHARE_DIR="$HOME/.local/share/nvim"

mkdir -p $NVIM_INSTALL_DIR $NVIM_BIN_DIR $NVIM_LIB_DIR $NVIM_SHARE_DIR

echo "Installing Neovim..."
tar xzf $NVIM_BINARY_ARCHIVE
mv nvim-linux64/bin/nvim $NVIM_BIN_DIR/
mv nvim-linux64/lib/nvim $NVIM_LIB_DIR/
mv nvim-linux64/share/nvim/* $NVIM_SHARE_DIR/

export PATH=$NVIM_BIN_DIR:$PATH
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc

echo "Setting up Neovim configuration..."
mkdir -p ~/.config/nvim
cp $NVIM_CONFIG_FILE ~/.config/nvim/

echo "Setting up Neovim plugins..."
mkdir -p ~/.local/share/nvim/
tar xzf $NVIM_PLUGINS_ARCHIVE -C ~/.local/share/nvim/

echo "Installing Python dependencies..."
mkdir -p ~/python_dependencies
tar xzf $PYTHON_DEPS_ARCHIVE -C /tmp/python_dependencies
pip install /tmp/python_dependencies/*.whl

echo "Installing fzf..."
tar xzf $FZF_ARCHIVE
mv fzf $NVIM_BIN_DIR/

echo "Configuring fzf..."
echo 'export FZF_DEFAULT_COMMAND="find ."' >> ~/.bashrc
echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.bashrc


echo "Reloading shell configuration..."
source ~/.bashrc || true

echo "Setup completed successfully!"

