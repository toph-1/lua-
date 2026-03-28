#!/bin/bash

echo "[GMod Nano Tool Starting...]"

# --- Find GMod path ---
POSSIBLE_PATHS=(
"$HOME/.steam/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"$HOME/.local/share/Steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
)

GMOD_LUA=""
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then
        GMOD_LUA="$path"
        break
    fi
done

if [ -z "$GMOD_LUA" ]; then
    echo "[ERROR] Could not find GMod install"
    exit 1
fi

FILE="$GMOD_LUA/_tool.lua"
mkdir -p "$GMOD_LUA"

# --- Check if GMod running ---
PID=$(pgrep -f "hl2_linux")

if [ -z "$PID" ]; then
    echo "[ERROR] Garry's Mod is not running"
    exit 1
fi

echo "[OK] GMod detected"

# --- Run script in GMod ---
run_gmod() {
    if command -v xdotool >/dev/null 2>&1; then
        xdotool search --name "Garry's Mod" windowactivate 2>/dev/null
        sleep 0.3
        xdotool key grave
        sleep 0.2
        xdotool type "lua_openscript_cl autorun/_tool.lua"
        xdotool key Return
    else
        echo "[!] Run in GMod console:"
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

# --- Create Lua file if missing ---
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
    echo "1) Edit Lua Script (nano)"
    echo "2) START Script"
    echo "3) STOP Script"
    echo "4) Exit"
    echo "==========================="
    read -p "Select> " CHOICE

    case $CHOICE in

        1)
            echo "[Opening nano...]"
            nano "$FILE"
            echo "[Saved]"
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
