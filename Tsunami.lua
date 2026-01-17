if game.PlaceId ~= 131623223084840 then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Anti AFK
player.Idled:Connect(function()
  VirtualUser:CaptureController()
  VirtualUser:ClickButton2(Vector2.new())
end)

-- Character setup
local hrp
local hum
local function setupChar(char)
  hrp = char:WaitForChild("HumanoidRootPart")
  hum = char:WaitForChild("Humanoid")
  
  -- Applique immédiatement les valeurs custom
  if walkSpeedEnabled then
    hum.WalkSpeed = customWalkSpeed
  end
  if jumpPowerEnabled then
    hum.JumpPower = customJumpPower
  end
  
  -- Applique unwalk animation si activé
  if unwalkEnabled then
    applyUnwalkAnimation(char)
  end
end

if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(function(c)
  task.wait(1)
  setupChar(c)
end)

-- UI Init
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
  Title = "Porn Hub",
  Icon = "monitor",
  Author = "By Enotix",
  Folder = "TsunamiBrainrots",
  Size = UDim2.fromOffset(560, 430),
  Theme = "Dark",
  Transparent = true,
  Resizable = true,
  User = { Enabled = true }
})

local FarmTab = Window:Tab({ Title = "Main", Icon = "zap" })
local UpgradeTab = Window:Tab({ Title = "Upgrade", Icon = "trending-up" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local ThemeTab = Window:Tab({ Title = "Theme", Icon = "palette" })

-- Positions
local BASE_POS = Vector3.new(130,3,0)
local SECRET_POS = Vector3.new(2440,3,-4)

-- === UNWALK ANIMATION ===
local unwalkEnabled = false
local originalWalkAnimation = nil

local function applyUnwalkAnimation(char)
  local animate = char:FindFirstChild("Animate")
  if animate then
    local walk = animate:FindFirstChild("walk")
    if walk then
      local walkAnim = walk:FindFirstChild("WalkAnim")
      if walkAnim and not originalWalkAnimation then
        originalWalkAnimation = walkAnim.AnimationId
      end
      if walkAnim then
        walkAnim.AnimationId = ""
      end
    end
  end
end

local function restoreWalkAnimation(char)
  local animate = char:FindFirstChild("Animate")
  if animate then
    local walk = animate:FindFirstChild("walk")
    if walk then
      local walkAnim = walk:FindFirstChild("WalkAnim")
      if walkAnim and originalWalkAnimation then
        walkAnim.AnimationId = originalWalkAnimation
      end
    end
  end
end

-- === HITBOX EXPANDER ===
local hitboxEnabled = false
local hitboxSize = 10
local originalSizes = {}

local function expandHitboxes()
  for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
      local hrpTarget = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrpTarget then
        if not originalSizes[hrpTarget] then
          originalSizes[hrpTarget] = hrpTarget.Size
        end
        hrpTarget.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        hrpTarget.Transparency = 0.1
        hrpTarget.CanCollide = false
      end
    end
  end
end

local function restoreHitboxes()
  for hrpTarget, originalSize in pairs(originalSizes) do
    if hrpTarget and hrpTarget.Parent then
      hrpTarget.Size = originalSize
      hrpTarget.Transparency = 1
    end
  end
  originalSizes = {}
end

-- Hitbox Update Loop
task.spawn(function()
  while true do
    task.wait(0.1)
    if hitboxEnabled then
      expandHitboxes()
    end
  end
end)

-- === ESP SYSTEM ===
local espEnabled = {
  players = false,
  brainrots = false,
  celestials = false
}

local espObjects = {}

local function createESP(object, name, color, espType, playerObj)
  if espObjects[object] then return end
  
  if espType == "player" then
    -- Pour les joueurs : box compacte avec juste le nom
    local character = object.Parent
    if character then
      local billboardGui = Instance.new("BillboardGui")
      billboardGui.Name = "PlayerESP"
      billboardGui.Adornee = object
      billboardGui.Size = UDim2.new(0, 0, 0, 0)
      billboardGui.StudsOffset = Vector3.new(0, 3, 0)
      billboardGui.AlwaysOnTop = true
      billboardGui.MaxDistance = 2000
      billboardGui.Parent = object
      
      local frame = Instance.new("Frame")
      frame.Size = UDim2.new(0, 0, 0, 22)
      frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      frame.BackgroundTransparency = 0.3
      frame.BorderSizePixel = 0
      frame.AutomaticSize = Enum.AutomaticSize.X
      frame.Parent = billboardGui
      
      local uiCorner = Instance.new("UICorner")
      uiCorner.CornerRadius = UDim.new(0, 6)
      uiCorner.Parent = frame
      
      local uiStroke = Instance.new("UIStroke")
      uiStroke.Color = Color3.fromRGB(255, 255, 255)
      uiStroke.Thickness = 1.5
      uiStroke.Parent = frame
      
      local padding = Instance.new("UIPadding")
      padding.PaddingLeft = UDim.new(0, 6)
      padding.PaddingRight = UDim.new(0, 6)
      padding.PaddingTop = UDim.new(0, 2)
      padding.PaddingBottom = UDim.new(0, 2)
      padding.Parent = frame
      
      local textLabel = Instance.new("TextLabel")
      textLabel.Size = UDim2.new(0, 0, 1, 0)
      textLabel.BackgroundTransparency = 1
      textLabel.Text = playerObj.DisplayName
      textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
      textLabel.TextStrokeTransparency = 0.5
      textLabel.TextSize = 12
      textLabel.Font = Enum.Font.GothamBold
      textLabel.TextXAlignment = Enum.TextXAlignment.Center
      textLabel.AutomaticSize = Enum.AutomaticSize.X
      textLabel.Parent = frame
      
      local highlight = Instance.new("Highlight")
      highlight.Name = "ESPHighlight"
      highlight.FillColor = Color3.fromRGB(255, 0, 0)
      highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
      highlight.FillTransparency = 0.5
      highlight.OutlineTransparency = 0
      highlight.Parent = character
      
      espObjects[object] = {gui = billboardGui, highlight = highlight, label = textLabel, espType = espType, playerObj = playerObj}
    end
  else
    -- Pour les secrets et celestials : box adaptative à la distance
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP"
    billboardGui.Adornee = object
    billboardGui.Size = UDim2.new(0, 70, 0, 35)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 2000
    billboardGui.Parent = object
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 255, 255)
    uiStroke.Thickness = 2
    uiStroke.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -8, 1, -8)
    textLabel.Position = UDim2.new(0, 4, 0, 4)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.RichText = true
    textLabel.Parent = frame
    
    -- Highlight pour les secrets et celestials
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    espObjects[object] = {gui = billboardGui, highlight = highlight, label = textLabel, frame = frame, espType = espType}
  end
