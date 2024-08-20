#! /usr/bin/env bash

PKG_NAME=$1

git clone --quiet https://github.com/tom-howard/ros2_pkg_template.git $PKG_NAME

cd $PKG_NAME 
rm -rf .git