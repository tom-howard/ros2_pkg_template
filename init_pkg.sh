#! /usr/bin/env bash

ask() {
    local reply

    echo -e -n "[INPUT] $1 [y/n] >> "
    read -r reply </dev/tty
    if [[ -z $reply ]]; then
        return 1;
    elif [ "$reply" == "y" ] || [ "$reply" == "Y" ]; then
        return 0;
    else
        return 1;
    fi
}

SCRIPT_NAME="$(readlink -f "$0")"
PKG_PATH="$(dirname "${SCRIPT_NAME}")"

echo "[DBG] Package path: ${PKG_PATH}"

cd ${PKG_PATH}
echo "[DBG] Current (PKG) directory: $(pwd)"

if ! $(git status >/dev/null 2>&1); then
    echo "[ERROR] Not a git repository..."
    exit 255
fi

GIT_REMOTE_URL=$(git config --get remote.origin.url)
if [[ "${GIT_REMOTE_URL}" == "https://github.com/tom-howard/ros2_pkg_template.git" ]]; then
    echo "[DBG] this is the package template"
    PKG_NAME=$1
    FROM_TEMPLATE=True
else
    echo "[DBG] this is not the package template, its a fork."
    PKG_NAME=$(basename "${GIT_REMOTE_URL}" ".git")
    FROM_TEMPLATE=False
fi

echo "[DBG] Package name: ${PKG_NAME}"

if [[ -z "${PKG_NAME}" ]]; then
    echo "[DBG] Package name is empty."
    echo -n "[INPUT] Please enter a name for your package >> "
    read -r ${PKG_NAME} </dev/tty
fi

echo "[DBG] Package name: ${PKG_NAME}"

if [[ ! "${PKG_NAME}" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "[ERROR] Invalid package name: '${PKG_NAME}'."
    echo "Package names must start with a lowercase letter, and can only contain lowercase letters, numbers, and underscores."
    exit 255
else
    echo "[DBG] Package name OK"
fi

if [ -z "$COLCON_PREFIX_PATH" ]; then
    echo "[EXITING] No ROS2 Workspaces detected."
    exit 0
fi

IFS=':' read -r -a COLCON_WS <<< "$COLCON_PREFIX_PATH"

PKG_PATH_IN_WS=false
for ws in "${COLCON_WS[@]}"; do
    if [[ "${PKG_PATH}" == "$(dirname "${ws}")/src"* ]]; then
        PKG_PATH_IN_WS=true
        echo "[DBG] PKG_PATH is inside workspace: $(dirname "${ws}")/src"
        break
    fi
done

if [[ "${PKG_PATH_IN_WS}" == "true" ]]; then
    echo "[DBG] PKG_PATH is inside a ROS2 workspace."
else
    if ! ask "This package doesn't appear to be inside a ROS2 workspace. Are you sure you want to continue?"; then
        echo "[DBG] Not in a WS, don't continue."
        exit 255
    fi
    echo "[DBG] PKG_PATH is NOT inside any ROS2 workspace, proceeding anyway."
fi

if ! ask "Initialise this ROS package with the name '${PKG_NAME}'?"; then
    echo "Exiting."
    exit 255
fi

echo "Initialising the '${PKG_NAME}' package..."

if [[ "${FROM_TEMPLATE}" == "True" ]]; then
    echo "[DBG] Renaming package location to '${PKG_NAME}'"
    NEW_PKG_PATH="$(dirname "${PKG_PATH}")/${PKG_NAME}"
    echo "[DBG] New package location: ${NEW_PKG_PATH}"
    if [ -d "${NEW_PKG_PATH}" ]; then
        echo "[ERROR] The '${PKG_NAME}' ROS package (or a directory of the same name) already exists!"
        exit 255
    fi
fi

rm -f init_pkg.sh

TEMPLATE_NAME=ros2_pkg_template
mv ${TEMPLATE_NAME}_modules/ ${PKG_NAME}_modules/
mv include/${TEMPLATE_NAME}/ include/${PKG_NAME}/
sed -i '/<name>/s/'${TEMPLATE_NAME}'/'${PKG_NAME}'/' package.xml
sed -i '2 s/'${TEMPLATE_NAME}'/'${PKG_NAME}'/' CMakeLists.txt

if [[ "${FROM_TEMPLATE}" == "True" ]]; then
    rm -rf .git*
    cd $(dirname "${PKG_PATH}")
    mv "${PKG_PATH}" "${NEW_PKG_PATH}"
fi 

echo "Done."
