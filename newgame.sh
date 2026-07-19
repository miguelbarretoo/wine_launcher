#!/bin/bash
# newgame.sh
# Steam-style Wine launcher creator
if [ $# -lt 2 ]; then
    echo "Usage:"
    echo "./newgame.sh <game_folder> <icon.png>"
    exit 1
fi
GAME_DIR="$(realpath "$1")"
ICON="$(realpath "$2")"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# ID based on the folder name
FOLDER_NAME=$(basename "$GAME_DIR")
GAME_ID=$(echo "$FOLDER_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_')
echo ""
echo "=============================="
echo " New Wine game"
echo "=============================="
echo ""
read -p "Game name: " GAME_NAME
if [ -z "$GAME_NAME" ]; then
    echo "Invalid name!"
    exit 1
fi
echo ""
echo "Executables found:"
find "$GAME_DIR" -maxdepth 1 -iname "*.exe" -printf " - %f\n"
echo ""
read -p "Executable name (.exe): " GAME_EXE
if [ -z "$GAME_EXE" ]; then
    echo "Invalid executable!"
    exit 1
fi
PREFIX="$SCRIPT_DIR/.tools/prefix"
LAUNCHER="$GAME_DIR/run.sh"
DESKTOP="$HOME/.local/share/applications/$GAME_ID.desktop"
WINE="$SCRIPT_DIR/.tools/wine/Wine-GE-latest/bin/wine"
echo ""
echo "Creating:"
echo "Name: $GAME_NAME"
echo "ID: $GAME_ID"
echo "EXE: $GAME_EXE"
echo ""
# first run: create the prefix if it doesn't exist yet
if [ ! -d "$PREFIX" ]; then
    echo "Prefix not found, creating a new one at:"
    echo "$PREFIX"
    mkdir -p "$PREFIX"
    WINEPREFIX="$PREFIX" "$WINE" wineboot --init
    echo "Prefix created."
    echo ""
fi
# create launcher
cat > "$LAUNCHER" <<EOF
#!/bin/bash
GAME_DIR="$GAME_DIR"
cd "\$GAME_DIR" || exit 1
gamemoderun env \\
WINEDLLOVERRIDES="d3d11,dxgi=n" \\
WINEPREFIX="$PREFIX" \\
"$WINE" "$GAME_EXE"
EOF
chmod +x "$LAUNCHER"
# create shortcut
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Name=$GAME_NAME
Comment=$GAME_NAME Launcher
Exec=$LAUNCHER
Icon=$ICON
Terminal=false
Type=Application
Categories=Game;
StartupNotify=true
EOF
chmod +x "$DESKTOP"
update-desktop-database ~/.local/share/applications 2>/dev/null
echo ""
echo "================================"
echo " Game created successfully!"
echo "================================"
echo ""
echo "🎮 $GAME_NAME"
echo "🚀 Launcher: $LAUNCHER"
