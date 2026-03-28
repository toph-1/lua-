#!/bin/bash

GMOD_LUA="$HOME/.steam/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
FILE="$GMOD_LUA/_nano_exec.lua"

mkdir -p "$GMOD_LUA"

# Check if GMod is running
PID=$(pgrep -f "hl2_linux.*garrysmod")

if [ -z "$PID" ]; then
    echo "[!] Garry's Mod is not running."
    echo "Start singleplayer first."
    exit 1
fi

echo "[+] GMod detected (PID: $PID)"

# Create base file if missing
if [ ! -f "$FILE" ]; then
cat > "$FILE" << 'EOF'
if CLIENT then
    print("[NANO EXEC] Loaded")

    local HOOK_NAME = "NanoExec_Main"

    -- Example code (edit this in nano)
    hook.Add("Think", HOOK_NAME, function()
        local ply = LocalPlayer()
        if IsValid(ply) then
            ply:SetWalkSpeed(400)
        end
    end)

    -- STOP command
    concommand.Add("nano_stop", function()
        hook.Remove("Think", HOOK_NAME)
        print("[NANO EXEC] Stopped script")
    end)

    -- STOP button UI
    hook.Add("InitPostEntity", "NanoExec_UI", function()
        local frame = vgui.Create("DFrame")
        frame:SetSize(200, 100)
        frame:SetPos(50, 50)
        frame:SetTitle("Nano Control")
        frame:MakePopup()

        local btn = vgui.Create("DButton", frame)
        btn:SetSize(160, 40)
        btn:SetPos(20, 40)
        btn:SetText("STOP SCRIPT")

        btn.DoClick = function()
            RunConsoleCommand("nano_stop")
        end
    end)
end
EOF
fi

# Open nano editor
nano "$FILE"

echo "[+] Saved. Executing in GMod..."

# Run script in GMod
if command -v xdotool >/dev/null 2>&1; then
    xdotool key grave
    xdotool type "lua_openscript_cl autorun/_nano_exec.lua"
    xdotool key Return
else
    echo "[!] Run this in GMod console:"
    echo "lua_openscript_cl autorun/_nano_exec.lua"
fi

echo "[+] Done!"
