#!/bin/bash

echo "[GMod Tool Starting...]"

# --- PATHS ---
POSSIBLE_PATHS=(
"/media/ubuntu/5945a0d2-a7ce-406a-a25d-20fa70dce945/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"/media/$USER/*/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"/run/media/$USER/*/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"$HOME/.steam/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
"$HOME/.local/share/Steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
)

GMOD_LUA=""

for path in "${POSSIBLE_PATHS[@]}"; do
    for real in $path; do
        if [ -d "$real" ]; then
            GMOD_LUA="$real"
            break 2
        fi
    done
done

if [ -z "$GMOD_LUA" ]; then
    echo "[ERROR] GMod path not found"
    exit 1
fi

echo "[OK] Using: $GMOD_LUA"

FILE="$GMOD_LUA/_tool.lua"

# --- REQUIRE xdotool ---
if ! command -v xdotool >/dev/null 2>&1; then
    echo "[ERROR] xdotool is REQUIRED"
    echo "Install it with: sudo apt install xdotool"
    exit 1
fi

# --- Run script ---
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

# --- FORCE TEST SCRIPT (so we know it works) ---
cat > "$FILE" << 'EOF'
if CLIENT then
    print("[TOOL] SCRIPT RAN")

    local HOOK = "Tool_Test"
    hook.Remove("Think", HOOK)

    hook.Add("Think", HOOK, function()
        if math.random() > 0.999 then
            print("[TOOL] Running...")
        end
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
        b:SetText("STOP")

        b.DoClick = function()
            RunConsoleCommand("tool_stop")
        end
    end)
end
EOF

echo "[INFO] Test script written"

# --- Menu ---
while true; do
    echo ""
    echo "1) Script"
    echo "2) START"
    echo "3) STOP"
    echo "4) Exit"
    read -p "Select> " CHOICE

    case $CHOICE in

        1)
            nano "$FILE"
        ;;

        2)
            stop_gmod
            sleep 0.3
            run_gmod
        ;;

        3)
            stop_gmod
        ;;

        4)
            exit 0
        ;;

    esac
done
