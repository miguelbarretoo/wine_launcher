#!/bin/bash

# newgame.sh
# Criador de launcher Wine estilo Steam

if [ $# -lt 2 ]; then
    echo "Uso:"
    echo "./newgame.sh <pasta_do_jogo> <icone.png>"
    exit 1
fi


GAME_DIR="$(realpath "$1")"
ICON="$(realpath "$2")"

# ID baseado no nome da pasta
FOLDER_NAME=$(basename "$GAME_DIR")

GAME_ID=$(echo "$FOLDER_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_')


echo ""
echo "=============================="
echo " Novo jogo Wine"
echo "=============================="
echo ""

read -p "Nome do jogo: " GAME_NAME

if [ -z "$GAME_NAME" ]; then
    echo "Nome inválido!"
    exit 1
fi


echo ""
echo "Executáveis encontrados:"
find "$GAME_DIR" -maxdepth 1 -iname "*.exe" -printf " - %f\n"

echo ""

read -p "Nome do executável (.exe): " GAME_EXE


if [ -z "$GAME_EXE" ]; then
    echo "Executável inválido!"
    exit 1
fi


PREFIX="$HOME/Joguitos/.tools/prefix"

LAUNCHER="$GAME_DIR/run.sh"

DESKTOP="$HOME/.local/share/applications/$GAME_ID.desktop"


WINE="$HOME/Joguitos/.tools/wine/Wine-GE-latest/bin/wine"


echo ""
echo "Criando:"
echo "Nome: $GAME_NAME"
echo "ID: $GAME_ID"
echo "EXE: $GAME_EXE"
echo ""

# cria launcher
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



# cria atalho
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
echo " Jogo criado com sucesso!"
echo "================================"
echo ""
echo "🎮 $GAME_NAME"
echo "🚀 Launcher: $LAUNCHER"
