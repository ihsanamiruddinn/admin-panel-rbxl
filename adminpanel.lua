-- TripleS Hub UI
-- Modified sesuai permintaan

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/windui/windui/main/source.lua"))()

-- 1. Window ukuran UDim2.fromOffset(360, 300)
local Window = Library:Window({
    Name = "TripleS", -- 2. Branding
    Size = UDim2.fromOffset(360, 300),
})

-- 3. Welcome
Window:Label("by saanseventeen | github.com/ihsanamiruddinn")

-- 4. Features
local Features = Window:Tab("Universal")

Features:Button("Sample Button", function()
    print("Button ditekan!")
end)

Features:Toggle("Sample Toggle", false, function(v)
    print("Toggle:", v)
end)

Features:Slider("Sample Slider", 0, 100, 50, function(v)
    print("Slider:", v)
end)

Features:Dropdown("Sample Dropdown", {"Option 1", "Option 2", "Option 3"}, function(v)
    print("Dropdown:", v)
end)

-- 5. Settings (tambah Appearance + Keybind)
local Settings = Window:Tab("Settings")

Settings:Section("Appearance")
Settings:Button("Change Theme", function()
    print("Theme diubah!")
end)

Settings:Section("Keybind")
Settings:Keybind("Open/Close UI", Enum.KeyCode.RightControl, function()
    print("Keybind ditekan!")
end)

-- 6. Utilities (tambah Configuration + Plugins)
local Utilities = Window:Tab("Utilities")

Utilities:Section("Configuration")
Utilities:Button("Save Config", function()
    print("Config tersimpan")
end)
Utilities:Button("Load Config", function()
    print("Config terbaca")
end)

Utilities:Section("Plugins")
Utilities:Button("Plugin Manager", function()
    print("Plugin Manager dibuka")
end)

-- Tambahan biar UI panjang kaya bawaan WindUI
for i = 1, 5 do
    Features:Button("Extra Button " .. i, function()
        print("Extra Button " .. i .. " ditekan")
    end)
end

for i = 1, 3 do
    Settings:Toggle("Extra Toggle " .. i, false, function(v)
        print("Extra Toggle " .. i .. ":", v)
    end)
end

for i = 1, 3 do
    Utilities:Slider("Extra Slider " .. i, 0, 100, i * 10, function(v)
        print("Extra Slider " .. i .. ":", v)
    end)
end

-- 7. Footer
Window:Label("github.com/ihsanamiruddinn")

Library:Init()
