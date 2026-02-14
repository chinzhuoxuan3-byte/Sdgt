local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

getgenv().AbyssSettings = getgenv().AbyssSettings or {
    AutoFish = false,
    AutoAim = false,
    AutoShoot = false,
    AutoCatch = false,
    AutoSell = false,
    AutoQuest = false,
    AutoReroll = false,
    AutoCollectChests = false,
    AutoEquipBestGun = false,
    AutoUpgradeTube = false,
    InfiniteOxygen = false,
    NoOxygenDepletion = false,
    FastSwim = false,
    FastShoot = false,
    InstantCatch = false,
    AutoReturn = false,
    FishESP = false,
    ChestESP = false,
    NPCESP = false,
    ArtifactESP = false,
    BiomeESP = false,
    PlayerESP = false,
    Fullbright = false,
    NoFog = false,
    ShowOxygen = false,
    ShowStorage = false,
    ShowDistance = false,
    ShowBiome = false,
    ShowFishInfo = false,
    CustomFOV = false,
    WalkSpeed = 16,
    SwimSpeed = 50,
    FOVValue = 90,
    ESPDistance = 2000,
    AutoAimFOV = 200,
    AutoSellThreshold = 80,
    TargetRarity = "All",
    TeleportLocation = "Spawn",
    FilterMutations = {},
    FilterRarity = {},
    HitboxMultiplier = 1.5,
    ShootDelay = 0.1,
    CatchDelay = 0,
}

local FishDatabase = {}
local ChestDatabase = {}
local NPCDatabase = {}
local ArtifactDatabase = {}
local ActiveESP = {}
local CurrentBiome = "Unknown"
local OxygenLevel = 100
local StorageUsed = 0
local StorageMax = 100
local TotalFishCaught = 0
local TotalMoneyCaught = 0

local Window = Library:CreateWindow({
    Title = "Abyss Pro | Deep Spirit Games",
    Footer = "version: 1.5",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "crosshair"),
    Automation = Window:AddTab("Automation", "bot"),
    Visual = Window:AddTab("Visual", "eye"),
    Player = Window:AddTab("Player", "user"),
    Teleport = Window:AddTab("Teleport", "map-pin"),
    Misc = Window:AddTab("Misc", "settings"),
    ["UI Settings"] = Window:AddTab("UI Settings", "sliders-horizontal"),
}

local FishingGroup = Tabs.Main:AddLeftGroupbox("钓鱼功能")

FishingGroup:AddToggle("AutoFish", {
    Text = "自动钓鱼",
    Default = false,
    Tooltip = "自动瞄准并射击鱼类",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoFish = Value
    end
})

FishingGroup:AddToggle("AutoAim", {
    Text = "自动瞄准",
    Default = false,
    Tooltip = "自动瞄准最近的鱼",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoAim = Value
    end
})

FishingGroup:AddSlider("AutoAimFOV", {
    Text = "瞄准范围",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.AutoAimFOV = Value
    end
})

FishingGroup:AddToggle("AutoShoot", {
    Text = "自动射击",
    Default = false,
    Tooltip = "自动射击瞄准的鱼",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoShoot = Value
    end
})

FishingGroup:AddToggle("AutoCatch", {
    Text = "自动完成小游戏",
    Default = false,
    Tooltip = "自动完成捕鱼小游戏",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoCatch = Value
    end
})

FishingGroup:AddToggle("InstantCatch", {
    Text = "瞬间捕捉",
    Default = false,
    Tooltip = "跳过小游戏直接捕获",
    Callback = function(Value)
        getgenv().AbyssSettings.InstantCatch = Value
    end
})

FishingGroup:AddSlider("HitboxMultiplier", {
    Text = "碰撞箱倍数",
    Default = 1.5,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.HitboxMultiplier = Value
    end
})

local GunGroup = Tabs.Main:AddRightGroupbox("枪械/装备")

GunGroup:AddToggle("AutoEquipBestGun", {
    Text = "自动装备最佳枪械",
    Default = false,
    Tooltip = "自动装备背包中最好的枪械",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoEquipBestGun = Value
    end
})

GunGroup:AddToggle("FastShoot", {
    Text = "快速射击",
    Default = false,
    Tooltip = "移除射击冷却",
    Callback = function(Value)
        getgenv().AbyssSettings.FastShoot = Value
    end
})