end

local function removeESP(object)
  if espObjects[object] then
    if espObjects[object].gui then espObjects[object].gui:Destroy() end
    if espObjects[object].highlight then espObjects[object].highlight:Destroy() end
    espObjects[object] = nil
  end
end

local function updatePlayerESP()
  if not espEnabled.players then
    for obj, data in pairs(espObjects) do
      if data.espType == "player" then
        removeESP(obj)
      end
    end
    return
  end
  
  for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
      local hrpTarget = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrpTarget then
        if not espObjects[hrpTarget] then
          createESP(hrpTarget, "", Color3.fromRGB(255, 255, 255), "player", otherPlayer)
        else
          -- Mise à jour du texte seulement (la taille s'adapte automatiquement)
          if hrp and espObjects[hrpTarget].label then
            local distance = math.floor((hrp.Position - hrpTarget.Position).Magnitude)
            espObjects[hrpTarget].label.Text = otherPlayer.DisplayName
          end
        end
      end
    end
  end
  
  -- Nettoyer les ESP des joueurs qui ont quitté
  for obj, data in pairs(espObjects) do
    if data.espType == "player" and data.playerObj then
      if not Players:FindFirstChild(data.playerObj.Name) or not data.playerObj.Character then
        removeESP(obj)
      end
    end
  end
end

local function updateBrainrotESP()
  if not espEnabled.brainrots then
    for obj, data in pairs(espObjects) do
      if data.espType == "brainrot" then
        removeESP(obj)
      end
    end
    return
  end
  
  local secretFolder = workspace:FindFirstChild("ActiveBrainrots") and workspace.ActiveBrainrots:FindFirstChild("Secret")
  if secretFolder then
    for _, item in ipairs(secretFolder:GetChildren()) do
      local handle = item:FindFirstChild("Handle")
      if handle then
        if not espObjects[handle] then
          createESP(handle, "SECRET", Color3.fromRGB(255, 0, 0), "brainrot")
        else
          -- Mise à jour de la distance et adaptation de la taille
          if hrp and espObjects[handle].label then
            local distance = math.floor((hrp.Position - handle.Position).Magnitude)
            local secretName = item.Name or "Unknown"
            espObjects[handle].label.Text = '<font color="rgb(255,0,0)">SECRET</font>\n' .. secretName .. "\n" .. distance .. " studs"
            espObjects[handle].label.RichText = true
            
            -- Adapter la taille de la box selon la distance (INVERSE: loin = petit, proche = grand)
            if distance > 1000 then
              espObjects[handle].gui.Size = UDim2.new(0, 70, 0, 35)
              espObjects[handle].label.TextSize = 9
            elseif distance > 500 then
              espObjects[handle].gui.Size = UDim2.new(0, 90, 0, 45)
              espObjects[handle].label.TextSize = 10
            elseif distance > 200 then
              espObjects[handle].gui.Size = UDim2.new(0, 120, 0, 60)
              espObjects[handle].label.TextSize = 12
            else
              espObjects[handle].gui.Size = UDim2.new(0, 150, 0, 70)
              espObjects[handle].label.TextSize = 14
            end
          end
        end
      end
    end
  end
end

local function updateCelestialESP()
  if not espEnabled.celestials then
    for obj, data in pairs(espObjects) do
      if data.espType == "celestial" then
        removeESP(obj)
      end
    end
    return
  end
  
  local celestialFolder = workspace:FindFirstChild("ActiveBrainrots") and workspace.ActiveBrainrots:FindFirstChild("Celestial")
  if celestialFolder then
    for _, item in ipairs(celestialFolder:GetChildren()) do
      local handle = item:FindFirstChild("Handle")
      if handle then
        if not espObjects[handle] then
          createESP(handle, "CELESTIAL", Color3.fromRGB(0, 255, 255), "celestial")
        else
          -- Mise à jour de la distance et adaptation de la taille
          if hrp and espObjects[handle].label then
            local distance = math.floor((hrp.Position - handle.Position).Magnitude)
            local celestialName = item.Name or "Unknown"
            espObjects[handle].label.Text = '<font color="rgb(0,255,255)">CELESTIAL</font>\n' .. celestialName .. "\n" .. distance .. " studs"
            espObjects[handle].label.RichText = true
            
            -- Adapter la taille de la box selon la distance (INVERSE: loin = petit, proche = grand)
            if distance > 1000 then
              espObjects[handle].gui.Size = UDim2.new(0, 70, 0, 35)
              espObjects[handle].label.TextSize = 9
            elseif distance > 500 then
              espObjects[handle].gui.Size = UDim2.new(0, 90, 0, 45)
              espObjects[handle].label.TextSize = 10
            elseif distance > 200 then
              espObjects[handle].gui.Size = UDim2.new(0, 120, 0, 60)
              espObjects[handle].label.TextSize = 12
            else
              espObjects[handle].gui.Size = UDim2.new(0, 150, 0, 70)
              espObjects[handle].label.TextSize = 14
            end
          end
        end
      end
    end
  end
end

-- ESP Update Loop
task.spawn(function()
  while true do
    task.wait(0.1)
    if espEnabled.players then updatePlayerESP() end
    if espEnabled.brainrots then updateBrainrotESP() end
    if espEnabled.celestials then updateCelestialESP() end
  end
end)

-- === ESP TAB ===
ESPTab:Section({ Title = "Player ESP" })

ESPTab:Toggle({
  Title = "Enable Player ESP",
  Default = false,
  Callback = function(v)
    espEnabled.players = v
    if not v then updatePlayerESP() end
  end
})

ESPTab:Section({ Title = "Brainrot ESP" })

ESPTab:Toggle({
  Title = "Enable Secret Brainrot ESP",
  Default = false,
  Callback = function(v)
    espEnabled.brainrots = v
    if not v then updateBrainrotESP() end
  end
})

ESPTab:Toggle({
  Title = "Enable Celestial Brainrot ESP",
  Default = false,
  Callback = function(v)
    espEnabled.celestials = v
    if not v then updateCelestialESP() end
  end
})

-- Handle new players
Players.PlayerAdded:Connect(function(newPlayer)
  newPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if espEnabled.players then updatePlayerESP() end
  end)
end)

