-- Fling Things and People Script v2.2
-- Clean and organized version

-- Load the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mano-Gustavo/Mano-Gustavo-Library/refs/heads/main/library.lua"))()

-- Services
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuration (ALL DISABLED BY DEFAULT)
local Config = {
    flingEnabled = false,
    strength = 560,
    autoDestroy = true,
    destroyDelay = 1,
    partName = "GrabParts",
    partChildName = "GrabPart",
    notificationOnFling = true,
    jumpPowerEnabled = false,
    jumpPower = 50,
    autoApplyOnRespawn = true
}

-- Create main window
local Window = Library:CreateWindow({
    Title = "Fling Things and People Script v2.2",
    Keybind = Enum.KeyCode.RightControl
})

-- Create tabs
local TabMain = Window:CreateTab("Main Settings")
local TabPlayer = Window:CreateTab("Player Modifications")

-- Main Section
local MainSection = TabMain:CreateSection("Fling Control")

-- Fling Toggle
local FlingToggle = MainSection:CreateToggle("Enable Fling", function(value)
    Config.flingEnabled = value
    if value then
        Library:Notification({
            Title = "Fling System",
            Text = "Fling system has been enabled",
            Type = "Success"
        })
    else
        Library:Notification({
            Title = "Fling System", 
            Text = "Fling system has been disabled",
            Type = "Warning"
        })
    end
end, false)

FlingToggle:SetTooltip("Enables or disables the entire fling system")

-- Strength Slider
local StrengthSlider = MainSection:CreateSlider("Fling Strength", 100, 2000, 560, function(value)
    Config.strength = value
end)

StrengthSlider:SetTooltip("Controls how far objects are flung")

-- Notification Toggle
local NotifToggle = MainSection:CreateToggle("Show Notifications", function(value)
    Config.notificationOnFling = value
end, false)

NotifToggle:SetTooltip("Shows notifications when objects are flung")

-- Advanced Section
local AdvancedSection = TabMain:CreateSection("Advanced Settings")

-- Part Name Input
local PartNameBox = AdvancedSection:CreateTextBox("Part Name", "GrabParts", function(text)
    Config.partName = text
end)

PartNameBox:SetTooltip("Name of the part to detect")

-- Child Name Input
local ChildNameBox = AdvancedSection:CreateTextBox("Child Name", "GrabPart", function(text)
    Config.partChildName = text
end)

ChildNameBox:SetTooltip("Name of the child inside the part")

-- Destroy Delay Slider
local DestroySlider = AdvancedSection:CreateSlider("Destroy Delay", 0.1, 5, 1, function(value)
    Config.destroyDelay = value
end)

DestroySlider:SetTooltip("Time before physics is removed")

-- Auto Destroy Toggle
local AutoDestroyToggle = AdvancedSection:CreateToggle("Auto Destroy Parts", function(value)
    Config.autoDestroy = value
end, false)

AutoDestroyToggle:SetTooltip("Automatically removes physics after delay")

-- Player Modifications Section
local PlayerSection = TabPlayer:CreateSection("Player Modifications")

-- JumpPower Toggle
local JumpPowerToggle = PlayerSection:CreateToggle("Enable JumpPower", function(value)
    Config.jumpPowerEnabled = value
    if value then
        ApplyJumpPower()
        Library:Notification({
            Title = "JumpPower",
            Text = "JumpPower modified to: " .. Config.jumpPower,
            Type = "Success"
        })
    else
        ResetJumpPower()
        Library:Notification({
            Title = "JumpPower",
            Text = "JumpPower reset to default",
            Type = "Warning"
        })
    end
end, false)

JumpPowerToggle:SetTooltip("Enables or disables jump height modification")

-- JumpPower Slider
local JumpPowerSlider = PlayerSection:CreateSlider("JumpPower", 50, 200, 50, function(value)
    Config.jumpPower = value
    if Config.jumpPowerEnabled then
        ApplyJumpPower()
    end
end)

JumpPowerSlider:SetTooltip("Sets the player's jump height")

-- Auto Respawn Toggle
local AutoRespawnToggle = PlayerSection:CreateToggle("Auto Apply on Respawn", function(value)
    Config.autoApplyOnRespawn = value
    if value then
        Library:Notification({
            Title = "Auto Apply",
            Text = "Modifications will auto apply on respawn",
            Type = "Info"
        })
    end
end, false)

AutoRespawnToggle:SetTooltip("Auto applies JumpPower when respawning")

-- Apply Button
PlayerSection:CreateButton("Apply Now", function()
    if Config.jumpPowerEnabled then
        ApplyJumpPower()
    end
    Library:Notification({
        Title = "Applied",
        Text = "Modifications applied to character",
        Type = "Success"
    })
end):SetTooltip("Manually applies modifications")

-- Test Section
local TestSection = TabMain:CreateSection("Test Functions")

TestSection:CreateButton("Test Notification", function()
    Library:Notification({
        Title = "Test",
        Text = "System is working",
        Duration = 3,
        Type = "Success"
    })
end):SetTooltip("Tests notification system")

-- Player Modification Functions
function ApplyJumpPower()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = Config.jumpPower
        end
    end
end

function ResetJumpPower()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
    end
end

-- Auto Apply on Respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    if Config.autoApplyOnRespawn then
        character:WaitForChild("Humanoid")
        if Config.jumpPowerEnabled then
            ApplyJumpPower()
        end
    end
end)

-- Main Fling System
local function SetupFlingSystem()
    Workspace.ChildAdded:Connect(function(model)
        if not Config.flingEnabled then return end
        
        if model.Name == Config.partName then
            local part = model:FindFirstChild(Config.partChildName)
            if part and part:FindFirstChild("WeldConstraint") then
                local obj = part.WeldConstraint.Part1
                
                if obj then
                    local velocity = Instance.new("BodyVelocity", obj)
                    
                    if Config.notificationOnFling then
                        Library:Notification({
                            Title = "Fling Detected",
                            Text = "Flinging object",
                            Duration = 2,
                            Type = "Info"
                        })
                    end
                    
                    model:GetPropertyChangedSignal("Parent"):Connect(function()
                        if not model.Parent then
                            if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                velocity.Velocity = Workspace.CurrentCamera.CFrame.lookVector * Config.strength
                                
                                if Config.autoDestroy then
                                    Debris:AddItem(velocity, Config.destroyDelay)
                                end
                            else
                                velocity:Destroy()
                            end
                        end
                    end)
                end
            end
        end
    end)
end

-- Initialize
SetupFlingSystem()

if Config.jumpPowerEnabled then
    ApplyJumpPower()
end

Library:Notification({
    Title = "Fling Script v2.2",
    Text = "Menu loaded - All features disabled by default",
    Duration = 5,
    Type = "Info"
})