GunGroup:AddSlider("ShootDelay", {
    Text = "射击延迟(秒)",
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.ShootDelay = Value
    end
})

GunGroup:AddDivider()

GunGroup:AddLabel("管道(Tube)设置")

GunGroup:AddToggle("AutoUpgradeTube", {
    Text = "自动升级管道",
    Default = false,
    Tooltip = "自动购买并升级管道",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoUpgradeTube = Value
    end
})

local AutomationGroup = Tabs.Automation:AddLeftGroupbox("自动化")

AutomationGroup:AddToggle("AutoSell", {
    Text = "自动出售",
    Default = false,
    Tooltip = "存储满时自动返回出售",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoSell = Value
    end
})

AutomationGroup:AddSlider("AutoSellThreshold", {
    Text = "出售阈值(%)",
    Default = 80,
    Min = 50,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.AutoSellThreshold = Value
    end
})

AutomationGroup:AddToggle("AutoReturn", {
    Text = "氧气低自动返回",
    Default = false,
    Tooltip = "氧气低于30%自动返回",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoReturn = Value
    end
})

AutomationGroup:AddToggle("AutoQuest", {
    Text = "自动任务",
    Default = false,
    Tooltip = "自动接受并完成任务",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoQuest = Value
    end
})

AutomationGroup:AddToggle("AutoCollectChests", {
    Text = "自动收集宝箱",
    Default = false,
    Tooltip = "自动收集附近的宝箱",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoCollectChests = Value
    end
})

AutomationGroup:AddToggle("AutoReroll", {
    Text = "自动重掷种族",
    Default = false,
    Tooltip = "自动使用星碎重掷种族",
    Callback = function(Value)
        getgenv().AbyssSettings.AutoReroll = Value
    end
})

local FilterGroup = Tabs.Automation:AddRightGroupbox("过滤设置")

FilterGroup:AddLabel("目标稀有度")
FilterGroup:AddDropdown("TargetRarity", {
    Values = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Default = 1,
    Multi = false,
    Text = "稀有度过滤",
    Tooltip = "只捕捉特定稀有度的鱼",
    Callback = function(Value)
        getgenv().AbyssSettings.TargetRarity = Value
    end
})

FilterGroup:AddInput("FilterMutations", {
    Default = "",
    Numeric = false,
    Finished = true,
    Text = "突变过滤",
    Tooltip = "用逗号分隔,如: Golden,Shiny,Albino",
    Placeholder = "Golden,Shiny,Albino",
    Callback = function(Value)
        local mutations = {}
        for mutation in string.gmatch(Value, "([^,]+)") do
            table.insert(mutations, string.lower(string.gsub(mutation, "^%s*(.-)%s*$", "%1")))
        end
        getgenv().AbyssSettings.FilterMutations = mutations
    end
})

FilterGroup:AddInput("FilterRarity", {
    Default = "",
    Numeric = false,
    Finished = true,
    Text = "稀有度过滤",
    Tooltip = "用逗号分隔,如: Legendary,Mythic",
    Placeholder = "Legendary,Mythic",
    Callback = function(Value)
        local rarities = {}
        for rarity in string.gmatch(Value, "([^,]+)") do
            table.insert(rarities, string.lower(string.gsub(rarity, "^%s*(.-)%s*$", "%1")))
        end
        getgenv().AbyssSettings.FilterRarity = rarities
    end
})

local FishESPGroup = Tabs.Visual:AddLeftGroupbox("鱼类透视")

FishESPGroup:AddToggle("FishESP", {
    Text = "启用鱼类ESP",
    Default = false,
    Tooltip = "显示鱼类位置",
    Callback = function(Value)
        getgenv().AbyssSettings.FishESP = Value
    end
})

FishESPGroup:AddToggle("ShowFishInfo", {
    Text = "显示鱼类信息",
    Default = false,
    Tooltip = "显示鱼的名称、稀有度等",
    Callback = function(Value)
        getgenv().AbyssSettings.ShowFishInfo = Value
    end
})

FishESPGroup:AddSlider("ESPDistance", {
    Text = "ESP最大距离",
    Default = 2000,
    Min = 500,
    Max = 10000,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.ESPDistance = Value
    end
})

local WorldESPGroup = Tabs.Visual:AddRightGroupbox("世界透视")

WorldESPGroup:AddToggle("ChestESP", {
    Text = "宝箱ESP",
    Default = false,
    Tooltip = "显示宝箱位置",
    Callback = function(Value)
        getgenv().AbyssSettings.ChestESP = Value
    end
})