-- === MAIN ACTIONS ===
FarmTab:Section({ Title = "Main Actions" })

FarmTab:Button({
  Title = "Teleport to spawn",
  Callback = function()
    if hrp then hrp.CFrame = CFrame.new(BASE_POS) end
  end
})

FarmTab:Button({
  Title = "Find Best Brainrot",
  Callback = function()
    if not hrp then return end
    local secretFolder = workspace:FindFirstChild("ActiveBrainrots") and workspace.ActiveBrainrots:FindFirstChild("Secret")
    if secretFolder then
        local items = secretFolder:GetChildren()
        if #items > 0 then
            local target = items[1]:FindFirstChild("Handle")
            if target then
                hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            else
                hrp.CFrame = CFrame.new(SECRET_POS)
            end
        else
            hrp.CFrame = CFrame.new(SECRET_POS)
        end
    else
        hrp.CFrame = CFrame.new(SECRET_POS)
    end
  end
})

local tsunamiRemoved = false

FarmTab:Button({
    Title = "Remove Tsunami",
    Callback = function()
        if tsunamiRemoved then return end
        tsunamiRemoved = true
        
        local ws = game:GetService("Workspace")
        local player = game.Players.LocalPlayer

        local function nukeWave(wave)
            task.spawn(function()
                pcall(function()
                    -- Désactiver tous les scripts dans la vague
                    for _, script in ipairs(wave:GetDescendants()) do
                        if script:IsA("Script") or script:IsA("LocalScript") then
                            script.Disabled = true
                            script:Destroy()
                        end
                    end
                    
                    -- Désactiver toutes les parts
                    for _, part in ipairs(wave:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.CanTouch = false
                            part.Transparency = 1
                            part.Anchored = true
                            
                            -- Désactiver tous les événements Touched
                            for _, conn in pairs(getconnections(part.Touched)) do
                                conn:Disable()
                            end
                            for _, conn in pairs(getconnections(part.TouchEnded)) do
                                conn:Disable()
                            end
                        end
                    end
                    
                    task.wait(0.1)
                    wave:Destroy()
                end)
            end)
        end

        -- Supprimer toutes les vagues existantes
        if ws:FindFirstChild("ActiveTsunamis") then
            for _, wave in ipairs(ws.ActiveTsunamis:GetChildren()) do
                nukeWave(wave)
            end
            
            -- Empêcher les nouvelles vagues
            ws.ActiveTsunamis.ChildAdded:Connect(function(wave)
                task.wait()
                nukeWave(wave)
            end)
        end

        -- Protection supplémentaire : empêcher la mort par noyade
        task.spawn(function()
            while tsunamiRemoved do
                task.wait(0.1)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        -- Empêcher la mort
                        if hum.Health < hum.MaxHealth * 0.5 then
                            hum.Health = hum.MaxHealth
                        end
                        
                        -- Désactiver les états de noyade/dégâts
                        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    end
                end
            end
        end)
    end
})

FarmTab:Button({
    Title = "Unlock VIP",
    Callback = function()
        local vipFolder = workspace:FindFirstChild("VIPWalls")
        if not vipFolder then return end

        for _, part in ipairs(vipFolder:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Transparency = 0.5 
            end
        end

        vipFolder.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Transparency = 0.5
            end
        end)
    end
})

-- === MOVEMENT (FLY & NOCLIP) ===
FarmTab:Section({ Title = "Movement" })

local flying = false
local noclip = false
local flySpeed = 2
customWalkSpeed = 16
customJumpPower = 50
walkSpeedEnabled = false
jumpPowerEnabled = false

-- Noclip Logic
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)


