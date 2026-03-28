#!/bin/bash

# Path to GMod lua autorun
GMOD_LUA="$HOME/.steam/steam/steamapps/common/GarrysMod/garrysmod/lua/autorun"
FILE="$GMOD_LUA/dev_tool.lua"

# Check if GMod is running
GMOD_PID=$(pgrep -f "hl2_linux.*garrysmod")

if [ -z "$GMOD_PID" ]; then
    echo "[!] Garry's Mod is not running. Please start singleplayer first."
    exit 1
else
    echo "[+] Detected GMod running (PID: $GMOD_PID)"
fi

# Make sure autorun folder exists
mkdir -p "$GMOD_LUA"

# Write the Lua dev tool
cat > "$FILE" << 'EOF'
if CLIENT then
    print("[DEV CONSOLE] Loaded!")

    local Dev = { frame = nil, value = 200 }

    local function OpenDevMenu()
        if IsValid(Dev.frame) then Dev.frame:Remove() end

        Dev.frame = vgui.Create("DFrame")
        Dev.frame:SetSize(400, 300)
        Dev.frame:Center()
        Dev.frame:SetTitle("Dev Console")
        Dev.frame:MakePopup()

        local valueLabel = vgui.Create("DLabel", Dev.frame)
        valueLabel:SetPos(20, 40)
        valueLabel:SetText("Value: " .. Dev.value)

        local slider = vgui.Create("DNumSlider", Dev.frame)
        slider:SetPos(20, 70)
        slider:SetSize(360, 40)
        slider:SetText("Set Value")
        slider:SetMin(0)
        slider:SetMax(1000)
        slider:SetDecimals(0)
        slider:SetValue(Dev.value)

        slider.OnValueChanged = function(_, val)
            Dev.value = math.floor(val)
            valueLabel:SetText("Value: " .. Dev.value)
        end

        local applyBtn = vgui.Create("DButton", Dev.frame)
        applyBtn:SetPos(20, 120)
        applyBtn:SetSize(150, 30)
        applyBtn:SetText("Apply Speed")
        applyBtn.DoClick = function()
            local ply = LocalPlayer()
            if IsValid(ply) then
                ply:SetWalkSpeed(Dev.value)
                ply:SetRunSpeed(Dev.value * 1.5)
                chat.AddText(Color(0,255,0), "[DEV] Speed set to ", Dev.value)
            end
        end

        local input = vgui.Create("DTextEntry", Dev.frame)
        input:SetPos(200, 120)
        input:SetSize(180, 30)
        input:SetPlaceholderText("Enter number...")

        local setBtn = vgui.Create("DButton", Dev.frame)
        setBtn:SetPos(200, 160)
        setBtn:SetSize(180, 30)
        setBtn:SetText("Set Value")
        setBtn.DoClick = function()
            local num = tonumber(input:GetValue())
            if num then
                Dev.value = num
                slider:SetValue(num)
                valueLabel:SetText("Value: " .. Dev.value)
                chat.AddText(Color(0,255,0), "[DEV] Value set to ", Dev.value)
            else
                chat.AddText(Color(255,0,0), "[DEV] Invalid number")
            end
        end
    end

    hook.Add("Think", "DevMenuKey", function()
        if input.IsKeyDown(KEY_F6) then
            OpenDevMenu()
        end
    end)
end
EOF

echo "[+] Dev tool installed at $FILE"
echo "[+] Press F6 in GMod to open the menu"