WorldESPGroup:AddToggle("NPCESP", {
    Text = "NPC ESP",
    Default = false,
    Tooltip = "显示NPC位置",
    Callback = function(Value)
        getgenv().AbyssSettings.NPCESP = Value
    end
})

WorldESPGroup:AddToggle("ArtifactESP", {
    Text = "神器ESP",
    Default = false,
    Tooltip = "显示神器位置",
    Callback = function(Value)
        getgenv().AbyssSettings.ArtifactESP = Value
    end
})

WorldESPGroup:AddToggle("BiomeESP", {
    Text = "生物群系ESP",
    Default = false,
    Tooltip = "显示生物群系边界",
    Callback = function(Value)
        getgenv().AbyssSettings.BiomeESP = Value
    end
})

WorldESPGroup:AddToggle("PlayerESP", {
    Text = "玩家ESP",
    Default = false,
    Tooltip = "显示其他玩家",
    Callback = function(Value)
        getgenv().AbyssSettings.PlayerESP = Value
    end
})

local EnvironmentGroup = Tabs.Visual:AddLeftGroupbox("环境设置")

EnvironmentGroup:AddToggle("Fullbright", {
    Text = "全亮",
    Default = false,
    Tooltip = "移除黑暗效果",
    Callback = function(Value)
        getgenv().AbyssSettings.Fullbright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

EnvironmentGroup:AddToggle("NoFog", {
    Text = "移除雾气",
    Default = false,
    Tooltip = "提高可见距离",
    Callback = function(Value)
        getgenv().AbyssSettings.NoFog = Value
        if Value then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 500
            Lighting.FogStart = 0
        end
    end
})

EnvironmentGroup:AddToggle("CustomFOV", {
    Text = "自定义FOV",
    Default = false,
    Tooltip = "调整视野范围",
    Callback = function(Value)
        getgenv().AbyssSettings.CustomFOV = Value
        if Value then
            Camera.FieldOfView = getgenv().AbyssSettings.FOVValue
        else
            Camera.FieldOfView = 70
        end
    end
})

EnvironmentGroup:AddSlider("FOVValue", {
    Text = "FOV值",
    Default = 90,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.FOVValue = Value
        if getgenv().AbyssSettings.CustomFOV then
            Camera.FieldOfView = Value
        end
    end
})

local InfoGroup = Tabs.Visual:AddRightGroupbox("信息显示")

InfoGroup:AddToggle("ShowOxygen", {
    Text = "显示氧气",
    Default = false,
    Tooltip = "显示当前氧气水平",
    Callback = function(Value)
        getgenv().AbyssSettings.ShowOxygen = Value
    end
})

InfoGroup:AddToggle("ShowStorage", {
    Text = "显示存储",
    Default = false,
    Tooltip = "显示当前存储使用情况",
    Callback = function(Value)
        getgenv().AbyssSettings.ShowStorage = Value
    end
})

InfoGroup:AddToggle("ShowDistance", {
    Text = "显示距离",
    Default = false,
    Tooltip = "显示到目标的距离",
    Callback = function(Value)
        getgenv().AbyssSettings.ShowDistance = Value
    end
})

InfoGroup:AddToggle("ShowBiome", {
    Text = "显示生物群系",
    Default = false,
    Tooltip = "显示当前所在生物群系",
    Callback = function(Value)
        getgenv().AbyssSettings.ShowBiome = Value
    end
})

local MovementGroup = Tabs.Player:AddLeftGroupbox("移动设置")

MovementGroup:AddSlider("WalkSpeed", {
    Text = "行走速度",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

MovementGroup:AddToggle("FastSwim", {
    Text = "快速游泳",
    Default = false,
    Tooltip = "提高游泳速度",
    Callback = function(Value)
        getgenv().AbyssSettings.FastSwim = Value
    end
})

MovementGroup:AddSlider("SwimSpeed", {
    Text = "游泳速度",
    Default = 50,
    Min = 20,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        getgenv().AbyssSettings.SwimSpeed = Value
    end
})

local OxygenGroup = Tabs.Player:AddRightGroupbox("氧气设置")

OxygenGroup:AddToggle("InfiniteOxygen", {
    Text = "无限氧气",
    Default = false,
    Tooltip = "氧气不会减少",
    Callback = function(Value)
        getgenv().AbyssSettings.InfiniteOxygen = Value
    end
})

OxygenGroup:AddToggle("NoOxygenDepletion", {
    Text = "无氧气消耗",
    Default = false,
    Tooltip = "停止氧气消耗",
    Callback = function(Value)
        getgenv().AbyssSettings.NoOxygenDepletion = Value
    end
})

OxygenGroup:AddButton("补满氧气", function()
    Library:Notify("正在补满氧气...", 2)
end)

local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("传送位置")

local teleportLocations = {
    "出生点",
    "海妖(Kraken)",
    "商店",
    "第二岛",
    "深渊入口",
    "宝藏区",
    "船只残骸",
    "洞穴入口",
}

TeleportGroup:AddDropdown("TeleportLocation", {
    Values = teleportLocations,
    Default = 1,
    Multi = false,
    Text = "选择位置",
    Tooltip = "选择要传送的位置",
    Callback = function(Value)
        getgenv().AbyssSettings.TeleportLocation = Value
    end
})

TeleportGroup:AddButton("传送", function()
    local location = getgenv().AbyssSettings.TeleportLocation
    Library:Notify("传送到: " .. location, 2)
end)

TeleportGroup:AddDivider()

TeleportGroup:AddButton("传送到最近的鱼", function()
    Library:Notify("正在寻找最近的鱼...", 2)
end)

TeleportGroup:AddButton("传送到最近的宝箱", function()
    Library:Notify("正在寻找最近的宝箱...", 2)
end)

TeleportGroup:AddButton("传送到最近的NPC", function()
    Library:Notify("正在寻找最近的NPC...", 2)
end)

local QuickTPGroup = Tabs.Teleport:AddRightGroupbox("快速传送")

QuickTPGroup:AddButton("返回基地", function()
    Library:Notify("正在返回基地...", 2)
end)

QuickTPGroup:AddButton("传送到深海", function()
    Library:Notify("正在传送到深海...", 2)
end)

QuickTPGroup:AddButton("传送到浅水区", function()
    Library:Notify("正在传送到浅水区...", 2)
end)

local StatsGroup = Tabs.Misc:AddLeftGroupbox("统计信息")

StatsGroup:AddLabel("总捕获: 0")
StatsGroup:AddLabel("总收益: $0")
StatsGroup:AddLabel("当前氧气: 100%")
StatsGroup:AddLabel("存储使用: 0/100")
StatsGroup:AddLabel("当前生物群系: Unknown")

StatsGroup:AddButton("重置统计", function()
    TotalFishCaught = 0
    TotalMoneyCaught = 0
    Library:Notify("统计已重置", 2)
end)

local UtilityGroup = Tabs.Misc:AddRightGroupbox("实用工具")

UtilityGroup:AddButton("收集所有附近物品", function()
    Library:Notify("正在收集附近物品...", 2)
end)

UtilityGroup:AddButton("修复管道", function()
    Library:Notify("正在修复管道...", 2)
end)

UtilityGroup:AddButton("刷新背包", function()
    Library:Notify("正在刷新背包...", 2)
end)

UtilityGroup:AddDivider()

UtilityGroup:AddButton("复制游戏链接", function()
    setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
    Library:Notify("游戏链接已复制到剪贴板", 2)
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Library.Options.MenuKeybind

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:OnUnload(function()
    print("Abyss Script Unloaded!")
end)

local function UpdateFishDatabase()
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                FishDatabase = {}
                for _, obj in pairs(getgc(true)) do
                    if type(obj) == "table" then
                        local model = rawget(obj, "model") or rawget(obj, "Model")
                        if typeof(model) == "Instance" and model:IsDescendantOf(Workspace) then
                            local data = rawget(obj, "fishData") or rawget(obj, "data") or obj
                            local name = rawget(data, "name") or rawget(data, "Name")
                            if type(name) == "string" and not string.find(model.Name:lower(), "chest") then
                                local rarity = rawget(data, "rarity") or ""
                                local mutation = rawget(data, "mutation") or ""
                                local value = rawget(data, "value") or 0
                                FishDatabase[model] = {
                                    Name = name,
                                    Rarity = tostring(rarity),
                                    Mutation = tostring(mutation),
                                    Value = tonumber(value) or 0,
                                    Position = model:IsA("Model") and model:GetPivot().Position or model.Position
                                }
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function UpdateChestDatabase()
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                ChestDatabase = {}
                local chestsFolder = Workspace:FindFirstChild("Chests")
                if chestsFolder then
                    for _, chest in ipairs(chestsFolder:GetChildren()) do
                        if chest:IsA("Model") or chest:IsA("BasePart") then
                            ChestDatabase[chest] = {
                                Name = chest.Name,
                                Position = chest:IsA("Model") and chest:GetPivot().Position or chest.Position
                            }
                        end
                    end
                end
            end)
        end
    end)
end

local function UpdateNPCDatabase()
    task.spawn(function()
        while task.wait(3) do
            pcall(function()
                NPCDatabase = {}
                local npcsFolder = Workspace:FindFirstChild("NPCs")
                if npcsFolder then
                    for _, npc in ipairs(npcsFolder:GetChildren()) do
                        if npc:IsA("Model") then
                            NPCDatabase[npc] = {
                                Name = npc.Name,
                                Position = npc:GetPivot().Position
                            }
                        end
                    end
                end
            end)
        end
    end)
end

local function CreateESP(object, espType, color, text)
    if ActiveESP[object] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = object
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Text = text
    textLabel.Parent = billboard
    
    billboard.Parent = object
    
    ActiveESP[object] = {
        Billboard = billboard,
        Type = espType
    }
end

local function UpdateESP()
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local camPos = Camera.CFrame.Position
                
                for object, espData in pairs(ActiveESP) do
                    if not object.Parent then
                        espData.Billboard:Destroy()
                        ActiveESP[object] = nil
                    else
                        local pos = object:IsA("Model") and object:GetPivot().Position or object.Position
                        local distance = (pos - camPos).Magnitude
                        
                        if distance > getgenv().AbyssSettings.ESPDistance then
                            espData.Billboard.Enabled = false
                        else
                            espData.Billboard.Enabled = true
                            local textLabel = espData.Billboard:FindFirstChildOfClass("TextLabel")
                            if textLabel then
                                if espData.Type == "Fish" and FishDatabase[object] then
                                    local fishData = FishDatabase[object]
                                    local displayText = fishData.Name
                                    if getgenv().AbyssSettings.ShowFishInfo then
                                        if fishData.Rarity ~= "" then
                                            displayText = displayText .. "\n[" .. fishData.Rarity .. "]"
                                        end
                                        if fishData.Mutation ~= "" then
                                            displayText = displayText .. "\n<" .. fishData.Mutation .. ">"
                                        end
                                    end
                                    displayText = displayText .. "\n[" .. math.floor(distance) .. "m]"
                                    textLabel.Text = displayText
                                else
                                    textLabel.Text = textLabel.Text:match("^(.-)%[") .. "[" .. math.floor(distance) .. "m]"
                                end
                            end
                        end
                    end
                end
                
                if getgenv().AbyssSettings.FishESP then
                    for model, data in pairs(FishDatabase) do
                        if not ActiveESP[model] then
                            CreateESP(model, "Fish", Color3.fromRGB(100, 200, 255), data.Name)
                        end
                    end
                else
                    for object, espData in pairs(ActiveESP) do
                        if espData.Type == "Fish" then
                            espData.Billboard:Destroy()
                            ActiveESP[object] = nil
                        end
                    end
                end
                
                if getgenv().AbyssSettings.ChestESP then
                    for chest, data in pairs(ChestDatabase) do
                        if not ActiveESP[chest] then
                            CreateESP(chest, "Chest", Color3.fromRGB(255, 215, 0), "Treasure Chest")
                        end
                    end
                else
                    for object, espData in pairs(ActiveESP) do
                        if espData.Type == "Chest" then
                            espData.Billboard:Destroy()
                            ActiveESP[object] = nil
                        end
                    end
                end
                
                if getgenv().AbyssSettings.NPCESP then
                    for npc, data in pairs(NPCDatabase) do
                        if not ActiveESP[npc] then
                            CreateESP(npc, "NPC", Color3.fromRGB(100, 255, 100), data.Name)
                        end
                    end
                else
                    for object, espData in pairs(ActiveESP) do
                        if espData.Type == "NPC" then
                            espData.Billboard:Destroy()
                            ActiveESP[object] = nil
                        end
                    end
                end
            end)
        end
    end)
end

local function AutoFish()
    task.spawn(function()
        while task.wait(getgenv().AbyssSettings.ShootDelay) do
            if getgenv().AbyssSettings.AutoFish or getgenv().AbyssSettings.AutoAim or getgenv().AbyssSettings.AutoShoot then
                pcall(function()
                    local closestFish = nil
                    local closestDistance = math.huge
                    local camPos = Camera.CFrame.Position
                    
                    for model, data in pairs(FishDatabase) do
                        if model.Parent then
                            local distance = (data.Position - camPos).Magnitude
                            if distance < closestDistance and distance < getgenv().AbyssSettings.AutoAimFOV then
                                closestFish = model
                                closestDistance = distance
                            end
                        end
                    end
                    
                    if closestFish and (getgenv().AbyssSettings.AutoAim or getgenv().AbyssSettings.AutoFish) then
                        local fishPos = closestFish:IsA("Model") and closestFish:GetPivot().Position or closestFish.Position
                        Camera.CFrame = CFrame.new(camPos, fishPos)
                        
                        if getgenv().AbyssSettings.AutoShoot or getgenv().AbyssSettings.AutoFish then
                            
                        end
                    end
                end)
            end
        end
    end)
end

local function AutoSell()
    task.spawn(function()
        while task.wait(5) do
            if getgenv().AbyssSettings.AutoSell then
                pcall(function()
                    local storagePercent = (StorageUsed / StorageMax) * 100
                    if storagePercent >= getgenv().AbyssSettings.AutoSellThreshold then
                        
                    end
                end)
            end
        end
    end)
end

local function InfiniteOxygen()
    task.spawn(function()
        while task.wait(0.1) do
            if getgenv().AbyssSettings.InfiniteOxygen or getgenv().AbyssSettings.NoOxygenDepletion then
                pcall(function()
                    if Character then
                        local oxygen = Character:FindFirstChild("Oxygen")
                        if oxygen and oxygen:IsA("NumberValue") then
                            oxygen.Value = 100
                            OxygenLevel = 100
                        end
                    end
                end)
            end
        end
    end)
end

local function FastSwim()
    task.spawn(function()
        while task.wait() do
            if getgenv().AbyssSettings.FastSwim then
                pcall(function()
                    if Character then
                        local swimController = Character:FindFirstChild("SwimController")
                        if swimController then
                            
                        end
                    end
                end)
            end
        end
    end)
end

local function ExpandHitbox()
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                for model, data in pairs(FishDatabase) do
                    if model.Parent then
                        for _, part in ipairs(model:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if not part:GetAttribute("OriginalSize") then
                                    part:SetAttribute("OriginalSize", part.Size)
                                end
                                part.Size = part:GetAttribute("OriginalSize") * getgenv().AbyssSettings.HitboxMultiplier
                                part.Transparency = 0.7
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function AutoCatch()
    task.spawn(function()
        while task.wait(getgenv().AbyssSettings.CatchDelay) do
            if getgenv().AbyssSettings.AutoCatch or getgenv().AbyssSettings.InstantCatch then
                pcall(function()
                    for _, module in ipairs(getloadedmodules()) do
                        local req = require(module)
                        if type(req) == "table" and rawget(req, "UpdateUI") and rawget(req, "PerfectCatch") then
                            if not req._hooked then
                                local oldUpdateUI = req.UpdateUI
                                req.UpdateUI = function(self, dt)
                                    if getgenv().AbyssSettings.AutoCatch and self._markerCurrent then
                                        self.zonePos = self._markerCurrent
                                    end
                                    if getgenv().AbyssSettings.InstantCatch then
                                        self._markerCurrent = self.zonePos
                                    end
                                    return oldUpdateUI(self, dt)
                                end
                                req._hooked = true
                            end
                        end
                    end
                end)
            end
        end
    end)
end

Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

RunService.Heartbeat:Connect(function()
    if Humanoid and getgenv().AbyssSettings.WalkSpeed ~= 16 then
        Humanoid.WalkSpeed = getgenv().AbyssSettings.WalkSpeed
    end
end)

UpdateFishDatabase()
UpdateChestDatabase()
UpdateNPCDatabase()
UpdateESP()
AutoFish()
AutoSell()
InfiniteOxygen()
FastSwim()
ExpandHitbox()
AutoCatch()

Library:Notify("Abyss Script Loaded! | v1.5", 5)

print("=================================")
print("Abyss Pro Script Loaded")
print("Version: 1.5")
print("Game: Deep Spirit Games - Abyss")
print("=================================")