FarmTab:Toggle({
  Title = "Unwalk Animation",
  Default = false,
  Callback = function(v)
    unwalkEnabled = v
    if player.Character then
      if v then
        applyUnwalkAnimation(player.Character)
      else
        restoreWalkAnimation(player.Character)
      end
    end
  end
})

FarmTab:Toggle({
  Title = "Noclip",
  Default = false,
  Callback = function(v) noclip = v end
})

FarmTab:Toggle({
  Title = "Fly Mode",
  Default = false,
  Callback = function(v)
    flying = v
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = v
    end
  end
})

FarmTab:Slider({
  Title = "Fly Speed",
  Value = {Min = 1, Max = 10, Default = 2},
  Step = 0.5,
  Callback = function(v) flySpeed = v end
})

RunService.RenderStepped:Connect(function()
    if flying and hrp and player.Character then
        local cam = workspace.CurrentCamera
        local md = player.Character.Humanoid.MoveDirection
        
        if md.Magnitude > 0 then
            local direction = (cam.CFrame.LookVector * -md.Z) + (cam.CFrame.RightVector * md.X)
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector) * CFrame.new(md.X * flySpeed, (direction.Y * flySpeed), md.Z * flySpeed)
            hrp.Velocity = Vector3.new(0,0,0)
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- === AUTO COLLECT (GLOBAL) ===
FarmTab:Section({ Title = "Global Farm" })

