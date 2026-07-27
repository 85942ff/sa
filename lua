-- 加载 Obsidian 库
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

-- 服务与玩家
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

if not game:IsLoaded() then game.Loaded:Wait() end

-- 获取 devv 模块
local devv = require(ReplicatedStorage:WaitForChild("devv"))
local loadModule = devv.load
local v3item = loadModule("v3item")
local Signal = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
local FireServer = Signal.FireServer
local InvokeServer = Signal.InvokeServer
local Inventory = v3item.inventory
local items = Inventory.items

-- 自定义 table.find 替代函数
local function tableFind(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- 位置常量
local maskBaseLocation = CFrame.new(604.114014, 5.09485245, -1018.1275)
local idleLocation = CFrame.new(1653.397216796875, -16.95315170288086, -530.3738403320312)
local grenadeBuyLocation = CFrame.new(659.044739, 5.77163315, -706.697632, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local bombThrowLocation = CFrame.new(1129.0994873046875, 14.843579292297363, -354.19488525390625)
local bombTargetPosition = Vector3.new(1124.0853271484, 5.3128666877747, -357.68710327148)
local afterExplosionWaitLocation = CFrame.new(1112.95142, 16.6149864, -331.99646, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local lockpickBuyLocation = CFrame.new(659.280029, 5.50683689, -716.48999, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local vestBuyLocation = CFrame.new(659.063477, 6.21583509, -684.365051, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07)
local bandageBuyLocation = CFrame.new(1168.04468, 25.0443974, -972.782654, 0, 0, -1, 0, 1, 0, 1, 0, 0)

-- 投掷武器购买位置
local throwBuyLocations = {
    ["Ninja Star"] = CFrame.new(337.521484, 25.4010315, -169.487122, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Tomahawk"] = CFrame.new(1027.82568, -48.4671783, -146.084671, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Banana Peel"] = CFrame.new(1568.33887, 3.93496037, -743.868835, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

-- 枪械购买位置（购买后自动返回AFK位置）
local gunBuyLocations = {
    ["Raygun"] = CFrame.new(147.022064, -98.0489502, -529.441406, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["M4A1"] = CFrame.new(603.467651, 25.6628113, -922.04425, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["AK47"] = CFrame.new(1628.71704, 6.15060806, -620.919617, 0.087131381, -0, -0.996196866, 0, 1, -0, 0.996196866, 0, 0.087131381),
}

-- 通用函数
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

-- 物品缓存
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

-- 状态变量
local flySpeed = 50
local currentSpeed = 10
local tpWalkEnabled = false
local flying = false
local flyBV, flyBG, flyConnection
local tpWalkConnection
local antivoidConnection
local fk3rd = false
local silentaim = false

-- Ohio 功能变量
local FromATM, FromBank, FromBalloon = false, false, false
local Auarcuff, autovest, autohealth, autokz, callphone = false, false, false, false, false
local autouse, remls, autobx, autozbd, autoTreasure = false, false, false, false, false
local autoblock, automoss, autoxybs, autoxywp, autoptbs, automoney, card = false, false, false, false, false, false, false
local aurablade, tpplayfb, isBlinkActive = false, false, false
local fbx, fby, fbz = 0, 0, 5
local targetPlayers = {}
local selectedWeapon = "Ninja Star"
local selectedGun = "Raygun"
local bladeid
local openfake, fakemoney = false, 0
local AntiDoll, AntiAdmin = false, false
local idleTeleportEnabled = true
local busy = false
local maskBuying = false   -- 临时标志，购买期间为true
local maskBought = false   -- 永久标志，成功购买后设为true，死亡重生重置

-- 现金光环 & 物品光环
local cashAuraEnabled = false
local itemAuraEnabled = false
local cashAuraConnection = nil
local itemAuraConnection = nil

-- 自动售卖变量
local autoSellEnabled = false
local autoSellInterval = 1
local lastBombardmentTime = 0
local autoSellConnection

local lastPhoneTick = 0
local lastAttack = 0
local originalPosition, blinkStartTime = nil, 0
local avoidPosition = Vector3.new(-23.943367, 53.9272232, -40.3150673)
local avoidRadius = 100

-- 连接存储
local flyJumpConnection
local espLoopConnection
local auraConnection
local fakeConnection
local idleConnection

-- 反坐
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

-- 角色变化处理（重生时重置口罩标志）
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        task.wait()
        onCharacterAdded(LocalPlayer.Character)
        if tpWalkEnabled then startTPWalk() end
        if flying then startFly() end
    end)
    maskBuying = false
    maskBought = false  -- 重生后允许重新购买口罩
end
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- 防AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

-- 飞行
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

-- TPWalk
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

-- 防虚空
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

-- 连跳
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

-- 穿墙
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

-- 透明
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

-- ESP
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

-- 击杀/战斗功能管理
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

-- 根据选择的武器准备武器（购买后自动返回原地）
local function prepareWeapon()
    if selectedWeapon == "Gun Kill" then
        local buyLoc = gunBuyLocations[selectedGun]
        if buyLoc then
            local root = getRoot(LocalPlayer.Character)
            if root then
                root.CFrame = buyLoc
                task.wait(0.5)
            end
        end
        InvokeServer("attemptPurchase", selectedGun)
        task.wait(0.3)
        for _, v in pairs(items) do
            if v.name == selectedGun then
                FireServer("equip", v.guid)
                break
            end
        end
        local root = getRoot(LocalPlayer.Character)
        if root then root.CFrame = idleLocation end
    else
        local buyLoc = throwBuyLocations[selectedWeapon]
        if buyLoc then
            local root = getRoot(LocalPlayer.Character)
            if root then
                root.CFrame = buyLoc
                task.wait(0.5)
            end
        end
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
        local root = getRoot(LocalPlayer.Character)
        if root then root.CFrame = idleLocation end
    end
end

local function attackTarget(target)
    local targetPos = target.Position
    if selectedWeapon == "Gun Kill" then
        local item = v3item.GetEquipped(LocalPlayer)
        if item and item.type == "Gun" then
            if item.ammoManager and item.ammoManager.ammo > 0 then
                local g = devv.load("GUID")()
                createTrace(targetPos)
                FireServer("replicateProjectiles", item.guid, {{g, target.CFrame}}, item.firemode)
                FireServer("projectileHit", g, "player", {
                    hitSize = target.Size,
                    hitPart = target,
                    pos = targetPos,
                    hitPlayerId = Players:GetPlayerFromCharacter(target.Parent).UserId
                })
                item.ammoManager.ammo = item.ammoManager.ammo - 1
            else
                InvokeServer("attemptPurchaseAmmo", item.name)
                FireServer("reload", item.guid)
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
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local isTarget = (#targetPlayers == 0) or tableFind(targetPlayers, player.Name)
            if isTarget and not player.Character:FindFirstChildOfClass("ForceField") and not LocalPlayer:IsFriendsWith(player.UserId) then
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
    if aurablade or isBlinkActive then
        local now = tick()
        local dist = (myRoot.Position - targetHead.Position).Magnitude
        local attackInterval = 0  -- 每帧攻击
        if now - lastAttack >= attackInterval and dist <= 200000 then  -- 距离上限200000
            if isBlinkActive then
                if not originalPosition then
                    originalPosition = myRoot.Position
                    myRoot.CFrame = CFrame.new(1000,1000,1000)
                    blinkStartTime = now
                    return
                elseif now - blinkStartTime >= math.random(1,3) then
                    myRoot.CFrame = targetHead.CFrame * CFrame.new(fbx, fby, fbz)
                    attackTarget(targetHead)
                    task.wait(0.05)
                    myRoot.CFrame = CFrame.new(originalPosition)
                    originalPosition = nil
                    isBlinkActive = false
                end
            else
                attackTarget(targetHead)
                lastAttack = now
            end
        end
    end
end

local function updateAuraConnection()
    if aurablade or tpplayfb or isBlinkActive then
        if not auraConnection then
            auraConnection = RunService.Heartbeat:Connect(auraHeartbeat)
        end
    else
        if auraConnection then auraConnection:Disconnect(); auraConnection = nil end
    end
end

-- 静默自瞄 hook
local function setupSilentAim()
    if v3item and v3item.projectiles then
        local oldNewProjectile = v3item.projectiles.newProjectileOfType
        v3item.projectiles.newProjectileOfType = function(ptype, pdata)
            if silentaim then
                local target = findTarget()
                if target and pdata.cframe then
                    pdata.cframe = CFrame.lookAt(pdata.cframe.Position, target.Position)
                end
            end
            return oldNewProjectile(ptype, pdata)
        end
    end
end
setupSilentAim()

-- 自动口罩（改进版：购买成功后立即返回AFK位置，并设置 maskBought 为 true，不再阻止归位）
local function tryBuyMaskOnce()
    if maskBuying or maskBought then return end
    maskBuying = true
    local char = LocalPlayer.Character
    if not char then maskBuying = false return end
    if char:FindFirstChild("Black Bandana") then
        maskBought = true
        maskBuying = false
        return
    end

    local root = getRoot(char)
    if root then
        local offsetX = math.random(-8, 8)
        local offsetZ = math.random(-8, 8)
        local randomPos = maskBaseLocation.Position + Vector3.new(offsetX, 0, offsetZ)
        root.CFrame = CFrame.new(randomPos)
        task.wait(0.5)

        InvokeServer("attemptPurchase", "Black Bandana")
        task.wait(0.3)
        for _, v in pairs(items) do
            if v.name == "Black Bandana" then
                FireServer("equip", v.guid)
                FireServer("wearMask", v.guid)
                break
            end
        end
        -- 等待口罩出现
        local startTime = tick()
        while not char:FindFirstChild("Black Bandana") and tick() - startTime < 2 do
            task.wait(0.1)
        end
        root.CFrame = idleLocation  -- 购买完毕立刻回到AFK位置
    end
    maskBought = true
    maskBuying = false
end

-- 自动ATM
local function runATMPhase()
    local atms = workspace:FindFirstChild("ATMs")
    if not atms then return end
    local root = getRoot(LocalPlayer.Character)
    if not root then return end

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
    local lockCF = CFrame.new(main.Position - Vector3.new(0, 4, 0)) * CFrame.Angles(math.rad(90), 0, 0)

    local lockConn = RunService.Heartbeat:Connect(function()
        if root and root.Parent then
            root.CFrame = lockCF
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end)

    task.wait(0.8)
    nearestATM:SetAttribute("health", 0)
    task.wait(1.4)

    if lockConn then lockConn:Disconnect() end
    root.CFrame = idleLocation
end

-- 自动银行
local function ensureItem(itemName, buyLocation)
    for _, v in pairs(items) do
        if v.name == itemName then return v.guid end
    end
    local root = getRoot(LocalPlayer.Character)
    if root then
        root.CFrame = buyLocation
        task.wait(0.5)
        InvokeServer("attemptPurchase", itemName)
        task.wait(0.5)
    end
    for _, v in pairs(items) do
        if v.name == itemName then return v.guid end
    end
    return nil
end

local function tryBankHeist()
    local bank = workspace:FindFirstChild("BankRobbery")
    if not bank then return false end
    local cashFolder = bank:FindFirstChild("BankCash") and bank.BankCash:FindFirstChild("Cash")
    if not cashFolder or #cashFolder:GetChildren() == 0 then return false end

    local fragGuid = ensureItem("Frag", grenadeBuyLocation)
    if not fragGuid then return false end

    local root = getRoot(LocalPlayer.Character)
    if not root then return false end

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

    root.CFrame = afterExplosionWaitLocation
    local lockPos = (afterExplosionWaitLocation * CFrame.new(0, 0, -4)).Position
    local lockCF = CFrame.new(lockPos) * CFrame.Angles(math.rad(90), 0, 0)
    local endTime = tick() + 4
    while tick() < endTime do
        root = getRoot(LocalPlayer.Character)
        if root then
            root.CFrame = lockCF
            root.Velocity = Vector3.zero
        end
        task.wait(0.2)
    end

    local collectCF = CFrame.new((bank.BankCash.Pallet.CFrame * CFrame.new(0, -2, 0)).Position) * CFrame.Angles(math.rad(90), 0, 0)
    root = getRoot(LocalPlayer.Character)
    if root then root.CFrame = collectCF end

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

    root = getRoot(LocalPlayer.Character)
    if root then root.CFrame = idleLocation end
    return true
end

-- 珠宝店
local function runJewelPhase()
    local cases = workspace:FindFirstChild("GemRobbery"):FindFirstChild("JewelryCases")
    if not cases then return false end
    for _, descendant in pairs(cases:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Steal" and descendant.Enabled then
            descendant.HoldDuration = 0
            local root = getRoot(LocalPlayer.Character)
            if root then
                root.CFrame = CFrame.new(descendant.Parent.Position)
                fireproximityprompt(descendant)
                return true
            end
        end
    end
    return false
end

-- 自动藏宝图
local function runTreasurePhase()
    local equipped = v3item.inventory.getEquippedItem()
    if not equipped or equipped.name ~= "Treasure Map" then return false end
    local root = getRoot(LocalPlayer.Character)
    if not root then return false end
    local debris = workspace.Game.Local.Debris
    local found = false
    for _, treasure in pairs(debris:GetChildren()) do
        if treasure.Name == "TreasureMarker" then
            root.CFrame = treasure.CFrame
            local prompt = treasure:FindFirstChild("ProximityPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
            task.wait(0.5)
            found = true
        end
    end
    if not found then
        root.CFrame = idleLocation
    end
    return found
end

-- 自动寻找物品（每帧）
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

-- 自动打开保险（先买锁后开）
local function runSafePhase()
    local lockGuid = getGuid("Lockpick")
    if not lockGuid then
        local root = getRoot(LocalPlayer.Character)
        if root then
            root.CFrame = lockpickBuyLocation
            task.wait(0.5)
            InvokeServer("attemptPurchase", "Lockpick")
            task.wait(0.8)
            refreshItems()
        end
        return false
    end

    local chestTypes = {"SmallChest","LargeChest","SmallSafe","MediumSafe","LargeSafe","JewelSafe","GoldJewelSafe"}
    for _, ct in pairs(chestTypes) do
        local folder = workspace.Game.Entities:FindFirstChild(ct)
        if folder then
            for _, chest in pairs(folder:GetChildren()) do
                if chest.PrimaryPart then
                    local prompt = chest:FindFirstChild("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        local root = getRoot(LocalPlayer.Character)
                        if root then
                            root.CFrame = chest.PrimaryPart.CFrame * CFrame.new(0,3,0)
                            fireproximityprompt(prompt)
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- 现金光环
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

-- 物品光环
local valuableItems = {
    "Dark Matter Gem", "Void Gem", "Diamond Ring", "Diamond", "Rollie",
    "Watch", "Glock 18", "AR-15", "Amethyst", "Topaz", "Emerald",
    "Gold Bar", "Sapphire", "Ruby", "Emerald Ring", "Topaz Ring",
    "Amethyst Ring", "Sapphire Ring", "Ruby Ring", "AK-47", "Glock",
    "Raygun", "Gold AK-47", "Gold Deagle", "AS Val", "AUG", "Acid Gun",
    "P90", "RPK", "Sawn Off", "Scar L", "Saiga 12", "Tommy Gun",
    "Double Barrel", "Deagle", "Dragunov", "Flamethrower", "M249 SAW",
    "MP7", "Minigun", "M4A1", "Barrett M107", "Gravity Gun",
    "Gold Lucky Block", "Orange Lucky Block", "Purple Lucky Block",
    "Green Lucky Block", "Red Lucky Block", "Blue Lucky Block",
    "Treasure Map", "Pearl Necklace", "Military Armory Keycard",
    "Police Armory Keycard", "Money Printer", "RPG", "Trident",
    "Gold Crown", "Gold Cup", "Heavy Vest", "Military Vest"
}

local function startItemAura()
    itemAuraConnection = RunService.Heartbeat:Connect(function()
        if not itemAuraEnabled then return end
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
    end
end

-- 空闲归位（移除 maskBuying 限制）
local function updateIdleConnection()
    if idleConnection then idleConnection:Disconnect(); idleConnection = nil end
    if idleTeleportEnabled then
        idleConnection = RunService.Heartbeat:Connect(function()
            if not busy then
                local root = getRoot(LocalPlayer.Character)
                if root and root.Parent then
                    root.CFrame = idleLocation
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                end
            end
        end)
    end
end

-- UI
local Tabs = {
    Player = Window:AddTab('玩家', 'user'),
    Visual = Window:AddTab('视觉', 'eye'),
    Ohio = Window:AddTab('主要', 'crosshair'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings')
}

-- 玩家 Tab
local PlayerGroup = Tabs.Player:AddLeftGroupbox('移动')
PlayerGroup:AddSlider('flySpeed', { Text = '飞行速度', Min = 10, Max = 200, Default = 50, Callback = function(v) flySpeed = v end })
PlayerGroup:AddToggle('flyToggle', { Text = '飞行模式（谨慎使用）', Default = false, Callback = function(s) if s then startFly() else stopFly() end end })
PlayerGroup:AddSlider('moveSpeed', { Text = '移动速度', Min = 1, Max = 1000, Default = 10, Callback = function(v) currentSpeed = v end })  -- 移速上限1000
PlayerGroup:AddToggle('speedToggle', { Text = '加速', Default = false, Callback = function(s) if s then startTPWalk() else stopTPWalk() end end })

local PlayerGroup2 = Tabs.Player:AddRightGroupbox('角色')
PlayerGroup2:AddToggle('transparentToggle', { Text = '透明', Default = false, Callback = toggleTransparent })
PlayerGroup2:AddToggle('bunnyHopToggle', { Text = '连跳', Default = false, Callback = toggleBunnyHop })
PlayerGroup2:AddToggle('noClipToggle', { Text = '穿墙', Default = false, Callback = toggleNoClip })
PlayerGroup2:AddToggle('antiVoidToggle', { Text = '防虚空掉落', Default = false, Callback = toggleAntiVoid })

-- 视觉 Tab
local VisualGroup = Tabs.Visual:AddLeftGroupbox('ESP 设置')
VisualGroup:AddToggle('espMaster', { Text = '开启 ESP', Default = false, Callback = toggleESP })
VisualGroup:AddToggle('espName', { Text = '显示玩家名', Default = true, Callback = function(s) DrawingConfig.NameEnabled = s end })
VisualGroup:AddToggle('espDist', { Text = '显示距离', Default = true, Callback = function(s) DrawingConfig.DistanceEnabled = s end })
VisualGroup:AddToggle('espHP', { Text = '显示 HP', Default = true, Callback = function(s) DrawingConfig.HealthText = s end })

-- 击杀
local function updatePlayerDropdown(dropdown)
    if not dropdown then return end
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    dropdown:Refresh(names, true)
end

local initialPlayerList = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(initialPlayerList, player.Name)
    end
end

local KillGroup = Tabs.Ohio:AddLeftGroupbox('击杀')
local playerDropdown = KillGroup:AddDropdown('targetPlayers', {
    Text = '目标玩家',
    Values = initialPlayerList,
    Default = initialPlayerList,
    Multi = true,
    Callback = function(v) targetPlayers = v end
})
KillGroup:AddDropdown('killMethod', { Text = '击杀方式', Values = {'Ninja Star', 'Tomahawk', 'Banana Peel', 'Gun Kill'}, Default = 'Ninja Star', Multi = false, Callback = function(v)
    selectedWeapon = (v[1] or v)
end })
KillGroup:AddDropdown('gunSelect', { Text = '选择枪械', Values = {'Raygun', 'M4A1', 'AK47'}, Default = 'Raygun', Multi = false, Callback = function(v)
    selectedGun = (v[1] or v)
end })
KillGroup:AddToggle('autoKill', { Text = '自动击杀', Default = false, Callback = function(s)
    aurablade = s
    if s then prepareWeapon() end
    updateAuraConnection()
end })
KillGroup:AddToggle('blinkToggle', { Text = '闪现', Default = false, Callback = function(s) isBlinkActive = s; if not s then originalPosition = nil end; updateAuraConnection() end })
KillGroup:AddToggle('tpPlayer', { Text = 'TP玩家', Default = false, Callback = function(s) tpplayfb = s; updateAuraConnection() end })
KillGroup:AddSlider('fbx', { Text = 'X 偏移', Min = -20, Max = 20, Default = 0, Callback = function(v) fbx = v end })
KillGroup:AddSlider('fby', { Text = 'Y 偏移', Min = -20, Max = 20, Default = 0, Callback = function(v) fby = v end })
KillGroup:AddSlider('fbz', { Text = 'Z 偏移', Min = -20, Max = 20, Default = 5, Callback = function(v) fbz = v end })

task.spawn(function()
    while true do
        updatePlayerDropdown(playerDropdown)
        task.wait(0.5)
    end
end)

-- 战斗
local CombatGroup = Tabs.Ohio:AddRightGroupbox('战斗')
CombatGroup:AddToggle('autoVest', { Text = '自动护甲', Default = false, Callback = function(s) autovest = s end })
CombatGroup:AddToggle('autoHeal', { Text = '自动回血', Default = false, Callback = function(s) autohealth = s end })
CombatGroup:AddToggle('autoMask', { Text = '自动口罩', Default = false, Callback = function(s) autokz = s end })
CombatGroup:AddToggle('phoneSpam', { Text = '电话骚扰', Default = false, Callback = function(s) callphone = s end })
CombatGroup:AddToggle('arrestAura', { Text = '逮捕光环', Default = false, Callback = function(s) Auarcuff = s end })

-- 自动
local AutoGroup = Tabs.Ohio:AddLeftGroupbox('自动')
AutoGroup:AddToggle('autoATM', { Text = '自动摧毁ATM', Default = false, Callback = function(s) FromATM = s end })
AutoGroup:AddToggle('autoBank', { Text = '自动偷盗银行', Default = false, Callback = function(s) FromBank = s end })
AutoGroup:AddToggle('autoJewel', { Text = '自动珠宝店', Default = false, Callback = function(s) autozbd = s end })
AutoGroup:AddToggle('autoTreasure', { Text = '自动藏宝图', Default = false, Callback = function(s) autoTreasure = s end })
AutoGroup:AddToggle('autoSafe', { Text = '自动打开保险', Default = false, Callback = function(s) autobx = s end })

-- 现金光环
AutoGroup:AddToggle('cashAura', { Text = '现金光环', Default = false, Callback = function(s)
    cashAuraEnabled = s
    if s then startCashAura() else stopCashAura() end
end })

-- 物品光环
AutoGroup:AddToggle('itemAura', { Text = '物品光环', Default = false, Callback = function(s)
    itemAuraEnabled = s
    if s then startItemAura() else stopItemAura() end
end })

-- 自动售卖
local function autoSellItems()
    for _, v in pairs(items) do
        if (v.type == "Holdable" and v.subtype == "gem" and v.sellPrice < 5000) or
           (v.subtype == "valuable") or
           (v.type == "Gun" and v.cost < 3999 and v.name ~= "Raygun") then
            FireServer("equip", v.guid)
            FireServer("sellItem", v.guid)
        end
    end
end

AutoGroup:AddToggle('autoSell', { Text = '自动售卖全部物品', Default = false, Callback = function(Value)
    autoSellEnabled = Value
    if autoSellConnection then autoSellConnection:Disconnect(); autoSellConnection = nil end
    if Value then
        autoSellConnection = RunService.Heartbeat:Connect(function()
            if tick() - lastBombardmentTime >= autoSellInterval then
                pcall(autoSellItems)
                lastBombardmentTime = tick()
            end
        end)
        pcall(autoSellItems)
    end
end })

AutoGroup:AddToggle('autoRemove', { Text = '自动移除垃圾', Default = false, Callback = function(s) remls = s end })
AutoGroup:AddToggle('autoConsume', { Text = '自动使用消耗品', Default = false, Callback = function(s) autouse = s end })
AutoGroup:AddToggle('idleTeleport', { Text = 'AFK位置', Default = true, Callback = function(s)
    idleTeleportEnabled = s
    updateIdleConnection()
end })

-- 寻找物品
local FindGroup = Tabs.Ohio:AddRightGroupbox('寻找物品')
FindGroup:AddToggle('findRare', { Text = '自动寻找稀有物品', Default = false, Callback = function(s) autoxywp = s end })
FindGroup:AddToggle('findBalloon', { Text = '自动寻找气球', Default = false, Callback = function(s) FromBalloon = s end })
FindGroup:AddToggle('findPrinter', { Text = '自动寻找印钞机', Default = false, Callback = function(s) automoney = s end })
FindGroup:AddToggle('findGems', { Text = '自动寻找普通宝石', Default = false, Callback = function(s) autoptbs = s end })
FindGroup:AddToggle('findRareGems', { Text = '自动寻找稀有宝石', Default = false, Callback = function(s) autoxybs = s end })
FindGroup:AddToggle('findPresents', { Text = '自动寻找礼物', Default = false, Callback = function(s) automoss = s end })
FindGroup:AddToggle('findBlocks', { Text = '自动寻找幸运方块', Default = false, Callback = function(s) autoblock = s end })
FindGroup:AddToggle('findCard', { Text = '自动寻找红卡', Default = false, Callback = function(s) card = s end })

-- 反制
local CounterGroup = Tabs.Ohio:AddLeftGroupbox('反制')
CounterGroup:AddButton('重新进入服务器', function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
local toastMsg, toastTime = "", 5
CounterGroup:AddInput('toastMsg', { Text = '弹窗内容', Default = '', Callback = function(v) toastMsg = v end })
CounterGroup:AddInput('toastTime', { Text = '弹窗时长(秒)', Default = '5', Callback = function(v) toastTime = tonumber(v) or 5 end })
CounterGroup:AddButton('发送弹窗', function() loadModule("makeToast")(toastMsg, "rainbow", toastTime) end)
CounterGroup:AddButton('通话禁音', function() FireServer("setAirplaneMode", true); LocalPlayer:SetAttribute('isAirplaneMode', true) end)
CounterGroup:AddButton('不允许战斗中', function()
    local combatIndicator = require(ReplicatedStorage.devv.client.Helpers.ui.combatIndicator)
    hookfunction(combatIndicator.isInCombat, function() return false end)
    hookfunction(combatIndicator.enterCombat, function() end)
end)
CounterGroup:AddButton('不允许被抓取', function()
    local GrabHandler = require(ReplicatedStorage.devv.client.Handlers.GrabHandler)
    local oldCheck = GrabHandler.CheckValid
    GrabHandler.CheckValid = function(self, p29, p30) if p29 == LocalPlayer then return false end; return oldCheck(self, p29, p30) end
    local oldGrab = GrabHandler.Grab
    GrabHandler.Grab = function(self, p55) if p55 == LocalPlayer then return end; return oldGrab(self, p55) end
end)
CounterGroup:AddButton('清除树叶', function()
    for _, v in workspace:GetDescendants() do if v.Name == "Leaves" and v:IsA("MeshPart") then v:Destroy() end end
end)
CounterGroup:AddButton('反坐下', function()
    local function antiSit(char)
        local hum = char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:GetPropertyChangedSignal("Sit"):Connect(function() if hum.Sit then hum.Sit = false end end)
        hum.Sit = false
    end
    if LocalPlayer.Character then antiSit(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(antiSit)
end)
CounterGroup:AddToggle('antiDoll', { Text = '反布娃娃', Default = false, Callback = function(s) AntiDoll = s end })
CounterGroup:AddToggle('antiAdmin', { Text = '反管理', Default = false, Callback = function(s) AntiAdmin = s end })

-- 绕过
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

-- 武器
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

-- UI 设置
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

updateIdleConnection()

-- ========== 核心逻辑 ==========
local function combatTick()
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
                busy = true
                local root = getRoot(LocalPlayer.Character)
                if root then
                    root.CFrame = vestBuyLocation
                    task.wait(0.5)
                    InvokeServer("attemptPurchase", "Light Vest")
                    task.wait(0.5)
                    refreshItems()
                    root.CFrame = idleLocation
                end
                busy = false
            else
                FireServer("equip", lightGuid)
                FireServer("useConsumable", lightGuid)
                FireServer("removeItem", lightGuid)
            end
        end
    end

    if autohealth and not busy then
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
            local bandage = getGuid("Bandage")
            if not bandage then
                busy = true
                local root = getRoot(LocalPlayer.Character)
                if root then
                    root.CFrame = bandageBuyLocation
                    task.wait(0.5)
                    InvokeServer("attemptPurchase", "Bandage")
                    task.wait(0.5)
                    refreshItems()
                    root.CFrame = idleLocation
                end
                busy = false
            else
                FireServer("equip", bandage)
                FireServer("useConsumable", bandage)
                FireServer("removeItem", bandage)
            end
        end
    end

    if autokz then
        local char = LocalPlayer.Character
        if char and not maskBought then
            task.spawn(tryBuyMaskOnce)
        end
    end

    if remls then
        for _, v in pairs(items) do
            if (v.type == "Consumable" and v.subtype == "food" and v.name ~= "Bandage") or
               (v.type == "Throwable" and v.cost < 500 and v.name ~= "Ninja Star" and v.name ~= "Tomahawk" and v.name ~= "Frag") or
               (v.type == "Melee" and v.cost > 100) then
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
                        if not cuffGuid then InvokeServer("attemptPurchase","Handcuffs") else
                            FireServer("equip", cuffGuid)
                            FireServer("cuffPlayer", player)
                        end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(combatTick)

-- 反布娃娃/反管理
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

-- 主任务循环：口罩 > ATM > 银行 > 珠宝店 > 藏宝图 > 寻找物品 > 自动保险
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

        if autozbd and not busy then
            busy = true
            while autozbd and runJewelPhase() do task.wait(0.1) end
            busy = false
        end

        if autoTreasure and not busy then
            busy = true
            runTreasurePhase()
            busy = false
        end

        if (autoblock or automoss or autoxybs or autoxywp or autoptbs or automoney or card) and not busy then
            busy = true
            while runItemFindPhase() do task.wait() end  -- 每帧
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
