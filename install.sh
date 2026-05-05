#!/bin/sh
# Install the picker by symlinking it onto PATH.
#
# Default target is $HOME/.local/bin. Override with PREFIX:
#     PREFIX=/usr/local/bin sudo ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/picker"
TARGET_DIR="${PREFIX:-$HOME/.local/bin}"
TARGET="$TARGET_DIR/picker"

if [ ! -f "$SOURCE" ]; then
    echo "Error: $SOURCE not found." >&2
    exit 1
fi

chmod +x "$SOURCE"
mkdir -p "$TARGET_DIR"

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    current_target=$(readlink "$TARGET" 2>/dev/null || echo "")
    if [ "$current_target" = "$SOURCE" ]; then
        echo "Already installed: $TARGET -> $SOURCE"
    else
        printf "%s already exists. Overwrite? [y/N] " "$TARGET"
        read -r ans
        case "$ans" in
            y|Y|yes|YES)
                rm -f "$TARGET"
                ln -s "$SOURCE" "$TARGET"
                echo "Installed: $TARGET -> $SOURCE"
                ;;
            *)
                echo "Aborted."
                exit 1
                ;;
        esac
    fi
else
    ln -s "$SOURCE" "$TARGET"
    echo "Installed: $TARGET -> $SOURCE"
fi

case ":$PATH:" in
    *":$TARGET_DIR:"*)
        echo "Ready: try 'picker --help'"
        ;;
    *)
        echo
        echo "Note: $TARGET_DIR is not on your PATH."
        echo "Add this to your shell rc (e.g. ~/.bashrc):"
        echo "    export PATH=\"\$PATH:$TARGET_DIR\""
        ;;
esac
