#!/bin/bash

echo "[GMod Tool Starting...]"

# --- All possible paths (USB + common Steam) ---
POSSIBLE_PATHS=(
"/media/ubuntu/5945a0d2-a7ce-406a-a25d-20fa70dce945/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
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

# --- Require xdotool ---
if ! command -v xdotool >/dev/null 2>&1; then
    echo "[ERROR] xdotool is required. Install with: sudo apt install xdotool"
    exit 1
fi

# --- Run script in GMod ---
run_gmod() {
    xdotool search --name "Garry" windowactivate 2>/dev/null
    sleep 0.5
    xdotool key grave
    sleep 0.2
    xdotool type "lua_openscript_cl autorun/_tool.lua"
    xdotool key Return
}

# --- Stop script ---
stop_gmod() {
    xdotool key grave
    xdotool type "tool_stop"
    xdotool key Return
}

# --- Create default one-time Lua script ---
if [ ! -f "$FILE" ]; then
cat > "$FILE" << 'EOF'
if CLIENT then
    print("[TOOL] Loaded")

    local HOOK = "Tool_Main"

    -- ONE-TIME UI box
    hook.Add("InitPostEntity", "Tool_UI_Once", function()
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

        print("[TOOL] Box created on screen!")
    end)

    -- ONE-TIME Think hook (executes once)
    hook.Add("Think", HOOK, function()
        hook.Remove("Think", HOOK)
        print("[TOOL] Script executed one time")
    end)

    -- STOP command
    concommand.Add("tool_stop", function()
        hook.Remove("Think", HOOK)
        hook.Remove("InitPostEntity", "Tool_UI_Once")
        print("[TOOL] Stopped")
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
            echo "[Opening Script in nano...]"
            nano "$FILE"
        ;;

        2)
            echo "[Starting Script...]"
            stop_gmod
            sleep 0.3
            run_gmod
        ;;

        3)
            echo "[Stopping Script...]"
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
