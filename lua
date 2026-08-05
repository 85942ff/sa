local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Right"

local Window = Library:CreateWindow({
    Title = ' Ohio | NOLSAKEN',
    Footer = "NOLSAKEN Team",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 8,
    MenuFadeTime = 0
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

if not game:IsLoaded() then game.Loaded:Wait() end

local devv = require(ReplicatedStorage:WaitForChild("devv"))
local loadModule = devv.load
local v3item = loadModule("v3item")
local Signal = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
local FireServer = Signal.FireServer
local InvokeServer = Signal.InvokeServer
local Inventory = v3item.inventory
local items = Inventory.items

local function tableFind(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

local function GUID()
    return devv.load("GUID")()
end

local idleLocations = {
    ["TeTraX"] = CFrame.new(1653.397216796875, -16.95315170288086, -530.3738403320312),
    ["宿傩"] = CFrame.new(121.4214859008789, -42.42018508911133, -515.8087158203125),
    ["位置1"] = CFrame.new(439.01190185546875, -25.120525360107422, -822.7509155273438),
    ["位置2"] = CFrame.new(386.4916076660156, 3.1478753089904785, -1359.7310791015625),
    ["位置3"] = CFrame.new(490.7265930175781, -22.4210262298584, -272.43170166015625),
    ["位置4"] = CFrame.new(160.63153076171875, -33.42034912109375, -445.28424072265625),
    ["位置5"] = CFrame.new(584.040283203125, -86.82018280029297, -724.7525634765625),
    ["位置6"] = CFrame.new(1021.9706420898438, -21.59579086303711, 89.16853332519531),
    ["位置7"] = CFrame.new(575.1665649414062, -40.00355911254883, -88.20584869384766),
    ["位置8"] = CFrame.new(1410.9215087890625, -9.405234336853027, 714.591064453125),
    ["位置9"] = CFrame.new(681.484619140625, -54.65692138671875, -337.3169860839844)
}
local currentIdleName = "TeTraX"
local currentMode = "AFK"
local function getCurrentIdleCF()
    return idleLocations[currentIdleName] or idleLocations["TeTraX"]
end

local atmYawOffset = 0

local maskLocations = {
    ["黑色头巾"] = CFrame.new(604.114014, 5.09485245, -1018.1275, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["红色头巾"] = CFrame.new(604.021545, 4.99485302, -1025.21191, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["蓝色头巾"] = CFrame.new(604.113892, 5.09485245, -1010.82751, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["外科医生口罩"] = CFrame.new(1160.00659, 4.65769672, -975.317871, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["面具"] = CFrame.new(1438.61926, 6.60790443, -145.005386, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}
local selectedMaskType = "黑色头巾"
local maskAutoBuy = true

local maskNames = {
    ["黑色头巾"] = "Black Bandana",
    ["红色头巾"] = "Red Bandana",
    ["蓝色头巾"] = "Blue Bandana",
    ["外科医生口罩"] = "Surgeon Mask",
    ["面具"] = "Hockey Mask"
}

local grenadeBuyLocation = CFrame.new(659.044739, 5.77163315, -706.697632, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local bombThrowLocation = CFrame.new(1129.0994873046875, 14.843579292297363, -354.19488525390625)
local bombTargetPosition = Vector3.new(1124.0853271484, 5.3128666877747, -357.68710327148)
local afterExplosionWaitLocation = CFrame.new(1112.95142, 16.6149864, -331.99646, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local lockpickBuyLocation = CFrame.new(659.280029, 5.50683689, -716.48999, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local vestBuyLocation = CFrame.new(659.063477, 6.21583509, -684.365051, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local bandageBuyLocation = CFrame.new(1168.04468, 25.0443974, -972.782654, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local flamethrowerBuyLocation = CFrame.new(1658.28564, 24.541769, -499.186249, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local rpgBuyLocation = CFrame.new(1145.82153, 25.5613174, -1322.12683, -0.173624277, 0, -0.984811902, 0, 1, 0, 0.984811902, 0, -0.173624277)

local throwBuyLocations = {
    ["Ninja Star"] = CFrame.new(337.521484, 25.4010315, -169.487122, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Tomahawk"] = CFrame.new(1027.82568, -48.4671783, -146.084671, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Banana Peel"] = CFrame.new(1568.33887, 3.93496037, -743.868835, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

local gunBuyLocations = {
    ["Raygun"] = CFrame.new(147.022064, -98.0489502, -529.441406, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["M4A1"] = CFrame.new(603.467651, 25.6628113, -922.04425, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["AK47"] = CFrame.new(1628.71704, 6.15060806, -620.919617, 0.087131381, -0, -0.996196866, 0, 1, -0, 0.996196866, 0, 0.087131381),
}

local function getGuid(name)
    for _, v in pairs(items) do
        if v.name == name then
            return v.guid
        end
    end
end

local function getRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
end

local function refreshItems()
    items = Inventory.items
end

local itemPickupFolder = workspace.Game.Entities:FindFirstChild("ItemPickup")
local itemMap = {}
local function updateItemCache()
    itemMap = {}
    local children = workspace.Game.Entities.ItemPickup:GetChildren()
    for _, model in pairs(children) do
        for _, v in pairs(model:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.ObjectText then
                    itemMap[prompt.ObjectText] = { part = v, prompt = prompt }
                end
            end
        end
    end
end
if itemPickupFolder then
    updateItemCache()
    itemPickupFolder.ChildAdded:Connect(updateItemCache)
    itemPickupFolder.ChildRemoved:Connect(updateItemCache)
end

local function Autoitem(itemName)
    local data = itemMap[itemName]
    if data then
        local char = LocalPlayer.Character
        local root = getRoot(char)
        if root then
            root.CFrame = data.part.CFrame
            data.prompt.RequiresLineOfSight = false
            data.prompt.HoldDuration = 0
            fireproximityprompt(data.prompt)
            return true
        end
    end
    return false
end

local flySpeed = 50
local currentSpeed = 10
local tpWalkEnabled = false
local flying = false
local flyBV, flyBG, flyConnection
local tpWalkConnection
local antivoidConnection
local silentaim = false

local FromATM, FromBank, FromBalloon = false, false, false
local Auarcuff, autovest, autohealth, autokz, callphone = false, false, false, false, false
local autouse, remls, autobx, autozbd, autoTreasure = false, false, false, false, false
local autoblock, automoss, autoxybs, autoxywp, autoptbs, automoney, card = false, false, false, false, false, false, false
local aurablade, tpplayfb = false, false
local fbx, fby, fbz = 0, 0, 5
local targetPlayers = {}
local selectedWeapon = "Ninja Star"
local selectedGun = "Raygun"
local bladeid
local openfake, fakemoney = false, 0
local AntiDoll, AntiAdmin = false, false
local busy = false
local maskBuying = false

local flameAttackEnabled = false
local flameAttackDistance = 10000
local hitPart = "Head"

local rpgAttackEnabled = false
local rpgAttackDistance = 100
local rpgMinHealth = 0.3

local autoUnlockEnabled = false
local unlockAuraConnection = nil

local cashAuraEnabled = false
local itemAuraEnabled = false
local cashAuraConnection = nil
local itemAuraConnection = nil

local autoSellEnabled = false
local autoSellTask = nil

local autoBuyGunAmmo = false
local autoBuyFlameAmmo = false
local autoBuyRPGAmmo = false
local gunBuyTimer = 0
local flameBuyTimer = 0
local rpgBuyTimer = 0
local gunBuyInterval = 10
local flameBuyInterval = 15
local rpgBuyInterval = 10
local BUY_AMMO_COUNT = 10

local lastAttack = 0
local avoidPosition = Vector3.new(-23.943367, 53.9272232, -40.3150673)
local avoidRadius = 100

local flyJumpConnection
local espLoopConnection
local auraConnection
local fakeConnection
local idleConnection

local autoCraftEnabled = false
local autoClaimEnabled = false
local autoStoreGems = false

local autoRewardEnabled = false
local autoRewardConnection = nil

local autoCollectTruckCash = false
local autoCollectScrap = false
local autoSlotMachine = false

local autoStomp = false
local autoGrab = false

local itemAuraTimer = 0
local ITEM_AURA_INTERVAL = 0.1

local punchType = "meleepunch"
local punchRunning = false
local punchConnection = nil

local autoCashRegister = false
local autoGemRubble = false
local gemRubbleCooldown = 0
local gemRubbleCooldownTime = 30

local RAINBOW_TRACE = false
local hitLogEnabled = false
local hitLogConnection = nil
local recentlyHit = {}
local healthCache = {}
local hitLogLastNotify = {}

local function fastCollectItems(itemNames)
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local originalPosition = rootPart.CFrame

    local targetItems = {}
    for _, l in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
        for _, v in pairs(l:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                for _, e in pairs(v:GetChildren()) do
                    if e:IsA("ProximityPrompt") then
                        for _, itemName in ipairs(itemNames) do
                            if e.ObjectText == itemName then
                                table.insert(targetItems, {
                                    cframe = v.CFrame,
                                    prompt = e
                                })
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if #targetItems == 0 then
        return false
    end

    for _, itemData in pairs(targetItems) do
        if not autoCollectScrap then break end
        rootPart.CFrame = itemData.cframe * CFrame.new(0, 2, 0)
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        task.wait(2)
        itemData.prompt.RequiresLineOfSight = false
        itemData.prompt.HoldDuration = 0
        for i = 1, 5 do
            fireproximityprompt(itemData.prompt)
            task.wait(0.01)
        end
    end

    rootPart.CFrame = originalPosition
    return true
end

local function autoClaimRewards()
    for day = 1, 12 do
        Signal.InvokeServer("claimDailyReward", day)
        task.wait(0.1)
    end
    for tier = 1, 3 do
        for level = 1, 6 do
            Signal.InvokeServer("claimPlaytimeReward", tier, level)
            task.wait(0.1)
        end
    end
end

local function startAutoRewardLoop()
    autoRewardEnabled = true
    autoRewardConnection = task.spawn(function()
        while autoRewardEnabled do
            autoClaimRewards()
            task.wait(5)
        end
    end)
end

local function stopAutoRewardLoop()
    autoRewardEnabled = false
    if autoRewardConnection then
        task.cancel(autoRewardConnection)
        autoRewardConnection = nil
    end
end

local function antiSit(character)
    local hum = character:WaitForChild("Humanoid")
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:GetPropertyChangedSignal("Sit"):Connect(function()
        if hum.Sit then hum.Sit = false end
    end)
    hum.Sit = false
end
if LocalPlayer.Character then antiSit(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(antiSit)

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        task.wait()
        onCharacterAdded(LocalPlayer.Character)
        if tpWalkEnabled then startTPWalk() end
        if flying then startFly() end
    end)
    maskBuying = false

    task.wait(0.5)
    if aurablade then
        prepareWeapon()
    end
    if flameAttackEnabled then
        startFlameAttack()
    end
    if rpgAttackEnabled then
        startRPGAttack()
    end
end
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

local function startFly()
    if flying or not LocalPlayer.Character then return end
    local char = LocalPlayer.Character
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    flying = true
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity", root)
    flyBV.Name = "FlyBodyVelocity"
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBG = Instance.new("BodyGyro", root)
    flyBG.Name = "FlyBodyGyro"
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 3000
    flyConnection = RunService.RenderStepped:Connect(function(delta)
        if not flying or not root then return end
        local camera = workspace.CurrentCamera
        local velocity = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + (camera.CFrame.LookVector * flySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - (camera.CFrame.LookVector * flySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - (camera.CFrame.RightVector * flySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + (camera.CFrame.RightVector * flySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, flySpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, flySpeed, 0) end
        flyBV.Velocity = velocity
        if camera then flyBG.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector) end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startTPWalk()
    if tpWalkEnabled then return end
    tpWalkEnabled = true
    tpWalkConnection = RunService.Stepped:Connect(function(_, deltaTime)
        if not tpWalkEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            local translation = hum.MoveDirection * currentSpeed * deltaTime * 10
            char:TranslateBy(translation)
        end
    end)
end

local function stopTPWalk()
    tpWalkEnabled = false
    if tpWalkConnection then tpWalkConnection:Disconnect(); tpWalkConnection = nil end
end

local function toggleAntiVoid(state)
    if state then
        if antivoidConnection then antivoidConnection:Disconnect() end
        local destroyHeight = workspace.FallenPartsDestroyHeight
        antivoidConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            local root = getRoot(char)
            if root and root.Position.Y <= destroyHeight + 25 then
                root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
            end
        end)
    else
        if antivoidConnection then antivoidConnection:Disconnect(); antivoidConnection = nil end
    end
end

local function toggleBunnyHop(state)
    if state then
        if flyJumpConnection then flyJumpConnection:Disconnect() end
        flyJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if flyJumpConnection then flyJumpConnection:Disconnect(); flyJumpConnection = nil end
    end
end

local function toggleNoClip(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

local transparentConnection
local function toggleTransparent(state)
    if state then
        if transparentConnection then transparentConnection:Disconnect() end
        transparentConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local root = getRoot(char)
            if not root then return end
            local rainbow = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    if v.Name == "Head" then
                        v.Transparency = 1
                        if v:FindFirstChild("face") then v.face:Destroy() end
                    else
                        v.Material = Enum.Material.ForceField
                        v.Color = rainbow
                        v.Transparency = 0.5
                    end
                end
            end
        end)
    else
        if transparentConnection then transparentConnection:Disconnect(); transparentConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0
                    v.Material = Enum.Material.Plastic
                end
            end
        end
    end
end

local DrawingConfig = {
    Enabled = false,
    NameEnabled = true,
    DistanceEnabled = true,
    HealthText = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(200, 200, 200),
    HealthColor = Color3.fromRGB(0, 255, 0),
}
local espCache = {}
local function clearESP()
    for _, cache in pairs(espCache) do
        if cache.Billboard then cache.Billboard:Destroy() end
    end
    espCache = {}
end
local function createESP(character, player, enabled)
    local billboard = character:FindFirstChild("SimpleESP")
    if not billboard and enabled then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "SimpleESP"
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 6, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = true
        billboard.Parent = character
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESPText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 12
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.RichText = true
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = billboard
        espCache[character] = { Billboard = billboard, TextLabel = textLabel }
    end
    if billboard then
        local textLabel = billboard:FindFirstChild("ESPText")
        if textLabel then
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health > 0 then
                local distance = math.round(LocalPlayer:DistanceFromCharacter(rootPart.Position))
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local texts = {}
                if DrawingConfig.NameEnabled then
                    table.insert(texts, string.format("<font color='rgb(%d,%d,%d)'>%s</font>",
                        DrawingConfig.NameColor.R*255, DrawingConfig.NameColor.G*255, DrawingConfig.NameColor.B*255, player.Name))
                end
                if DrawingConfig.DistanceEnabled then
                    table.insert(texts, string.format("<font color='rgb(%d,%d,%d)'>距离: %dm</font>",
                        DrawingConfig.DistanceColor.R*255, DrawingConfig.DistanceColor.G*255, DrawingConfig.DistanceColor.B*255, distance))
                end
                if DrawingConfig.HealthText then
                    table.insert(texts, string.format("<font color='rgb(%d,%d,%d)'>HP: %d/%d</font>",
                        DrawingConfig.HealthColor.R*255, DrawingConfig.HealthColor.G*255, DrawingConfig.HealthColor.B*255, health, maxHealth))
                end
                textLabel.Text = table.concat(texts, "\n")
                billboard.Enabled = enabled
            else
                billboard.Enabled = false
            end
        end
    end
end
local function toggleESP(state)
    DrawingConfig.Enabled = state
    if state then
        if espLoopConnection then espLoopConnection:Disconnect() end
        espLoopConnection = RunService.Heartbeat:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createESP(player.Character, player, true)
                end
            end
        end)
    else
        if espLoopConnection then espLoopConnection:Disconnect(); espLoopConnection = nil end
        clearESP()
    end
end

local function findTarget()
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

local function createTrace(targetPos)
    local char = LocalPlayer.Character
    local myPos = char and getRoot(char) and getRoot(char).Position or Vector3.zero
    local startPos = myPos + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
    local mag = (targetPos - startPos).Magnitude
    local part = Instance.new("Part")
    part.Name = "Trace"
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromHSV(tick()%1, 0.8, 1)
    part.Size = Vector3.new(0.15, 0.15, mag)
    part.CFrame = CFrame.lookAt(startPos, targetPos) * CFrame.new(0,0,-mag/2)
    part.Parent = workspace
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://5633695679"
    sound.Parent = part
    sound:Play()
    game.Debris:AddItem(sound, 1)
    TweenService:Create(part, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0,0,mag)}):Play()
    game.Debris:AddItem(part, 1)
end

local function createRainbowTrace(cf)
    if not cf then return end
    local startPos = cf.Position
    local targetPos = startPos + (cf.LookVector * 1000)
    local mag = (targetPos - startPos).Magnitude
    local P = Instance.new("Part")
    P.Name = "RainbowTrace"
    P.Anchored = true
    P.CanCollide = false
    P.CastShadow = false
    P.Material = Enum.Material.Neon
    P.Color = Color3.fromHSV(tick() % 1, 0.8, 1)
    P.Size = Vector3.new(0.15, 0.15, mag)
    P.CFrame = CFrame.lookAt(startPos, targetPos) * CFrame.new(0, 0, -mag/2)
    P.Parent = workspace
    local s = Instance.new("Sound", P)
    s.SoundId = "rbxassetid://5633695679"
    s:Play()
    TweenService:Create(P, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0, 0, mag)}):Play()
    game.Debris:AddItem(P, 1)
end

local function startHitLogger()
    if hitLogConnection then return end
    hitLogEnabled = true
    recentlyHit = {}
    healthCache = {}
    hitLogLastNotify = {}

    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and hitLogEnabled then
            if args[2] == "player" and args[3] then
                local hitPlayerId = args[3].hitPlayerId
                recentlyHit[hitPlayerId] = true
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)

    hitLogConnection = RunService.RenderStepped:Connect(function()
        if not hitLogEnabled then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer or not p.Character then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not hum then continue end
            local oldHealth = healthCache[p.UserId] or hum.Health
            local newHealth = hum.Health
            local damage = oldHealth - newHealth
            if damage > 0 and recentlyHit[p.UserId] then
                local now = tick()
                if not hitLogLastNotify[p.UserId] or (now - hitLogLastNotify[p.UserId] > 0.5) then
                    hitLogLastNotify[p.UserId] = now
                    Library:Notify({
                        Text = string.format("对 %s 造成了 %.0f 伤害 | 剩余血量：%.0f", p.Name, damage, newHealth),
                        Duration = 2,
                        Icon = "info"
                    })
                end
                recentlyHit[p.UserId] = nil
            end
            healthCache[p.UserId] = newHealth
        end
    end)
end

local function stopHitLogger()
    hitLogEnabled = false
    if hitLogConnection then
        hitLogConnection:Disconnect()
        hitLogConnection = nil
    end
    recentlyHit = {}
    healthCache = {}
    hitLogLastNotify = {}
end

local function prepareWeapon()
    if selectedWeapon == "Gun Kill" then
        local hasGun = false
        for _, v in pairs(items) do
            if v.name == selectedGun then
                hasGun = true
                FireServer("equip", v.guid)
                break
            end
        end
        if not hasGun then
            local buyLoc = gunBuyLocations[selectedGun]
            local root = getRoot(LocalPlayer.Character)
            if root and buyLoc then
                local originalCF = root.CFrame
                root.CFrame = buyLoc
                task.wait(0.5)
                InvokeServer("attemptPurchase", selectedGun)
                task.wait(0.3)
                for _, v in pairs(items) do
                    if v.name == selectedGun then
                        FireServer("equip", v.guid)
                        break
                    end
                end
                root.CFrame = originalCF
            end
        end
    else
        local hasWeapon = false
        for _, v in pairs(items) do
            if v.name == selectedWeapon then
                hasWeapon = true
                bladeid = v.guid
                FireServer("equip", bladeid)
                break
            end
        end
        if not hasWeapon then
            local buyLoc = throwBuyLocations[selectedWeapon]
            local root = getRoot(LocalPlayer.Character)
            if root and buyLoc then
                local originalCF = root.CFrame
                root.CFrame = buyLoc
                task.wait(0.5)
                InvokeServer("attemptPurchase", selectedWeapon)
                for _, v in pairs(items) do
                    if v.name == selectedWeapon then
                        bladeid = v.guid
                        break
                    end
                end
                if bladeid then
                    FireServer("equip", bladeid)
                    task.wait(0.1)
                    local _, id = InvokeServer("throwSticky", devv.load("GUID")(), selectedWeapon, bladeid, Vector3.zero, Vector3.zero)
                    bladeid = id
                end
                root.CFrame = originalCF
            end
        end
    end
end

local function attackTarget(target)
    local targetPos = target.Position
    if selectedWeapon == "Gun Kill" then
        local item = v3item.inventory.getEquippedItem()
        if item and item.type == "Gun" then
            if item.ammoManager and item.ammoManager.ammo <= 0 then
                FireServer("reload", item.guid)
                return
            end

            if selectedGun == "Raygun" then
                local g = devv.load("GUID")()
                createTrace(targetPos)
                FireServer("replicateProjectiles", item.guid, {{g, target.CFrame}}, item.firemode)
                FireServer("projectileHit", g, "player", {
                    hitSize = target.Size,
                    hitPart = target,
                    pos = targetPos,
                    hitPlayerId = Players:GetPlayerFromCharacter(target.Parent).UserId
                })
                if item.ammoManager then
                    item.ammoManager.ammo = item.ammoManager.ammo - 1
                end
                return
            end

            local g = devv.load("GUID")()
            createTrace(targetPos)
            FireServer("replicateProjectiles", item.guid, {{g, target.CFrame}}, item.firemode)
            FireServer("projectileHit", g, "player", {
                hitSize = target.Size,
                hitPart = target,
                pos = targetPos,
                hitPlayerId = Players:GetPlayerFromCharacter(target.Parent).UserId
            })
            if item.ammoManager then
                item.ammoManager.ammo = item.ammoManager.ammo - 1
            end
        end
    else
        if bladeid then
            createTrace(targetPos)
            InvokeServer("hitSticky", bladeid, target, target.CFrame, target.CFrame)
        end
    end
end

local function auraHeartbeat()
    local myChar = LocalPlayer.Character
    if not myChar or not getRoot(myChar) then return end
    local myRoot = getRoot(myChar)
    local targetHead = nil
    local minDist = math.huge

    local shouldSkipFriend = (#targetPlayers == 0)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local isTarget = false
            if #targetPlayers > 0 then
                isTarget = tableFind(targetPlayers, player.Name)
            else
                isTarget = true
            end

            if isTarget and not player.Character:FindFirstChildOfClass("ForceField") then
                if shouldSkipFriend then
                    if LocalPlayer:IsFriendsWith(player.UserId) then
                        continue
                    end
                end
                local head = player.Character.Head
                local dist = (myRoot.Position - head.Position).Magnitude
                if dist < minDist and (head.Position - avoidPosition).Magnitude > avoidRadius then
                    minDist = dist
                    targetHead = head
                end
            end
        end
    end

    if not targetHead then return end

    if tpplayfb then
        myRoot.CFrame = targetHead.CFrame * CFrame.new(fbx, fby, fbz)
    end

    if aurablade then
        local now = tick()
        local dist = (myRoot.Position - targetHead.Position).Magnitude
        if now - lastAttack >= 0 and dist <= 200000 then
            attackTarget(targetHead)
            lastAttack = now
        end
    end
end

local function updateAuraConnection()
    if aurablade or tpplayfb then
        if not auraConnection then
            auraConnection = RunService.Heartbeat:Connect(auraHeartbeat)
        end
    else
        if auraConnection then auraConnection:Disconnect(); auraConnection = nil end
    end
end

local function setupSilentAimAndRainbow()
    if not v3item.projectiles then return end

    local oldNewProjectile = v3item.projectiles.newProjectileOfType
    v3item.projectiles.newProjectileOfType = function(ptype, pdata)
        if silentaim then
            local target = findTarget()
            if target and pdata.cframe then
                pdata.cframe = CFrame.lookAt(pdata.cframe.Position, target.Position)
            end
        end
        local obj = oldNewProjectile(ptype, pdata)
        if RAINBOW_TRACE and pdata and pdata.cframe and pdata.Owner == LocalPlayer then
            createRainbowTrace(pdata.cframe)
        end
        return obj
    end
end
setupSilentAimAndRainbow()

local function buyMaskIfNeeded()
    if not maskAutoBuy or maskBuying then return end
    local char = LocalPlayer.Character
    if not char then return end

    local maskName = maskNames[selectedMaskType]
    if not maskName then return end

    if char:FindFirstChild(maskName) then return end

    maskBuying = true
    local root = getRoot(char)
    if root then
        local buyLoc = maskLocations[selectedMaskType]
        local offsetX = math.random(-8, 8)
        local offsetZ = math.random(-8, 8)
        local randomPos = buyLoc.Position + Vector3.new(offsetX, 0, offsetZ)
        root.CFrame = CFrame.new(randomPos)
        task.wait(0.5)

        InvokeServer("attemptPurchase", maskName)
        task.wait(0.3)
        for _, v in pairs(items) do
            if v.name == maskName then
                FireServer("equip", v.guid)
                FireServer("wearMask", v.guid)
                break
            end
        end
        local startTime = tick()
        while not char:FindFirstChild(maskName) and tick() - startTime < 2 do
            task.wait(0.1)
        end
        if currentMode == "AFK" then
            root.CFrame = getCurrentIdleCF()
        end
    end
    maskBuying = false
end

local function runATMPhase()
    local atms = workspace:FindFirstChild("ATMs")
    if not atms then return end
    local root = getRoot(LocalPlayer.Character)
    if not root then return end

    local originalCF = root.CFrame

    local nearestATM, nearestDist = nil, math.huge
    for _, atm in ipairs(atms:GetChildren()) do
        if atm:IsA("Model") and (atm:GetAttribute("health") or 0) ~= 0 then
            local main = atm:FindFirstChild("Main")
            if main and main:IsA("BasePart") then
                local dist = (root.Position - main.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestATM = atm
                end
            end
        end
    end
    if not nearestATM then return end

    local main = nearestATM:FindFirstChild("Main")
    local targetPos = main.Position + Vector3.new(0, -4, 0)
    local backDir = -main.CFrame.LookVector
    local yaw = math.atan2(backDir.X, backDir.Z) + atmYawOffset
    local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, yaw)

    local lockConn = RunService.Heartbeat:Connect(function()
        if root and root.Parent then
            root.CFrame = targetCF
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end)

    task.wait(0.8)
    nearestATM:SetAttribute("health", 0)
    task.wait(1.4)

    if lockConn then lockConn:Disconnect() end

    if currentMode == "AFK" then
        root.CFrame = getCurrentIdleCF()
    else
        root.CFrame = originalCF
    end
end

local function ensureItem(itemName, buyLocation)
    for _, v in pairs(items) do
        if v.name == itemName then return v.guid end
    end
    local root = getRoot(LocalPlayer.Character)
    if root then
        local originalCF = root.CFrame
        root.CFrame = buyLocation
        local lockConn = RunService.Heartbeat:Connect(function()
            if root and root.Parent then
                root.CFrame = buyLocation
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
        end)
        task.wait(0.5)
        InvokeServer("attemptPurchase", itemName)
        task.wait(0.5)
        if lockConn then lockConn:Disconnect() end
        root.CFrame = originalCF
    end
    for _, v in pairs(items) do
        if v.name == itemName then return v.guid end
    end
    return nil
end

local function tryGemRubble()
    local rubble = workspace:FindFirstChild("GemRobbery") and workspace.GemRobbery:FindFirstChild("Rubble")
    if not rubble or not rubble:IsDescendantOf(workspace) then return false end

    local tntGuid = getGuid("TNT")
    if not tntGuid then
        local root = getRoot(LocalPlayer.Character)
        if not root then return false end
        local originalCF = root.CFrame
        local targetCF = CFrame.new(grenadeBuyLocation.Position + Vector3.new(0, -2, 0))
        root.CFrame = targetCF
        local lockConn = RunService.Heartbeat:Connect(function()
            if root and root.Parent then
                root.CFrame = targetCF
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
        end)
        task.wait(0.5)
        InvokeServer("attemptPurchase", "TNT")
        task.wait(0.5)
        if lockConn then lockConn:Disconnect() end
        refreshItems()
        tntGuid = getGuid("TNT")
        root.CFrame = originalCF
        if not tntGuid then return false end
    end

    local root = getRoot(LocalPlayer.Character)
    if not root then return false end
    local originalCF = root.CFrame

    local standCFrame = CFrame.new(1694, 22, -725)
    local throwTarget = Vector3.new(1700, 16, -721)

    root.CFrame = standCFrame
    FireServer("equip", tntGuid)
    task.wait(0.2)
    FireServer("throwItem", tntGuid, Vector3.new(5.2, 29.9, 79.3), throwTarget)
    task.wait(0.5)
    FireServer("removeItem", tntGuid)

    if currentMode == "AFK" then
        root.CFrame = getCurrentIdleCF()
    else
        root.CFrame = originalCF
    end
    return true
end

local function tryBankHeist()
    local bank = workspace:FindFirstChild("BankRobbery")
    if not bank then return false end
    local cashFolder = bank:FindFirstChild("BankCash") and bank.BankCash:FindFirstChild("Cash")
    if not cashFolder or #cashFolder:GetChildren() == 0 then return false end

    local adjustedGrenadeLoc = CFrame.new(grenadeBuyLocation.Position + Vector3.new(0, -2, 0))
    local fragGuid = ensureItem("Frag", adjustedGrenadeLoc)
    if not fragGuid then return false end

    local root = getRoot(LocalPlayer.Character)
    if not root then return false end

    local originalCF = root.CFrame

    root.CFrame = bombThrowLocation
    task.wait(0.3)
    FireServer("equip", fragGuid)
    task.wait(0.1)
    local direction = (bombTargetPosition - root.Position).Unit
    FireServer("throwItem", fragGuid, direction, bombTargetPosition)
    FireServer("removeItem", fragGuid)
    task.wait(1.5)

    bank = workspace:FindFirstChild("BankRobbery")
    if not bank then return false end
    local promptPart = bank:FindFirstChild("BankCash") and bank.BankCash:FindFirstChild("Main")
    local prompt = promptPart and promptPart:FindFirstChild("Attachment") and promptPart.Attachment:FindFirstChild("ProximityPrompt")
    if not prompt or not prompt.Enabled then return false end

    root = getRoot(LocalPlayer.Character)
    if not root then return false end

    root.CFrame = afterExplosionWaitLocation
    local lockPos = (afterExplosionWaitLocation * CFrame.new(0, 0, -4)).Position
    local lockCF = CFrame.new(lockPos) * CFrame.Angles(math.rad(90), 0, 0)
    local collectCF = CFrame.new((bank.BankCash.Pallet.CFrame * CFrame.new(0, -2, 0)).Position) * CFrame.Angles(math.rad(90), 0, 0)

    local lockConn
    local currentLockCF = lockCF
    lockConn = RunService.Heartbeat:Connect(function()
        local currentRoot = getRoot(LocalPlayer.Character)
        if currentRoot and currentRoot.Parent then
            currentRoot.CFrame = currentLockCF
            currentRoot.Velocity = Vector3.zero
            currentRoot.RotVelocity = Vector3.zero
        end
    end)

    task.wait(4)

    currentLockCF = collectCF

    local cashConnection
    cashConnection = RunService.Heartbeat:Connect(function()
        if not cashFolder or not cashFolder.Parent or #cashFolder:GetChildren() == 0 then
            if cashConnection then cashConnection:Disconnect() end
            return
        end
        pcall(function() fireproximityprompt(prompt) end)
    end)

    repeat task.wait(0.2) until not prompt.Enabled or #cashFolder:GetChildren() == 0
    if cashConnection then cashConnection:Disconnect() end
    if lockConn then lockConn:Disconnect() end

    root = getRoot(LocalPlayer.Character)
    if root then
        if currentMode == "AFK" then
            root.CFrame = getCurrentIdleCF()
        else
            root.CFrame = originalCF
        end
    end
    return true
end

local function runJewelPhase()
    local gemRobbery = workspace:FindFirstChild("GemRobbery")
    if not gemRobbery then return false end
    local cases = gemRobbery:FindFirstChild("JewelryCases")
    if not cases then return false end

    local root = getRoot(LocalPlayer.Character)
    if not root then return false end
    local originalCF = root.CFrame

    for _, descendant in pairs(cases:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Steal" and descendant.Enabled then
            descendant.HoldDuration = 0
            descendant.RequiresLineOfSight = false
            local targetPos = descendant.Parent:GetPivot().Position
            root.CFrame = CFrame.new(targetPos)
            task.wait(0.1)
            fireproximityprompt(descendant)

            if currentMode == "AFK" then
                root.CFrame = getCurrentIdleCF()
            else
                root.CFrame = originalCF
            end
            return true
        end
    end
    return false
end

local function runItemFindPhase()
    local did = false
    if autoblock then
        if Autoitem("Green Lucky Block") then did = true end
        if Autoitem("Orange Lucky Block") then did = true end
        if Autoitem("Purple Lucky Block") then did = true end
    end
    if automoss then
        if Autoitem("Medium Present") then did = true end
        if Autoitem("Large Present") then did = true end
    end
    if autoxybs then
        if Autoitem("Diamond") then did = true end
        if Autoitem("Void Gem") then did = true end
        if Autoitem("Dark Matter Gem") then did = true end
        if Autoitem("Rollie") then did = true end
        if Autoitem("Gold Crown") then did = true end
        if Autoitem("Gold Cup") then did = true end
        if Autoitem("Pearl Necklace") then did = true end
    end
    if autoxywp then
        if Autoitem("Blue Candy Cane") then did = true end
        if Autoitem("Suitcase Nuke") then did = true end
        if Autoitem("Nuke Launcher") then did = true end
        if Autoitem("Easter Basket") then did = true end
        if Autoitem("Gold Cup") then did = true end
        if Autoitem("Gold Crown") then did = true end
        if Autoitem("Treasure Map") then did = true end
        if Autoitem("Spectral Scythe") then did = true end
    end
    if autoptbs then
        if Autoitem("Amethyst") then did = true end
        if Autoitem("Sapphire") then did = true end
        if Autoitem("Emerald") then did = true end
        if Autoitem("Topaz") then did = true end
        if Autoitem("Ruby") then did = true end
    end
    if automoney then
        if Autoitem("Money Printer") then did = true end
    end
    if card then
        local has = false
        for _, v in pairs(items) do if v.name == "Military Armory Keycard" then has = true break end end
        if not has then
            if Autoitem("Military Armory Keycard") then did = true end
        end
    end

    return did
end

local function runSafePhase()
    local lockGuid = getGuid("Lockpick")
    if not lockGuid then
        local root = getRoot(LocalPlayer.Character)
        if root then
            local originalCF = root.CFrame
            local targetCF = CFrame.new(lockpickBuyLocation.Position + Vector3.new(0, -2, 0))
            root.CFrame = targetCF
            local lockConn = RunService.Heartbeat:Connect(function()
                if root and root.Parent then
                    root.CFrame = targetCF
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                end
            end)
            task.wait(0.5)
            InvokeServer("attemptPurchase", "Lockpick")
            task.wait(0.8)
            if lockConn then lockConn:Disconnect() end
            refreshItems()
            root.CFrame = originalCF
        end
        return false
    end

    local chestTypes = {"SmallSafe","MediumSafe","LargeSafe","JewelSafe","GoldJewelSafe"}
    for _, ct in pairs(chestTypes) do
        local folder = workspace.Game.Entities:FindFirstChild(ct)
        if folder then
            for _, chest in pairs(folder:GetChildren()) do
                if chest.PrimaryPart then
                    local prompt = chest:FindFirstChild("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        local root = getRoot(LocalPlayer.Character)
                        if root then
                            local originalCF = root.CFrame
                            local lockCF = CFrame.new(chest.PrimaryPart.Position - Vector3.new(0,3,0)) * CFrame.Angles(math.rad(90), 0, 0)
                            root.CFrame = lockCF

                            local lockConn = RunService.Heartbeat:Connect(function()
                                if root and root.Parent then
                                    root.CFrame = lockCF
                                    root.Velocity = Vector3.zero
                                    root.RotVelocity = Vector3.zero
                                end
                            end)

                            fireproximityprompt(prompt)
                            task.wait(3.0)

                            if lockConn then lockConn:Disconnect() end
                            if currentMode == "AFK" then
                                root.CFrame = getCurrentIdleCF()
                            else
                                root.CFrame = originalCF
                            end
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function runTreasurePhase()
    return false
end

local function startUnlockAura()
    if unlockAuraConnection then unlockAuraConnection:Disconnect() end
    unlockAuraConnection = RunService.Heartbeat:Connect(function()
        if not autoUnlockEnabled then return end
        local char = LocalPlayer.Character
        local root = getRoot(char)
        if not root then return end

        local lockGuid = getGuid("Lockpick")
        if not lockGuid then
            InvokeServer("attemptPurchase", "Lockpick")
        end

        local safeTypes = {"LargeSafe", "MediumSafe", "SmallSafe", "JewelSafe", "GoldJewelSafe"}
        for _, safeType in ipairs(safeTypes) do
            local folder = workspace.Game.Entities:FindFirstChild(safeType)
            if folder then
                for _, safe in ipairs(folder:GetChildren()) do
                    if safe:FindFirstChild("ProximityPrompt", true) then
                        local distance = (root.Position - safe:GetPivot().Position).Magnitude
                        if distance <= 45 then
                            pcall(function()
                                fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function stopUnlockAura()
    if unlockAuraConnection then
        unlockAuraConnection:Disconnect()
        unlockAuraConnection = nil
    end
end

local function startCashAura()
    cashAuraConnection = RunService.Heartbeat:Connect(function()
        if not cashAuraEnabled then return end
        local root = getRoot(LocalPlayer.Character)
        if not root then return end
        local cashBundles = workspace.Game.Entities.CashBundle
        for _, cash in pairs(cashBundles:GetChildren()) do
            if not cashAuraEnabled then break end
            local part = cash:FindFirstChildOfClass("Part")
            if part and (root.Position - part.Position).Magnitude <= 30 then
                local clickDetector = cash:FindFirstChildOfClass("ClickDetector") or part:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                end
            end
        end
    end)
end

local function stopCashAura()
    if cashAuraConnection then
        cashAuraConnection:Disconnect()
        cashAuraConnection = nil
    end
end

local valuableItems = {
    "Dark Matter Gem", "Void Gem", "Diamond Ring", "Diamond", "Rollie",
    "Watch", "Glock 18", "AR-15", "Amethyst", "Sapphire",
    "Ruby", "AK-47", "Glock",
    "Raygun", "Gold AK-47", "Gold Deagle", "AS Val", "AUG", "Acid Gun",
    "P90", "RPK", "Sawn Off", "Scar L", "Saiga 12", "Tommy Gun",
    "Double Barrel", "Deagle", "Dragunov", "Flamethrower", "M249 SAW",
    "MP7", "Minigun", "M4A1", "Barrett M107", "Gravity Gun",
    "Gold Lucky Block", "Orange Lucky Block", "Purple Lucky Block",
    "Green Lucky Block", "Red Lucky Block", "Blue Lucky Block",
    "Treasure Map", "Pearl Necklace", "Military Armory Keycard",
    "Police Armory Keycard", "Money Printer", "RPG", "Trident",
    "Gold Crown", "Gold Cup", "Heavy Vest", "Military Vest",
    "Electronics", "Weapon Parts"
}

local function startItemAura()
    if itemAuraConnection then itemAuraConnection:Disconnect(); itemAuraConnection = nil end
    itemAuraTimer = 0
    itemAuraConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not itemAuraEnabled then return end
        itemAuraTimer = itemAuraTimer + deltaTime
        if itemAuraTimer < ITEM_AURA_INTERVAL then return end
        itemAuraTimer = 0

        local root = getRoot(LocalPlayer.Character)
        if not root then return end
        local itemPickup = workspace.Game.Entities.ItemPickup
        for _, item in pairs(itemPickup:GetChildren()) do
            if not itemAuraEnabled then break end
            local mainPart = item:FindFirstChildOfClass("Part") or item:FindFirstChildWhichIsA("BasePart")
            if mainPart and (root.Position - mainPart.Position).Magnitude <= 27 then
                local itemName = item:GetAttribute("itemName") or (mainPart:GetAttribute("itemName"))
                if itemName then
                    for _, vname in pairs(valuableItems) do
                        if itemName == vname then
                            local click = item:FindFirstChildOfClass("ClickDetector") or mainPart:FindFirstChildOfClass("ClickDetector")
                            if click then
                                fireclickdetector(click)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function stopItemAura()
    if itemAuraConnection then
        itemAuraConnection:Disconnect()
        itemAuraConnection = nil
        itemAuraTimer = 0
    end
end

local function updateIdleConnection()
    if idleConnection then idleConnection:Disconnect(); idleConnection = nil end
    if currentMode == "AFK" then
        local targetCF = getCurrentIdleCF()
        idleConnection = RunService.Heartbeat:Connect(function()
            if not busy and not maskBuying then
                local root = getRoot(LocalPlayer.Character)
                if root and root.Parent then
                    root.CFrame = targetCF
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                end
            end
        end)
    end
end

local function ensureSpecialWeapon(weaponName, buyLocation)
    local guid = getGuid(weaponName)
    if not guid then
        local root = getRoot(LocalPlayer.Character)
        if root then
            local originalCF = root.CFrame
            root.CFrame = buyLocation
            task.wait(0.5)
            InvokeServer("attemptPurchase", weaponName)
            task.wait(0.5)
            refreshItems()
            root.CFrame = originalCF
        end
    else
        FireServer("equip", guid)
    end
end

local function ensureRPG()
    local hasRPG = false
    for _, v in pairs(items) do
        if v.name == "RPG" or v.name == "Trident" then
            hasRPG = true
            FireServer("equip", v.guid)
            break
        end
    end
    if not hasRPG then
        local root = getRoot(LocalPlayer.Character)
        if root then
            local originalCF = root.CFrame
            root.CFrame = rpgBuyLocation
            task.wait(0.5)
            InvokeServer("attemptPurchase", "RPG")
            task.wait(0.3)
            refreshItems()
            for _, v in pairs(items) do
                if v.name == "RPG" then
                    FireServer("equip", v.guid)
                    break
                end
            end
            root.CFrame = originalCF
        end
    end
end

local function startFlameAttack()
    task.spawn(function()
        local same = {GUID()}
        while flameAttackEnabled do
            if not LocalPlayer.Character or not getRoot(LocalPlayer.Character) then
                task.wait(0.5)
            else
                local equippedItem = v3item.inventory.getEquippedItem()
                if not equippedItem or (equippedItem.name ~= "Flamethrower" and equippedItem.name ~= "Acid Gun") then
                    if not getGuid("Flamethrower") and not getGuid("Acid Gun") then
                        ensureSpecialWeapon("Flamethrower", flamethrowerBuyLocation)
                    end
                    task.wait(0.5)
                else
                    local equippedGUID = equippedItem.guid
                    local equippedName = equippedItem.name
                    local currentAmmo = equippedItem.ammoManager and equippedItem.ammoManager.ammo or 0

                    if currentAmmo <= 0 then
                        FireServer("reload", equippedGUID)
                        task.wait(0.2)
                    else
                        local friendIDs = {}
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local success, isFriend = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
                                if success and isFriend then
                                    table.insert(friendIDs, player.UserId)
                                end
                            end
                        end

                        local myRoot = getRoot(LocalPlayer.Character)
                        if myRoot then
                            for _, player in pairs(Players:GetPlayers()) do
                                if not flameAttackEnabled then break end
                                if player ~= LocalPlayer and player.Character then
                                    local isTarget = false
                                    if #targetPlayers > 0 then
                                        isTarget = tableFind(targetPlayers, player.Name)
                                    else
                                        isTarget = true
                                    end

                                    if isTarget then
                                        local isFriend = false
                                        for _, friendID in pairs(friendIDs) do
                                            if player.UserId == friendID then
                                                isFriend = true
                                                break
                                            end
                                        end
                                        if not isFriend then
                                            local character = player.Character
                                            local humanoid = character:FindFirstChild("Humanoid")
                                            local targetPart = character:FindFirstChild(hitPart)
                                            if humanoid and targetPart and humanoid.Health > 0 then
                                                local targetRoot = character:FindFirstChild("HumanoidRootPart")
                                                if targetRoot then
                                                    local distance = (myRoot.Position - targetRoot.Position).magnitude
                                                    if distance <= flameAttackDistance then
                                                        FireServer("replicateProjectiles", equippedGUID, { { same[1], targetPart.CFrame } }, "auto")
                                                        if equippedName == "Flamethrower" then
                                                            FireServer("flameHit", same[1], GUID(), targetPart.Position)
                                                        elseif equippedName == "Acid Gun" then
                                                            FireServer("acidHit", same[1], GUID(), targetPart.Position)
                                                        end
                                                        FireServer("projectileHit", same[1], "player", {
                                                            hitPart = targetPart,
                                                            hitPlayerId = player.UserId,
                                                            hitSize = targetPart.Size,
                                                            pos = targetPart.Position
                                                        })
                                                        if equippedItem.ammoManager then
                                                            equippedItem.ammoManager.ammo = equippedItem.ammoManager.ammo - 1
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function startRPGAttack()
    task.spawn(function()
        ensureRPG()
        local same = {GUID()}
        while rpgAttackEnabled do
            if not LocalPlayer.Character or not getRoot(LocalPlayer.Character) then
                task.wait(0.5)
            else
                local equippedItem = v3item.inventory.getEquippedItem()
                if not equippedItem or (equippedItem.name ~= "RPG" and equippedItem.name ~= "Trident") then
                    task.wait(0.1)
                else
                    local equippedGUID = equippedItem.guid
                    local equippedName = equippedItem.name

                    local friendIDs = {}
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local success, isFriend = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
                            if success and isFriend then
                                table.insert(friendIDs, player.UserId)
                            end
                        end
                    end

                    local myRoot = getRoot(LocalPlayer.Character)
                    if myRoot then
                        for _, player in pairs(Players:GetPlayers()) do
                            if not rpgAttackEnabled then break end
                            if player ~= LocalPlayer and player.Character then
                                local isTarget = false
                                if #targetPlayers > 0 then
                                    isTarget = tableFind(targetPlayers, player.Name)
                                else
                                    isTarget = true
                                end

                                if isTarget then
                                    local isFriend = false
                                    for _, friendID in pairs(friendIDs) do
                                        if player.UserId == friendID then
                                            isFriend = true
                                            break
                                        end
                                    end
                                    if not isFriend then
                                        local character = player.Character
                                        local humanoid = character:FindFirstChild("Humanoid")
                                        local targetPart = character:FindFirstChild(hitPart)
                                        local targetRoot = character:FindFirstChild("HumanoidRootPart")
                                        if humanoid and targetPart and targetRoot and humanoid.Health > rpgMinHealth then
                                            local distance = (myRoot.Position - targetRoot.Position).magnitude
                                            if distance <= rpgAttackDistance then
                                                local replicateArgs = {equippedGUID}
                                                local projectileData = {{same[1], targetPart.CFrame}}
                                                replicateArgs[2] = projectileData
                                                replicateArgs[3] = "semi"
                                                FireServer("replicateProjectiles", unpack(replicateArgs))
                                                local rocketArgs = {same[1], GUID(), targetPart.Position}
                                                for i = 1, 5 do
                                                    FireServer("rocketHit", unpack(rocketArgs))
                                                end
                                                FireServer("reload", equippedGUID)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function performCrafting()
    if autoCraftEnabled then
        Signal.InvokeServer("beginCraft", 'RollieCraft')
    end
    if autoClaimEnabled then
        Signal.InvokeServer("claimCraft", 'RollieCraft')
    end
end

local function storeGems()
    local housingPlots = workspace:FindFirstChild("HousingPlots")
    if not housingPlots then return end
    local items = v3item.inventory.items
    for _, v in pairs(housingPlots:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local action = v.ActionText
            if action == "Add Gem" or action == "Equip a Gem" then
                local houseid = v.Parent.Parent.Name
                local hitid = v.Parent.Name
                for _, item in pairs(items) do
                    if item.name == "Diamond" or item.name == "Rollie" or item.name == "Dark Matter Gem" or
                       item.name == "Diamond Ring" or item.name == "Void Gem" then
                        FireServer("equip", item.guid)
                        FireServer("updateGemDisplay", houseid, hitid, item.guid)
                    end
                end
            end
        end
    end
end

local function stompAura()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            if targetHRP and targetHumanoid and targetHumanoid.Health < 20 then
                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= 40 then
                    FireServer("finish", player)
                end
            end
        end
    end
end

local function grabAura()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            if targetHRP and targetHumanoid and targetHumanoid.Health < 20 then
                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= 40 then
                    FireServer("grabPlayer", player)
                end
            end
        end
    end
end

local function executeCashRegister()
    local regFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Props") and workspace.Game.Props:FindFirstChild("CashRegister")
    if not regFolder then return false end
    local aliveRegs = {}
    for _, v in pairs(regFolder:GetChildren()) do
        if v:IsA("Model") and v:GetAttribute("state") ~= "destroyed" then
            table.insert(aliveRegs, v)
        end
    end
    if #aliveRegs == 0 then return false end

    local fistsGuid = nil
    for _, v in pairs(items) do
        if v.name == "Fists" then
            fistsGuid = v.guid
            break
        end
    end
    if not fistsGuid then return false end

    local root = getRoot(LocalPlayer.Character)
    if not root then return false end

    for _, target in ipairs(aliveRegs) do
        if not autoCashRegister then break end
        local targetCFrame = target.WorldPivot * CFrame.new(0, -5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        root.CFrame = targetCFrame
        FireServer("equip", fistsGuid)
        local lockConn = RunService.Heartbeat:Connect(function()
            if root and root.Parent then
                root.CFrame = targetCFrame
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
        end)
        local startTime = tick()
        while tick() - startTime < 2 do
            if not autoCashRegister then break end
            for _, reg in ipairs(aliveRegs) do
                local rGuid = reg:GetAttribute("guid")
                if rGuid and reg:GetAttribute("state") ~= "destroyed" and (root.Position - reg.WorldPivot.Position).Magnitude <= 30 then
                    pcall(function()
                        local attackName = tostring(getupvalue(Signal.FireServer, 1)["attackMeleeHit"])
                        game:GetService("ReplicatedStorage").devv.remoteStorage[attackName]:FireServer("prop", {meleeType = "meleepunch", guid = rGuid})
                    end)
                end
            end
            task.wait(0.1)
        end
        if lockConn then lockConn:Disconnect() end
    end
    return true
end

local function startPunchAura()
    if punchRunning then return end
    punchRunning = true
    punchConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local fistsGuid = nil
        for _, v in pairs(items) do
            if v.name == "Fists" then
                fistsGuid = v.guid
                break
            end
        end
        if not fistsGuid then return end
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if (myPos - player.Character.HumanoidRootPart.Position).Magnitude <= 35 then
                    task.spawn(function()
                        FireServer("equip", fistsGuid)
                        pcall(function()
                            FireServer("attackMeleeHit", "player", {meleeType = punchType, hitPlayerId = player.UserId, weaponGUID = fistsGuid})
                        end)
                    end)
                end
            end
        end
    end)
end

local function stopPunchAura()
    punchRunning = false
    if punchConnection then
        punchConnection:Disconnect()
        punchConnection = nil
    end
end

task.spawn(function()
    while true do
        task.wait(1)

        if autoBuyGunAmmo and selectedWeapon == "Gun Kill" and selectedGun ~= "Raygun" then
            gunBuyTimer = gunBuyTimer + 1
            if gunBuyTimer >= gunBuyInterval then
                gunBuyTimer = 0
                local item = v3item.inventory.getEquippedItem()
                if item and item.type == "Gun" and item.name == selectedGun then
                    local buyLoc = gunBuyLocations[selectedGun]
                    local root = getRoot(LocalPlayer.Character)
                    if root and buyLoc then
                        local originalCF = root.CFrame
                        root.CFrame = buyLoc
                        task.wait(0.5)
                        for i = 1, BUY_AMMO_COUNT do
                            InvokeServer("attemptPurchaseAmmo", item.name)
                            task.wait(0.1)
                        end
                        root.CFrame = originalCF
                    end
                end
            end
        else
            gunBuyTimer = 0
        end

        if autoBuyFlameAmmo and flameAttackEnabled then
            flameBuyTimer = flameBuyTimer + 1
            if flameBuyTimer >= flameBuyInterval then
                flameBuyTimer = 0
                local equippedItem = v3item.inventory.getEquippedItem()
                if equippedItem and (equippedItem.name == "Flamethrower" or equippedItem.name == "Acid Gun") then
                    local root = getRoot(LocalPlayer.Character)
                    if root then
                        local originalCF = root.CFrame
                        local buyLoc = flamethrowerBuyLocation
                        root.CFrame = buyLoc
                        local startTime = tick()
                        while tick() - startTime < 2 do
                            InvokeServer("attemptPurchaseAmmo", equippedItem.name)
                            task.wait(0.05)
                        end
                        root.CFrame = originalCF
                    end
                end
            end
        else
            flameBuyTimer = 0
        end

        if autoBuyRPGAmmo and rpgAttackEnabled then
            rpgBuyTimer = rpgBuyTimer + 1
            if rpgBuyTimer >= rpgBuyInterval then
                rpgBuyTimer = 0
                local equippedItem = v3item.inventory.getEquippedItem()
                if equippedItem and (equippedItem.name == "RPG" or equippedItem.name == "Trident") then
                    local root = getRoot(LocalPlayer.Character)
                    if root then
                        local originalCF = root.CFrame
                        local buyLoc = rpgBuyLocation
                        root.CFrame = buyLoc
                        local startTime = tick()
                        while tick() - startTime < 3 do
                            InvokeServer("attemptPurchaseAmmo", equippedItem.name)
                            task.wait(0.05)
                        end
                        root.CFrame = originalCF
                    end
                end
            end
        else
            rpgBuyTimer = 0
        end
    end
end)

local function setupUI()
    local Tabs = {
        Player = Window:AddTab('玩家', 'user'),
        Visual = Window:AddTab('视觉', 'eye'),
        Ohio = Window:AddTab('主要', 'crosshair'),
        SpecialAttack = Window:AddTab('特殊攻击', 'zap'),
        Misc = Window:AddTab('杂项', 'wrench'),
        ["UI Settings"] = Window:AddTab('UI 调试', 'settings')
    }

    local function getPlayerListValues()
        local names = {"关闭"}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        return names
    end

    do
        local SpecialGroup1 = Tabs.SpecialAttack:AddLeftGroupbox('火焰/酸液攻击')
        SpecialGroup1:AddSlider('flameDistance', {
            Text = '攻击距离',
            Min = 1,
            Max = 10000,
            Default = 10000,
            Callback = function(v) flameAttackDistance = v end
        })
        SpecialGroup1:AddToggle('flameAttack', {
            Text = '火焰/酸液攻击',
            Default = false,
            Callback = function(s)
                flameAttackEnabled = s
                if s then
                    startFlameAttack()
                end
            end
        })
    end

    do
        local SpecialGroup2 = Tabs.SpecialAttack:AddRightGroupbox('RPG/三叉戟攻击')
        SpecialGroup2:AddSlider('rpgDistance', {
            Text = '攻击距离',
            Min = 1,
            Max = 5000,
            Default = 100,
            Callback = function(v) rpgAttackDistance = v end
        })
        SpecialGroup2:AddSlider('rpgMinHealth', {
            Text = '最低血量',
            Min = 0.1,
            Max = 1,
            Default = 0.3,
            Callback = function(v) rpgMinHealth = v end
        })
        SpecialGroup2:AddToggle('rpgAttack', {
            Text = 'RPG/三叉戟攻击',
            Default = false,
            Callback = function(s)
                rpgAttackEnabled = s
                if s then
                    startRPGAttack()
                end
            end
        })
    end

    do
        local PlayerGroup = Tabs.Player:AddLeftGroupbox('移动')
        PlayerGroup:AddSlider('flySpeed', { Text = '飞行速度', Min = 10, Max = 200, Default = 50, Callback = function(v) flySpeed = v end })
        PlayerGroup:AddToggle('flyToggle', { Text = '飞行模式（谨慎使用）', Default = false, Callback = function(s) if s then startFly() else stopFly() end end })
        PlayerGroup:AddSlider('moveSpeed', { Text = '移动速度', Min = 1, Max = 1000, Default = 10, Callback = function(v) currentSpeed = v end })
        PlayerGroup:AddToggle('speedToggle', { Text = '加速', Default = false, Callback = function(s) if s then startTPWalk() else stopTPWalk() end end })
    end

    do
        local PlayerGroup2 = Tabs.Player:AddRightGroupbox('角色')
        PlayerGroup2:AddToggle('transparentToggle', { Text = '透明', Default = false, Callback = toggleTransparent })
        PlayerGroup2:AddToggle('bunnyHopToggle', { Text = '连跳', Default = false, Callback = toggleBunnyHop })
        PlayerGroup2:AddToggle('noClipToggle', { Text = '穿墙', Default = false, Callback = toggleNoClip })
        PlayerGroup2:AddToggle('antiVoidToggle', { Text = '防虚空掉落', Default = false, Callback = toggleAntiVoid })
    end

    do
        local VisualGroup = Tabs.Visual:AddLeftGroupbox('ESP 设置')
        VisualGroup:AddToggle('espMaster', { Text = '开启 ESP', Default = false, Callback = toggleESP })
        VisualGroup:AddToggle('espName', { Text = '显示玩家名', Default = true, Callback = function(s) DrawingConfig.NameEnabled = s end })
        VisualGroup:AddToggle('espDist', { Text = '显示距离', Default = true, Callback = function(s) DrawingConfig.DistanceEnabled = s end })
        VisualGroup:AddToggle('espHP', { Text = '显示 HP', Default = true, Callback = function(s) DrawingConfig.HealthText = s end })
    end

    do
        local KillGroup = Tabs.Ohio:AddLeftGroupbox('击杀')
        local playerDropdown = KillGroup:AddDropdown('targetPlayers', {
            Text = '选择目标玩家',
            Desc = '选择"关闭"则攻击所有玩家，选择玩家则只攻击该玩家',
            Values = getPlayerListValues(),
            Default = '关闭',
            Multi = false,
            Callback = function(value)
                if not value or value == '' or value == '关闭' then
                    targetPlayers = {}
                    return
                end
                targetPlayers = {}
                local player = Players:FindFirstChild(value)
                if player then
                    table.insert(targetPlayers, value)
                end
            end
        })

        KillGroup:AddButton('刷新玩家列表', function()
            local newList = getPlayerListValues()
            if playerDropdown then
                pcall(function()
                    if playerDropdown.SetValues then
                        playerDropdown:SetValues(newList)
                    elseif playerDropdown.SetOptions then
                        playerDropdown:SetOptions(newList)
                    elseif playerDropdown.Refresh then
                        playerDropdown:Refresh(newList, true)
                    elseif playerDropdown.Values ~= nil then
                        playerDropdown.Values = newList
                    end
                end)
            end
        end)

        KillGroup:AddDropdown('killMethod', {
            Text = '击杀方式',
            Values = {'Ninja Star', 'Tomahawk', 'Banana Peel', 'Gun Kill'},
            Default = 'Ninja Star',
            Multi = false,
            Callback = function(v)
                selectedWeapon = (v[1] or v)
            end
        })
        KillGroup:AddDropdown('gunSelect', {
            Text = '选择枪械',
            Values = {'Raygun', 'M4A1', 'AK47'},
            Default = 'Raygun',
            Multi = false,
            Callback = function(v)
                selectedGun = (v[1] or v)
            end
        })
        KillGroup:AddToggle('autoKill', {
            Text = '自动击杀',
            Default = false,
            Callback = function(s)
                aurablade = s
                if s then prepareWeapon() end
                updateAuraConnection()
            end
        })
        KillGroup:AddToggle('tpPlayer', {
            Text = 'TP玩家',
            Default = false,
            Callback = function(s) tpplayfb = s; updateAuraConnection() end
        })
        KillGroup:AddSlider('fbx', { Text = 'X 偏移', Min = -20, Max = 20, Default = 0, Callback = function(v) fbx = v end })
        KillGroup:AddSlider('fby', { Text = 'Y 偏移', Min = -20, Max = 20, Default = 0, Callback = function(v) fby = v end })
        KillGroup:AddSlider('fbz', { Text = 'Z 偏移', Min = -20, Max = 20, Default = 5, Callback = function(v) fbz = v end })
    end

    do
        local AmmoGroup = Tabs.Ohio:AddRightGroupbox('弹药自动购买')
        AmmoGroup:AddToggle('autoBuyGunAmmo', {
            Text = '击杀枪自动买弹药（M4/AK）',
            Desc = '每10秒传送购买大量弹药',
            Default = false,
            Callback = function(s)
                autoBuyGunAmmo = s
                if s then
                    gunBuyTimer = 0
                end
            end
        })
        AmmoGroup:AddToggle('autoBuyFlameAmmo', {
            Text = '喷火枪自动买弹药（火焰/酸液）',
            Desc = '每15秒传送购买2秒弹药',
            Default = false,
            Callback = function(s)
                autoBuyFlameAmmo = s
                if s then
                    flameBuyTimer = 0
                end
            end
        })
        AmmoGroup:AddToggle('autoBuyRPGAmmo', {
            Text = 'RPG自动买弹药（RPG/三叉戟）',
            Desc = '每10秒传送购买3秒弹药',
            Default = false,
            Callback = function(s)
                autoBuyRPGAmmo = s
                if s then
                    rpgBuyTimer = 0
                end
            end
        })
    end

    task.spawn(function()
        while true do
            task.wait(0.5)
            local newList = getPlayerListValues()
            local killGroup = Tabs.Ohio:GetGroupbox('击杀')
            if killGroup then
                local dropdown = killGroup:GetDropdown('targetPlayers')
                if dropdown then
                    pcall(function()
                        if dropdown.SetValues then
                            dropdown:SetValues(newList)
                        elseif dropdown.SetOptions then
                            dropdown:SetOptions(newList)
                        elseif dropdown.Refresh then
                            dropdown:Refresh(newList, true)
                        elseif dropdown.Values ~= nil then
                            dropdown.Values = newList
                        end
                    end)
                end
            end
        end
    end)

    do
        local CombatGroup = Tabs.Ohio:AddRightGroupbox('战斗')

        CombatGroup:AddDropdown('maskSelect', {
            Text = '口罩选择',
            Values = {'黑色头巾', '红色头巾', '蓝色头巾', '外科医生口罩', '面具'},
            Default = '黑色头巾',
            Callback = function(v)
                selectedMaskType = v
                maskAutoBuy = true
            end
        })

        CombatGroup:AddToggle('autoVest', { Text = '自动护甲', Default = false, Callback = function(s) autovest = s end })
        CombatGroup:AddToggle('autoHeal', { Text = '自动回血', Default = false, Callback = function(s) autohealth = s end })
        CombatGroup:AddToggle('autoMask', { Text = '自动口罩', Default = false, Callback = function(s) autokz = s end })
        CombatGroup:AddToggle('phoneSpam', { Text = '电话骚扰', Default = false, Callback = function(s) callphone = s end })
        CombatGroup:AddToggle('arrestAura', { Text = '逮捕光环', Default = false, Callback = function(s) Auarcuff = s end })
        CombatGroup:AddDivider()
        CombatGroup:AddToggle('autoStomp', {
            Text = '踩踏光环',
            Desc = '踩踏血量低于20的玩家（距离40）',
            Default = false,
            Callback = function(s) autoStomp = s end
        })
        CombatGroup:AddToggle('autoGrab', {
            Text = '抓取光环',
            Desc = '抓取血量低于20的玩家（距离40）',
            Default = false,
            Callback = function(s) autoGrab = s end
        })
        CombatGroup:AddDivider()
        CombatGroup:AddDropdown('punchTypeSelect', {
            Text = '一拳类型',
            Values = {'普通拳', '超级拳'},
            Default = '普通拳',
            Callback = function(val)
                punchType = val == '普通拳' and 'meleepunch' or 'meleemegapunch'
            end
        })
        CombatGroup:AddToggle('onePunchAura', {
            Text = '启用一拳光环',
            Default = false,
            Callback = function(state)
                if state then
                    startPunchAura()
                else
                    stopPunchAura()
                end
            end
        })
    end

    do
        local AutoGroup = Tabs.Ohio:AddLeftGroupbox('自动')

        AutoGroup:AddDropdown('modeSelect', {
            Text = '农场模式',
            Values = {'AFK', 'Normal'},
            Default = 'AFK',
            Callback = function(v)
                currentMode = v
                updateIdleConnection()
            end
        })
        AutoGroup:AddDropdown('idleSelect', {
            Text = '挂机位置',
            Values = {'TeTraX', '宿傩', '位置1', '位置2', '位置3', '位置4', '位置5', '位置6', '位置7', '位置8', '位置9'},
            Default = 'TeTraX',
            Callback = function(v)
                currentIdleName = v
                updateIdleConnection()
            end
        })
        AutoGroup:AddDivider()

        AutoGroup:AddToggle('autoATM', { Text = '自动摧毁ATM', Default = false, Callback = function(s) FromATM = s end })
        AutoGroup:AddToggle('autoBank', { Text = '自动偷盗银行', Default = false, Callback = function(s) FromBank = s end })
        AutoGroup:AddToggle('autoCashRegister', {
            Text = '自动收银机',
            Desc = '依次攻击每个收银机，每个停留2秒（固定位置）',
            Default = false,
            Callback = function(s)
                autoCashRegister = s
            end
        })
        AutoGroup:AddToggle('autoGemRubble', {
            Text = '自动炸珠宝店',
            Desc = '用TNT炸开岩石（每30秒一次）',
            Default = false,
            Callback = function(s)
                autoGemRubble = s
                if not s then gemRubbleCooldown = 0 end
            end
        })

        AutoGroup:AddToggle('autoCollectTruckCash', {
            Text = '自动收集装甲车现金',
            Desc = '自动收集附近装甲车现金',
            Default = false,
            Callback = function(s)
                autoCollectTruckCash = s
                if s then
                    task.spawn(function()
                        while autoCollectTruckCash do
                            local rootPart = getRoot(LocalPlayer.Character)
                            if rootPart then
                                for _, vehicle in pairs(workspace.Game.Vehicles:GetChildren()) do
                                    if vehicle.Name == "Armored Truck" and vehicle:FindFirstChild("TruckCash") and (rootPart.Position - vehicle.PrimaryPart.Position).magnitude <= 100 then
                                        local orig = rootPart.CFrame
                                        rootPart.CFrame = vehicle.PrimaryPart.CFrame
                                        local prompt = vehicle.TruckCash.Main:FindFirstChild("Attachment")
                                        if prompt then
                                            prompt = prompt:FindFirstChild("ProximityPrompt")
                                            if prompt then
                                                prompt.RequiresLineOfSight = false
                                                prompt.HoldDuration = 0
                                                fireproximityprompt(prompt)
                                                task.wait(0.5)
                                            end
                                        end
                                        rootPart.CFrame = orig
                                    end
                                end
                            end
                            task.wait(1)
                        end
                    end)
                end
            end
        })

        AutoGroup:AddToggle('autoJewel', { Text = '自动珠宝店', Default = false, Callback = function(s) autozbd = s end })

        AutoGroup:AddToggle('autoCollectScrap', {
            Text = '自动捡废料',
            Desc = '传送至废料位置跳跃后等待2秒拾取',
            Default = false,
            Callback = function(Value)
                autoCollectScrap = Value
                if Value then
                    task.spawn(function()
                        while autoCollectScrap do
                            if FromATM or FromBank or autobx or autozbd or autoTreasure or autoblock or automoss or autoxybs or autoxywp or autoptbs or automoney or card then
                                task.wait(1)
                                continue
                            end
                            busy = true
                            local success = fastCollectItems({"Electronics", "Weapon Parts"})
                            if not success then
                                task.wait(1)
                            end
                            busy = false
                            task.wait(0.1)
                        end
                    end)
                else
                    busy = false
                end
            end
        })

        AutoGroup:AddToggle('autoSlotMachine', {
            Text = '自动老虎机',
            Desc = '传送至老虎机前自动旋转',
            Default = false,
            Callback = function(s)
                autoSlotMachine = s
                if s then
                    task.spawn(function()
                        local slotMachineCFrame = CFrame.new(846.239685, 0.435377538, -919.226746, -0.999359787, 0.0311656408, 0.0175692085, 0.0265386514, 0.975102663, -0.220160127, -0.0239932127, -0.219552919, -0.975305498) * CFrame.new(10, -1.6, -5)
                        while autoSlotMachine do
                            local hasSlotMachine = false
                            local serverFurniture = workspace:FindFirstChild("ServerFurniture")
                            if serverFurniture then
                                for _, furniture in pairs(serverFurniture:GetDescendants()) do
                                    if furniture:GetAttribute("furnitureName") == "SlotMachine" then
                                        hasSlotMachine = true
                                        break
                                    end
                                end
                            end
                            if not hasSlotMachine then
                                task.wait(1)
                                continue
                            end
                            local character = LocalPlayer.Character
                            if not character then task.wait(0.5) continue end
                            local rootPart = getRoot(character)
                            if not rootPart then task.wait(0.5) continue end
                            rootPart.CFrame = slotMachineCFrame
                            local lockConn = RunService.Heartbeat:Connect(function()
                                if rootPart and rootPart.Parent then
                                    rootPart.CFrame = slotMachineCFrame
                                    rootPart.Velocity = Vector3.zero
                                    rootPart.RotVelocity = Vector3.zero
                                end
                            end)
                            while autoSlotMachine and (LocalPlayer:GetAttribute("slotSpins") or 0) > 0 do
                                for _, furniture in pairs(serverFurniture:GetDescendants()) do
                                    if furniture:GetAttribute("furnitureName") == "SlotMachine" then
                                        local prompt = furniture:FindFirstChild("Attachment", true)
                                        if prompt then
                                            prompt = prompt:FindFirstChild("ProximityPrompt")
                                            if prompt then
                                                prompt.MaxActivationDistance = 40
                                                fireproximityprompt(prompt)
                                            end
                                        end
                                        break
                                    end
                                end
                                task.wait(0.5)
                            end
                            if lockConn then lockConn:Disconnect() end
                            task.wait(1)
                        end
                    end)
                end
            end
        })

        AutoGroup:AddToggle('autoTreasure', { Text = '自动藏宝图', Default = false, Callback = function(s) autoTreasure = s end })
        AutoGroup:AddToggle('autoSafe', { Text = '自动打开保险', Default = false, Callback = function(s) autobx = s end })
        AutoGroup:AddToggle('unlockAura', {
            Text = '开锁光环',
            Default = false,
            Callback = function(s)
                autoUnlockEnabled = s
                if s then
                    startUnlockAura()
                else
                    stopUnlockAura()
                end
            end
        })

        AutoGroup:AddToggle('cashAura', { Text = '现金光环', Default = false, Callback = function(s)
            cashAuraEnabled = s
            if s then startCashAura() else stopCashAura() end
        end })
        AutoGroup:AddToggle('itemAura', { Text = '物品光环', Default = false, Callback = function(s)
            itemAuraEnabled = s
            if s then startItemAura() else stopItemAura() end
        end })

        function autoSellItems()
            local sold = false
            for _, v in pairs(items) do
                if (v.type == "Holdable" and v.subtype == "gem" and v.sellPrice < 5000) or
                   (v.subtype == "valuable") or
                   (v.type == "Gun" and v.cost < 3999 and v.name ~= "Raygun") then
                    FireServer("equip", v.guid)
                    FireServer("sellItem", v.guid)
                    sold = true
                end
            end
            return sold
        end

        AutoGroup:AddToggle('autoSell', { Text = '自动售卖全部物品', Default = false, Callback = function(Value)
            autoSellEnabled = Value
            if autoSellTask then
                task.cancel(autoSellTask)
                autoSellTask = nil
            end
            if Value then
                autoSellTask = task.spawn(function()
                    while autoSellEnabled do
                        pcall(autoSellItems)
                        task.wait(0.1)
                    end
                end)
            end
        end })

        AutoGroup:AddToggle('autoRemove', { Text = '自动移除垃圾', Default = false, Callback = function(s) remls = s end })
        AutoGroup:AddToggle('autoConsume', { Text = '自动使用消耗品', Default = false, Callback = function(s) autouse = s end })

        AutoGroup:AddToggle('autoCraft', {
            Text = '自动制作萝莉',
            Desc = '制作 Rollie 萝莉',
            Default = false,
            Callback = function(s)
                autoCraftEnabled = s
            end
        })
        AutoGroup:AddToggle('autoClaim', {
            Text = '自动领取萝莉',
            Desc = '领取已完成的 Rollie 萝莉',
            Default = false,
            Callback = function(s)
                autoClaimEnabled = s
            end
        })
        AutoGroup:AddToggle('autoStoreGems', {
            Text = '自动存放珍贵宝石',
            Desc = '将钻石、萝莉、暗物质宝石等存放到房屋珠宝柜',
            Default = false,
            Callback = function(s)
                autoStoreGems = s
            end
        })

        AutoGroup:AddToggle('autoReward', {
            Text = '自动领取奖励',
            Desc = '自动领取每日奖励和游玩时间奖励',
            Default = false,
            Callback = function(s)
                if s then
                    startAutoRewardLoop()
                else
                    stopAutoRewardLoop()
                end
            end
        })
    end

    do
        local FindGroup = Tabs.Ohio:AddRightGroupbox('寻找物品')
        FindGroup:AddToggle('findRare', { Text = '自动寻找稀有物品', Default = false, Callback = function(s) autoxywp = s end })
        FindGroup:AddToggle('findBalloon', { Text = '自动寻找气球', Default = false, Callback = function(s) FromBalloon = s end })
        FindGroup:AddToggle('findPrinter', { Text = '自动寻找印钞机', Default = false, Callback = function(s) automoney = s end })
        FindGroup:AddToggle('findGems', { Text = '自动寻找普通宝石', Default = false, Callback = function(s) autoptbs = s end })
        FindGroup:AddToggle('findRareGems', { Text = '自动寻找稀有宝石', Default = false, Callback = function(s) autoxybs = s end })
        FindGroup:AddToggle('findPresents', { Text = '自动寻找礼物', Default = false, Callback = function(s) automoss = s end })
        FindGroup:AddToggle('findBlocks', { Text = '自动寻找幸运方块', Default = false, Callback = function(s) autoblock = s end })
        FindGroup:AddToggle('findCard', { Text = '自动寻找红卡', Default = false, Callback = function(s) card = s end })
    end

    do
        local CounterGroup = Tabs.Ohio:AddLeftGroupbox('反制')
        CounterGroup:AddButton('重新进入服务器', function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)

        local toastTarget = "关闭"
        local toastTargetDropdown = CounterGroup:AddDropdown('toastTargetSelect', {
            Text = '弹窗目标',
            Values = {'关闭'},
            Default = '关闭',
            Callback = function(v)
                toastTarget = v
            end
        })

        local function refreshToastTargets()
            local names = {"关闭"}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local success, isFriend = pcall(function()
                        return LocalPlayer:IsFriendsWith(player.UserId)
                    end)
                    if not success or not isFriend then
                        table.insert(names, player.Name)
                    end
                end
            end
            if toastTargetDropdown then
                pcall(function()
                    if toastTargetDropdown.SetValues then
                        toastTargetDropdown:SetValues(names)
                    elseif toastTargetDropdown.SetOptions then
                        toastTargetDropdown:SetOptions(names)
                    elseif toastTargetDropdown.Refresh then
                        toastTargetDropdown:Refresh(names, true)
                    elseif toastTargetDropdown.Values ~= nil then
                        toastTargetDropdown.Values = names
                    end
                end)
            end
        end

        task.spawn(function()
            while true do
                task.wait(0.5)
                refreshToastTargets()
            end
        end)

        local toastMsg, toastTime = "", 5
        CounterGroup:AddInput('toastMsg', {
            Text = '弹窗内容',
            Default = '',
            Callback = function(v) toastMsg = v end
        })
        CounterGroup:AddInput('toastTime', {
            Text = '弹窗时长(秒)',
            Default = '5',
            Callback = function(v) toastTime = tonumber(v) or 5 end
        })

        CounterGroup:AddButton('发送弹窗', function()
            if toastTarget == "关闭" then
                loadModule("makeToast")(toastMsg, "rainbow", toastTime)
            else
                local targetPlayer = Players:FindFirstChild(toastTarget)
                if targetPlayer then
                    local chatService = game:GetService("Chat")
                    if chatService and chatService.Chat then
                        chatService:Chat("/msg " .. targetPlayer.Name .. " " .. toastMsg)
                    end
                    Library:Notify({
                        Text = "已尝试向 " .. targetPlayer.Name .. " 发送弹窗: " .. toastMsg,
                        Duration = 3,
                        Icon = "info"
                    })
                else
                    Library:Notify({
                        Text = "目标玩家不存在！",
                        Duration = 2,
                        Icon = "warning"
                    })
                end
            end
        end)

        CounterGroup:AddButton('通话禁音', function()
            FireServer("setAirplaneMode", true)
            LocalPlayer:SetAttribute('isAirplaneMode', true)
        end)
        CounterGroup:AddButton('不允许战斗中', function()
            local combatIndicator = require(ReplicatedStorage.devv.client.Helpers.ui.combatIndicator)
            hookfunction(combatIndicator.isInCombat, function() return false end)
            hookfunction(combatIndicator.enterCombat, function() end)
        end)
        CounterGroup:AddButton('不允许被抓取', function()
            local GrabHandler = require(ReplicatedStorage.devv.client.Handlers.GrabHandler)
            local oldCheck = GrabHandler.CheckValid
            GrabHandler.CheckValid = function(self, p29, p30)
                if p29 == LocalPlayer then return false end
                return oldCheck(self, p29, p30)
            end
            local oldGrab = GrabHandler.Grab
            GrabHandler.Grab = function(self, p55)
                if p55 == LocalPlayer then return end
                return oldGrab(self, p55)
            end
        end)
        CounterGroup:AddButton('清除树叶', function()
            for _, v in workspace:GetDescendants() do
                if v.Name == "Leaves" and v:IsA("MeshPart") then v:Destroy() end
            end
        end)
        CounterGroup:AddButton('反坐下', function()
            local function antiSit(char)
                local hum = char:WaitForChild("Humanoid")
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum:GetPropertyChangedSignal("Sit"):Connect(function()
                    if hum.Sit then hum.Sit = false end
                end)
                hum.Sit = false
            end
            if LocalPlayer.Character then antiSit(LocalPlayer.Character) end
            LocalPlayer.CharacterAdded:Connect(antiSit)
        end)
        CounterGroup:AddToggle('antiDoll', { Text = '反布娃娃', Default = false, Callback = function(s) AntiDoll = s end })
        CounterGroup:AddToggle('antiAdmin', { Text = '反管理', Default = false, Callback = function(s) AntiAdmin = s end })
    end

    do
        local BypassGroup = Tabs.Ohio:AddRightGroupbox('绕过')
        BypassGroup:AddInput('fakeMoney', { Text = '伪装金钱数量', Default = '', Callback = function(v) fakemoney = tonumber(v) or 0 end })
        BypassGroup:AddToggle('fakeMoneyToggle', { Text = '开启伪装', Default = false, Callback = function(s)
            openfake = s
            if s then
                if fakeConnection then fakeConnection:Disconnect() end
                fakeConnection = RunService.Heartbeat:Connect(function()
                    local moneyDisplay = loadModule("moneyDisplay")
                    loadModule("v3sound")
                    moneyDisplay.current = fakemoney
                    moneyDisplay.tweenTo = fakemoney
                    local equipped = loadModule("v3item").inventory.getEquipped()
                    if equipped and equipped.name == "Wallet" then
                        equipped.controller:updateMoney(fakemoney)
                    end
                end)
            else
                if fakeConnection then fakeConnection:Disconnect(); fakeConnection = nil end
            end
        end })
        BypassGroup:AddSlider('inventorySlots', { Text = '物品栏数量', Min = 6, Max = 12, Default = 9, Callback = function(v) loadModule("v3item").inventory.numSlots = v end })
        BypassGroup:AddButton('解锁移动经销商', function()
            local Signal = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
            local oldInvoke = Signal.InvokeServer
            Signal.InvokeServer = function(self, cmd, ...)
                if cmd == "attemptPurchase" or cmd == "attemptPurchaseAmmo" then
                    local itemName, isDealer = ...
                    return oldInvoke(self, cmd, itemName, false, select(3,...))
                end
                return oldInvoke(self, cmd, ...)
            end
            LocalPlayer:SetAttribute("mobileDealer",true)
            local mobileDealer = require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)
            for _, items in pairs(mobileDealer) do for _, item in ipairs(items) do item.stock = 12e12 end end
            table.insert(mobileDealer.Gun, {itemName="Acid Gun",stock=12e12})
        end)
        BypassGroup:AddButton('解锁全皮肤', function()
            local skinsModule = require(ReplicatedStorage.devv.client.Helpers.ui.screens.CaseMenu.Skins)
            local state = loadModule("state")
            hookfunction(skinsModule.AttemptEquip, function(self, itemName, skinName)
                local skinToEquip = skinName
                if self:IsSkinEquipped(itemName, skinName) then skinToEquip = nil end
                state.data.equippedSkins[itemName] = skinToEquip
                loadModule("v3item").inventory.unequipAll()
                loadModule("v3item").inventory.skinUpdate(itemName, skinToEquip)
                self:_setEquipped(itemName, skinToEquip)
                return true
            end)
            local skins = loadModule("skins")
            for skinName in pairs(skins.skinData) do
                for _, itemName in pairs(skins.compatabilities.Generic) do
                    state.data.ownedSkins[itemName] = state.data.ownedSkins[itemName] or {}
                    state.data.ownedSkins[itemName][skinName] = 1
                end
            end
        end)
        BypassGroup:AddButton('解锁高级表情', function()
            for _, v in LocalPlayer.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants() do
                if v.Name == "Locked" then v.Visible = false end
            end
        end)
        BypassGroup:AddButton('绕过火&酸伤害', function()
            local fire = ReplicatedStorage.devv.remoteStorage:FindFirstChild("fireHit")
            local acid = ReplicatedStorage.devv.remoteStorage:FindFirstChild("acidHit")
            if fire then fire:Destroy() end
            if acid then acid:Destroy() end
        end)
    end

    do
        local WeaponGroup = Tabs.Ohio:AddLeftGroupbox('武器')
        WeaponGroup:AddToggle('silentAim', { Text = '静默自瞄', Default = false, Callback = function(s) silentaim = s end })
        WeaponGroup:AddButton('全枪无后座', function()
            for _, v in game:GetDescendants() do if v:IsA("ParticleEmitter") then v:Destroy() end end
            game.DescendantAdded:Connect(function(d) if d:IsA("ParticleEmitter") then d:Destroy() end end)
            for _, v in pairs(items) do if v.type == "Gun" then v.recoilAdd=0; v.maxRecoil=0; v.recoilDiminishFactor=0; v.recoilFastDiminishFactor=0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then
                    local t = require(gun); t.recoilAdd=0; t.maxRecoil=0; t.recoilDiminishFactor=0; t.recoilFastDiminishFactor=0
                end
            end
        end)
        WeaponGroup:AddButton('全枪据点', function()
            for _, v in pairs(items) do if v.type == "Gun" then v.baseSpread=0; v.baseAimSpread=0; v.spread=0; v.aimSpread=0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then local t = require(gun); t.baseSpread=0; t.baseAimSpread=0 end
            end
        end)
        WeaponGroup:AddButton('全枪射速', function()
            for _, v in pairs(items) do if v.type == "Gun" then v.fireDebounce=0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then local t = require(gun); t.fireDebounce=0 end
            end
        end)
        WeaponGroup:AddButton('全枪瞬击', function()
            for _, v in pairs(items) do if v.type == "Gun" then v.speedMax=9999; v.speedDropoff=0; v.projectileLifetime=9999 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then local t = require(gun); t.speedMax=9999; t.speedDropoff=0; t.projectileLifetime=9999 end
            end
        end)
        WeaponGroup:AddButton('快速换弹', function()
            for _, v in pairs(items) do if v.type == "Gun" then v.reloadTime=0 end end
            for _, gun in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun:GetChildren()) do
                if gun:IsA("ModuleScript") then local t = require(gun); t.reloadTime=0 end
            end
        end)
    end

    -- 杂项标签
    do
        local MiscTab = Tabs.Misc
        local MiscGroup = MiscTab:AddLeftGroupbox('杂项功能')
        MiscGroup:AddToggle('hitLogToggle', {
            Text = '命中日志',
            Default = false,
            Callback = function(s)
                if s then
                    startHitLogger()
                else
                    stopHitLogger()
                end
            end
        })
        MiscGroup:AddToggle('rainbowTraceToggle', {
            Text = '彩虹弹道美化',
            Default = false,
            Callback = function(s)
                RAINBOW_TRACE = s
            end
        })
    end

    do
        local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Debug")
        MenuGroup:AddToggle("KeybindMenuOpen", {
            Default = Library.KeybindFrame.Visible,
            Text = "shortcut menu",
            Callback = function(value) Library.KeybindFrame.Visible = value end,
        })
        MenuGroup:AddToggle("ShowCustomCursor", {
            Text = "custom cursors",
            Default = true,
            Callback = function(Value) Library.ShowCustomCursor = Value end,
        })
        MenuGroup:AddDropdown("NotificationSide", {
            Values = { "Left", "Right" },
            Default = "Right",
            Text = "informer location",
            Callback = function(Value) Library:SetNotifySide(Value) end,
        })
        MenuGroup:AddDropdown("DPIDropdown", {
            Values = { "25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
            Default = "100%",
            Text = "UI Size",
            Callback = function(Value)
                Value = Value:gsub("%%", "")
                local DPI = tonumber(Value)
                Library:SetDPIScale(DPI)
            end,
        })
        MenuGroup:AddDivider()
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        MenuGroup:AddButton("Destroy UI", function() Library:Unload() end)
    end

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("MyScriptHub")
    SaveManager:SetFolder("MyScriptHub/specific-game")
    SaveManager:SetSubFolder("specific-place")
    SaveManager:BuildConfigSection(Tabs["UI Settings"])
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
    SaveManager:LoadAutoloadConfig()
end

setupUI()
updateIdleConnection()

function combatTick()
    if autouse then
        for _, v in pairs(items) do
            if v.type == "Consumable" and v.subtype ~= "vest" and v.subtype ~= "food" and v.name ~= "Lockpick" then
                FireServer("equip", v.guid)
                FireServer("useConsumable", v.guid)
                FireServer("removeItem", v.guid)
            end
        end
    end

    if autovest and not busy then
        local armor = LocalPlayer:GetAttribute("armor")
        if not armor or armor <= 0 then
            local lightGuid = getGuid("Light Vest")
            if not lightGuid then
                local root = getRoot(LocalPlayer.Character)
                if root then
                    busy = true
                    local originalCF = root.CFrame
                    root.CFrame = vestBuyLocation
                    task.wait(0.1)
                    InvokeServer("attemptPurchase", "Light Vest")
                    task.wait(0.1)
                    refreshItems()
                    root.CFrame = originalCF
                    busy = false
                end
            else
                FireServer("equip", lightGuid)
                FireServer("useConsumable", lightGuid)
                FireServer("removeItem", lightGuid)
            end
        end
    end

    if autohealth and not busy then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
                local bandage = getGuid("Bandage")
                if not bandage then
                    local root = getRoot(char)
                    if root then
                        busy = true
                        local originalCF = root.CFrame
                        root.CFrame = bandageBuyLocation
                        task.wait(0.1)
                        InvokeServer("attemptPurchase", "Bandage")
                        task.wait(0.1)
                        refreshItems()
                        root.CFrame = originalCF
                        busy = false
                    end
                else
                    FireServer("equip", bandage)
                    FireServer("useConsumable", bandage)
                    FireServer("removeItem", bandage)
                end
            end
        end
    end

    if autokz and maskAutoBuy then
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild(maskNames[selectedMaskType]) and not maskBuying then
            task.spawn(buyMaskIfNeeded)
        end
    end

    if remls then
        local garbageItems = {"Topaz", "Emerald Ring", "Topaz Ring", "Amethyst Ring", "Gold Bar", "Emerald"}
        local keepThrowables = {"Ninja Star", "Tomahawk", "Frag", "Banana Peel", "TNT"}
        for _, v in pairs(items) do
            local shouldRemove = false
            if v.type == "Consumable" and v.subtype == "food" then
                shouldRemove = true
            end
            if v.type == "Throwable" then
                local isKept = false
                for _, keepName in pairs(keepThrowables) do
                    if v.name == keepName then
                        isKept = true
                        break
                    end
                end
                if not isKept then
                    shouldRemove = true
                end
            end
            for _, garbageName in pairs(garbageItems) do
                if v.name == garbageName then
                    shouldRemove = true
                    break
                end
            end
            if shouldRemove then
                FireServer("removeItem", v.guid)
            end
        end
    end

    if Auarcuff then
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 and hum.Health < 5 and (myRoot.Position - root.Position).Magnitude <= 30 then
                    if not loadModule("ClientReplicator").Get(player, "cuffed") then
                        local cuffGuid
                        for _, v in pairs(items) do if v.name == "Handcuffs" then cuffGuid = v.guid break end end
                        if not cuffGuid then
                            InvokeServer("attemptPurchase","Handcuffs")
                        else
                            FireServer("equip", cuffGuid)
                            FireServer("cuffPlayer", player)
                        end
                    end
                end
            end
        end
    end

    if autoStomp then
        stompAura()
    end

    if autoGrab then
        grabAura()
    end
end

RunService.Heartbeat:Connect(combatTick)

RunService.Heartbeat:Connect(function()
    if AntiDoll then
        local ragdolled = LocalPlayer:GetAttribute("isRagdoll")
        if ragdolled then
            FireServer("setRagdoll", false)
            loadModule("ClientReplicator").Set(LocalPlayer, "ragdolled", false)
            LocalPlayer:SetAttribute("isRagdoll", false)
        end
    end
    if AntiAdmin then
        for _, p in Players:GetPlayers() do
            if p:GetAttribute("clanId") == "6557c057b60ffcc7226f532c" then
                LocalPlayer:Kick('[Anti Admin] Admin UserName = '.. p.Name)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if autoCraftEnabled or autoClaimEnabled then
        performCrafting()
    end
    if autoStoreGems then
        storeGems()
    end
end)

task.spawn(function()
    while true do
        if FromATM and not busy then
            busy = true
            pcall(runATMPhase)
            busy = false
        end

        if FromBank and not busy then
            busy = true
            pcall(tryBankHeist)
            busy = false
        end

        if autoCashRegister and not busy then
            busy = true
            pcall(executeCashRegister)
            busy = false
        end

        if autoGemRubble and not busy and (tick() - gemRubbleCooldown >= gemRubbleCooldownTime) then
            busy = true
            pcall(tryGemRubble)
            gemRubbleCooldown = tick()
            busy = false
        end

        if (autoblock or automoss or autoxybs or autoxywp or autoptbs or automoney or card) and not busy then
            busy = true
            while runItemFindPhase() do task.wait() end
            busy = false
        end

        if autozbd and not busy then
            busy = true
            while autozbd and runJewelPhase() do task.wait(0.1) end
            busy = false
        end

        if autoTreasure and not busy then
            busy = true
            while autoTreasure do
                if not runTreasurePhase() then
                    break
                end
                task.wait(0.1)
            end
            busy = false
        end

        if autobx and not busy then
            busy = true
            while autobx do
                if not runSafePhase() then break end
                task.wait(0.1)
            end
            busy = false
        end

        task.wait(0.5)
    end
end)