local autoCollect = false
local collectDelay = 0.5

FarmTab:Toggle({
  Title = "Auto Collect Money",
  Default = false,
  Callback = function(v) autoCollect = v end
})

local function fireAllGlobalSlots()
    if not hrp then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Collect" and obj:IsA("BasePart") then
            pcall(function()
                obj.Transparency = 1
                obj.CanCollide = false
                obj.CFrame = hrp.CFrame
                firetouchinterest(hrp, obj, 0)
                firetouchinterest(hrp, obj, 1)
            end)
        end
    end
end

task.spawn(function()
  while true do
    task.wait(collectDelay)
    if autoCollect then
      fireAllGlobalSlots()
    end
  end
end)

-- === COMBAT TAB ===
FarmTab:Section({ Title = "Hitbox Settings" })

FarmTab:Toggle({
  Title = "Enable Hitbox Expander",
  Default = false,
  Callback = function(v)
    hitboxEnabled = v
    if not v then
      restoreHitboxes()
    end
  end
})

FarmTab:Slider({
  Title = "Hitbox Size",
  Value = {Min = 5, Max = 50, Default = 10},
  Step = 1,
  Callback = function(v)
    hitboxSize = v
  end
})

-- === AUTO UPGRADES ===
local autoRebirth = false
local autoSpeed = false
local autoCarry = false
local autoSlots = false

UpgradeTab:Toggle({ Title = "Auto Upgrade Rebirth", Callback = function(v) autoRebirth = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Speed", Callback = function(v) autoSpeed = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Carry", Callback = function(v) autoCarry = v end })
UpgradeTab:Toggle({ Title = "Auto Upgrade Slots", Callback = function(v) autoSlots = v end })

local UpgradeBrainrot = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBrainrot")

local function upgradeAllSlots()
  for i = 1, 30 do
    pcall(function() UpgradeBrainrot:InvokeServer("Slot"..i) end)
  end
end

task.spawn(function()
  while true do
    task.wait(0.5)
    if autoSpeed then pcall(function() ReplicatedStorage.RemoteFunctions.UpgradeSpeed:InvokeServer(10) end) end
    if autoCarry then pcall(function() ReplicatedStorage.RemoteFunctions.UpgradeCarry:InvokeServer() end) end
    if autoRebirth then pcall(function() ReplicatedStorage.RemoteFunctions.Rebirth:InvokeServer() end) end
    if autoSlots then upgradeAllSlots() end
  end
end)

-- === THEME ===
ThemeTab:Dropdown({
  Title = "Select Theme",
  Values = {"Dark","Light","Rose","Plant","Red","Indigo","Sky","Violet","Amber","Emerald","Midnight","Crimson","MonokaiPro","CottonCandy"},
  Default = "Dark",
  Callback = function(t) WindUI:SetTheme(t) end
})

Window:SelectTab(1)
Window:SetVisible(true)