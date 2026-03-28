#!/bin/bash

echo "[GMod Tool Starting...]"

# --- ALL POSSIBLE PATHS (including your USB) ---
POSSIBLE_PATHS=(
"/media/ubuntu/5945a0d2-a7ce-406a-a25d-20fa70dce945/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"/media/$USER/5945a0d2-a7ce-406a-a25d-20fa70dce945/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"/media/$USER/*/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"/run/media/$USER/*/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"$HOME/.steam/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"$HOME/.local/share/Steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
)

GMOD_LUA=""

# --- Find valid path ---
for path in "${POSSIBLE_PATHS[@]}"; do
    for real in $path; do
        if [ -d "$real" ]; then
            GMOD_LUA="$real"
            break 2
        fi
    done
done

if [ -z "$GMOD_LUA" ]; then
    echo "[ERROR] Could not find GMod lua folder"
    exit 1
fi

echo "[OK] Using: $GMOD_LUA"

FILE="$GMOD_LUA/_tool.lua"
mkdir -p "$GMOD_LUA"

# --- Detect running game ---
PID=$(pgrep -f "hl2|gmod|Garry")

if [ -z "$PID" ]; then
    echo "[WARNING] Could not detect GMod (continuing anyway)"
else
    echo "[OK] GMod running (PID: $PID)"
fi

# --- Run script ---
run_gmod() {
    if command -v xdotool >/dev/null 2>&1; then
        xdotool search --name "Garry" windowactivate 2>/dev/null
        sleep 0.3
        xdotool key grave
        sleep 0.2
        xdotool type "lua_openscript_cl autorun/_tool.lua"
        xdotool key Return
    else
        echo "[!] Run in console:"
        echo "lua_openscript_cl autorun/_tool.lua"
    fi
}

# --- Stop script ---
stop_gmod() {
    if command -v xdotool >/dev/null 2>&1; then
        xdotool key grave
        xdotool type "tool_stop"
        xdotool key Return
    else
        echo "Run in console: tool_stop"
    fi
}

# --- Create base Lua file if missing ---
if [ ! -f "$FILE" ]; then
cat > "$FILE" << 'EOF'
if CLIENT then
    print("[TOOL] Loaded")

    local HOOK = "Tool_Main"

    hook.Remove("Think", HOOK)

    hook.Add("Think", HOOK, function()
        -- WRITE YOUR CODE HERE
    end)

    concommand.Add("tool_stop", function()
        hook.Remove("Think", HOOK)
        print("[TOOL] Stopped")
    end)

    hook.Add("InitPostEntity", "Tool_UI", function()
        local f = vgui.Create("DFrame")
        f:SetSize(200,100)
        f:SetPos(50,50)
        f:SetTitle("Lua Tool")
        f:MakePopup()

        local b = vgui.Create("DButton", f)
        b:SetSize(160,40)
        b:SetPos(20,40)
        b:SetText("STOP SCRIPT")

        b.DoClick = function()
            RunConsoleCommand("tool_stop")
        end
    end)
end
EOF
fi

# --- Menu ---
while true; do
    echo ""
    echo "====== GMOD LUA TOOL ======"
    echo "1) Script"
    echo "2) START Script"
    echo "3) STOP Script"
    echo "4) Exit"
    echo "==========================="
    read -p "Select> " CHOICE

    case $CHOICE in

        1)
            echo "[Opening script in nano...]"
            nano "$FILE"
        ;;

        2)
            echo "[Starting script...]"
            stop_gmod
            sleep 0.3
            run_gmod
        ;;

        3)
            echo "[Stopping script...]"
            stop_gmod
        ;;

        4)
            echo "[Exiting]"
            exit 0
        ;;

        *)
            echo "[!] Invalid option"
        ;;

    esac
done
