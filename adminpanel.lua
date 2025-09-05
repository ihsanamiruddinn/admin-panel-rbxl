local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ihsanamiruddinn/TripleS-UI/main/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TripleS",
    Author = "by saanseventeen",
    Size = UDim2.fromOffset(360, 300),
    Theme = "Dark",
})

-- Tab Universal
local TabUniversal = Window:Tab({ Title = "Universal" })

TabUniversal:Button({
    Title = "Test Button",
    Callback = function()
        WindUI:Notify({
            Title = "Universal",
            Content = "Button berfungsi!",
            Duration = 3
        })
    end
})

TabUniversal:Toggle({
    Title = "Test Toggle",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Universal",
            Content = "Toggle: " .. tostring(state),
            Duration = 3
        })
    end
})

TabUniversal:Slider({
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})
