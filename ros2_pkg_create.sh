#! /usr/bin/env bash

ask() {
    local reply prompt
    prompt='y/n'
    echo -e -n "[INPUT] $1 [$prompt] >> "
    read -r reply </dev/tty
    if [[ -z $reply ]]; then
        return 1;
    elif [ "$reply" == "y" ] || [ "$reply" == "Y" ]; then
        return 0;
    else
        return 1;
    fi
}

# PKG_NAME=$1

# git clone --quiet https://github.com/tom-howard/ros2_pkg_template.git $PKG_NAME

# cd $PKG_NAME 
# rm -rf .git

if [ -z "$COLCON_PREFIX_PATH" ]; then
    echo "[EXITING] No ROS2 Workspaces detected."
    exit 0
fi

ROS2_WS=""
for path in ${COLCON_PREFIX_PATH//:/ }; do
    targetdir="$(dirname "$path")/src"
    echo "ROS2 Workspace detected at: '$targetdir'."
    if ask "Do you want to create your package here?"; then
        ROS2_WS=$targetdir
        break
    else
        continue
    fi
done

if [ -z "$ROS2_WS" ]; then
    echo "[EXITING] No path selected."
    exit 0    
fi

echo -n "[INPUT] Please enter a name for your package >>> "
read -r PKG_NAME </dev/tty

if [ -z "$PKG_NAME" ]; then
    echo "[EXITING] No package name provided."
    exit 0
fi

PKG_PATH="$ROS2_WS/$PKG_NAME"

if [ -d "$PKG_PATH"]; then
    echo "[WARNING] The '$PKG_NAME' ROS package (or a directory of the same name) already exists!"
    if ask "Do you want to replace it?"; then
        echo "Removing the existing directory:"
        echo "  $PKG_PATH"
        rm -rf $PKG_PATH
    else
        echo "[EXITING] Start again with a new package name, or remove the existing one."
        exit 0
    fi
fi

echo "Creating the '$PKG_NAME' package at:"
echo "  $PKG_PATH"

