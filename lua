#!/bin/bash

echo "[GMod Tool Starting...]"

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
    echo "[ERROR] Could not find GMod folder"
    exit 1
fi

FILE="$GMOD_LUA/_tool.lua"
mkdir -p "$GMOD_LUA"

# --- Better detection (works for more setups) ---
PID=$(pgrep -f "hl2|gmod|Garry")

if [ -z "$PID" ]; then
    echo "[WARNING] Could not confirm GMod running"
    echo "[INFO] You can still continue"
else
    echo "[OK] GMod detected (PID: $PID)"
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

# --- Menu ---
while true; do
    echo ""
    echo "====== GMOD TOOL ======"
    echo "1) Nano Editor"
    echo "2) Number Tool"
    echo "3) START Script"
    echo "4) STOP Script"
    echo "5) Exit"
    echo "======================="
    read -p "Select> " CHOICE

    case $CHOICE in

        1)
            nano "$FILE"
        ;;

        2)
            read -p "Enter number (e.g. 300): " VAL

            if ! [[ "$VAL" =~ ^[0-9]+$ ]]; then
                echo "[!] Invalid number"
                continue
            fi

cat > "$FILE" << EOF
if CLIENT then
    print("[NUMBER TOOL] $VAL")

    local HOOK = "Tool_Num"
    hook.Remove("Think", HOOK)

    hook.Add("Think", HOOK, function()
        local ply = LocalPlayer()
        if IsValid(ply) then
            ply:SetWalkSpeed($VAL)
            ply:SetRunSpeed($((VAL*2)))
            ply:SetJumpPower($((VAL/2)))
        end
    end)

    concommand.Add("tool_stop", function()
        hook.Remove("Think", HOOK)
        print("[STOPPED]")
    end)
end
EOF

            run_gmod
        ;;

        3)
            stop_gmod
            sleep 0.3
            run_gmod
        ;;

        4)
            stop_gmod
        ;;

        5)
            exit 0
        ;;

        *)
            echo "Invalid option"
        ;;

    esac
done
