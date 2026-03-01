-- AzyroX Hub - Ultimate Unified Version
-- Credits: Original Gravel.cc by hmmm5651, Rebranded & Enhanced by AzyroX

repeat wait() until game:IsLoaded()

for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
    v:Disable()
end

for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
    v:Disable()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

-- UI Libraries
local Alurt = loadstring(game:HttpGet("https://raw.githubusercontent.com/azir-py/project/refs/heads/main/Zwolf/AlurtUI.lua"))()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Anti-kick system
local function setupAntiKick()
    local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller = 
          getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller
    
    if getgenv().AZ_AntiKick then return end
    
    local cloneref = cloneref or function(...) return ... end
    local clonefunction = clonefunction or function(...) return ... end
    
    local PlayersService, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), 
                                                     cloneref(game:GetService("Players").LocalPlayer), 
                                                     cloneref(game:GetService("StarterGui"))
    
    local SetCore = clonefunction(StarterGui.SetCore)
    
    getgenv().AZ_AntiKick = {
        Enabled = true,
        SendNotifications = true,
        CheckCaller = true
    }
    
    local OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local self, message = ...
        local method = getnamecallmethod()
        local isCallerValid = true
        
        if AZ_AntiKick.CheckCaller then
            local success, result = pcall(checkcaller)
            isCallerValid = success and result or true
        end
        
        if (isCallerValid or not AZ_AntiKick.CheckCaller) and 
           self == LocalPlayer and 
           method:lower() == "kick" and 
           AZ_AntiKick.Enabled then
            if AZ_AntiKick.SendNotifications then
                SetCore(StarterGui, "SendNotification", {
                    Title = "AzyroX Anti-Kick",
                    Text = "Blocked kick attempt",
                    Duration = 2
                })
            end
            return
        end
        return OldNamecall(...)
    end))
    
    local OldFunction = hookfunction(LocalPlayer.Kick, function(...)
        if AZ_AntiKick.Enabled then
            if AZ_AntiKick.SendNotifications then
                SetCore(StarterGui, "SendNotification", {
                    Title = "AzyroX Anti-Kick",
                    Text = "Blocked kick attempt",
                    Duration = 2
                })
            end
            return
        end
        return OldFunction(...)
    end)
end
setupAntiKick()

-- Notification helper
local function notify(opts)
    if typeof(Alurt) == "table" and type(Alurt.CreateNode) == "function" then
        pcall(function() Alurt.CreateNode(opts) end)
    end
end

-- Startup notifications
notify({
    Title = "AzyroX Hub",
    Content = "Script started!",
    Audio = "rbxassetid://17208361335",
    Length = 2,
    Image = "rbxassetid://4483362458",
    BarColor = Color3.fromRGB(0, 170, 255)
})

-- Utility functions
local function math_clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end
math.clamp = math_clamp

-- Valid target parts
local ValidTargetParts = {
    "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
    "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
    "RightHand", "LeftHand", "RightUpperLeg", "LeftUpperLeg",
    "RightLowerLeg", "LeftLowerLeg", "RightFoot", "LeftFoot"
}

-- ================= CONFIGURATION =================
local config = {
    -- Master settings
    masterTarget = "Players",
    masterTeamTarget = "Enemies",
    masterGetTarget = "Closest",
    ignoreForcefield = true,
    
    -- Silent Aim (HB)
    startsa = false,
    fovsize = 120,
    predic = 1,
    hbtrans = 1,
    bodypart = "Head",
    hitchance = 100,
    wallc = false,
    maxExpansion = math.huge,
    
    -- Silent Aim (HK)
    SA2_Enabled = false,
    SA2_Method = "Raycast",
    SA2_TeamTarget = "Enemies",
    SA2_Wallcheck = false,
    SA2_TargetPart = "Head",
    SA2_HitChance = 100,
    SA2_FovRadius = 100,
    SA2_FovVisible = true,
    SA2_FovTransparency = 0.90,
    SA2_FovColor = Color3.new(0, 0, 0),
    SA2_FovColourTarget = Color3.new(1, 1, 0),
    SA2_ThreeSixtyMode = false,
    SA2_GetTarget = "Closest",
    SA2_TargetRange = 1000,
    SA2_WallbangEnabled = false,
    
    -- Aimbot
    aimbotEnabled = false,
    aimbotFOVSize = 70,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    
    -- Hitbox
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Enemies",
    hitboxColor = Color3.fromRGB(255, 255, 255),
    
    -- Anti Aim
    antiAimEnabled = false,
    raycastAntiAim = false,
    antiAimTPDistance = 3,
    antiAimAbovePlayer = false,
    antiAimAboveHeight = 10,
    antiAimBehindPlayer = false,
    antiAimBehindDistance = 5,
    antiAimOrbitEnabled = false,
    antiAimOrbitSpeed = 5,
    antiAimOrbitRadius = 5,
    antiAimOrbitHeight = 0,
    antiAimGetTarget = "Closest",
    
    -- Auto Farm
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargetPart = "Head",
    autoFarmVerticalOffset = 0,
    autoFarmMinRange = 0,
    autoFarmMaxRange = 50,
    autoFarmWallCheck = false,
    gp = 200,
    
    -- ESP
    espMasterEnabled = false,
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    prefTextESP = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefHeadDotESP = false,
    prefColorByHealth = false,
    lineESPEnabled = false,
    lineESPOnlyTarget = false,
    lineStartPosition = "Center",
    lineColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1,
    
    -- Colors
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    
    -- Reach
    reach = {
        enabled = false,
        type = "Sphere",
        distance = 10,
        autoSwing = {
            enabled = false,
            delay = 0.1
        },
    },
    visualizer = {
        enabled = false,
        color = Color3.fromRGB(255, 0, 0),
        material = "ForceField",
        transparency = 0.6
    },
    materials = {
        ForceField = Enum.Material.ForceField,
        Plastic = Enum.Material.Plastic,
        Glass = Enum.Material.Glass,
        Neon = Enum.Material.Neon,
        SmoothPlastic = Enum.Material.SmoothPlastic,
        Metal = Enum.Material.Metal,
        DiamondPlate = Enum.Material.DiamondPlate
    },
    
    -- Client
    clientMasterEnabled = false,
    clientWalkSpeed = 16,
    clientJumpPower = 50,
    clientNoclipEnabled = false,
    clientCFrameWalkToggle = false,
    clientCFrameSpeed = 1,
    
    -- Misc
    rfd = false,
    antiafk = false,
    fastspawn = false,
    LowRender = true,
    animations = false,
    anim_speed = 1,
    R15 = false,
    Ids_R6 = {"90814669", "182436935", "48957148", "35634514", "27789359", "327324663"},
    Ids_R15 = {"15698404340", "10147821284", "10147823318", "10714340543", "2733837253", "10714089137"},
    targetSeenMode = "Switch",
    targetSeenSwitchRate = 0.2,
    QuickToggles = false,
    
    -- Keybinds
    KeybindsEnabled = true,
    HoldKeysEnabled = false,
    Keybinds = {
        HoldKeybind = "LeftAlt",
        silentaim = "E",
        aimbot = "Q",
        autofarm = "F",
        antiaim = "L",
        hitbox = "G",
        esp = "Z",
        client = "V",
        silentaimwallcheck = "B",
        aimbotwallcheck = "H",
        silentaimhk = "R",
        silentaimhkwallcheck = "T",
    },
    
    -- Data storage
    originalSizes = {},
    activeApplied = {},
    espData = {},
    highlightData = {},
    lineESPData = {},
    currentTarget = nil,
    aimbotCurrentTarget = nil,
    SA2_currentTarget = nil,
    targethbSizes = {},
    playerConnections = {},
    characterConnections = {},
    centerLocked = {},
    hitboxExpandedParts = {},
    hitboxOriginalSizes = {},
    hitboxLastSize = {},
    autoFarmOriginalPositions = {},
    autoFarmCompleted = {},
    autoFarmTargets = {},
    autoFarmIndex = 1,
    autoFarmLoop = nil,
    currentAutoFarmTarget = nil,
    originalPosition = nil,
    isTeleported = false,
    currentAntiAimTarget = nil,
    targetSeenTargets = {},
    clientOriginals = {},
    clientConnections = {},
    _tpwalking = false,
    clientWalkEnabled = false,
    clientJumpEnabled = false,
    clientNoclip = false,
    clientCFrameWalkEnabled = false,
}

-- Load required modules
local func = loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/HBSS/refs/heads/main/SA2_Function.lua"))()
local FindTool = loadstring(game:HttpGet("https://raw.githubusercontent.com/hm5650/HBSS/refs/heads/main/SA2_FindTool.lua"))()

-- ================= HELPER FUNCTIONS =================

local function hasForcefield(character)
    if not character or not config.ignoreForcefield then return false end
    
    if character:FindFirstChildOfClass("ForceField") then return true end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("ForceField") then return true end
        local nameLower = child.Name:lower()
        if nameLower:find("shield") or nameLower:find("forcefield") or 
           nameLower:find("invincible") or nameLower:find("invulnerable") then
            return true
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and (humanoid.MaxHealth == math.huge or humanoid.Health == math.huge) then
        return true
    end
    
    return false
end

local function isTeammate(p)
    if not (localPlayer and p) or typeof(p) ~= "Instance" or not p:IsA("Player") then 
        return false 
    end
    return localPlayer.Team and p.Team and localPlayer.Team == p.Team
end

local function getTargetCharacter(target)
    if not target then return nil end
    if typeof(target) == "Instance" then
        if target:IsA("Player") then return target.Character end
        if target:IsA("Model") then return target end
    end
    return nil
end

local function getTargetName(target)
    if not target then return "Unknown" end
    return typeof(target) == "Instance" and target.Name or tostring(target)
end

local function isNPCModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health ~= nil and 
           (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head"))
end

local function plralive(target)
    if not target then return false end
    local char = getTargetCharacter(target)
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function shouldTargetPlayer(player, mode)
    if not player or player == localPlayer then return false end
    if typeof(player) == "Instance" and player:IsA("Model") then
        return mode ~= "Teams"
    end
    if mode == "Enemies" then return not isTeammate(player)
    elseif mode == "Teams" then return isTeammate(player)
    elseif mode == "All" then return true end
    return false
end

local function addesp(targetPlayer)
    if not targetPlayer then return false end
    if (config.masterTarget == "NPCs" or config.masterTarget == "Both") and 
       typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Model") then
        return true
    end
    if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") and targetPlayer ~= localPlayer then
        return shouldTargetPlayer(targetPlayer, config.masterTeamTarget or "Enemies")
    end
    return false
end

local function getAllTargets(getTargetSeen)
    local targets = {}
    
    if config.masterTarget == "Players" or config.masterTarget == "Both" then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= localPlayer then
                if getTargetSeen then
                    local char = getTargetCharacter(pl)
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                        if root then
                            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                            if onScreen and screenPos.Z > 0 then
                                local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                local fovSize = config.masterGetTarget == "TargetSeen" and config.fovsize or config.aimbotFOVSize
                                if dist <= fovSize then
                                    table.insert(targets, pl)
                                end
                            end
                        end
                    end
                else
                    table.insert(targets, pl)
                end
            end
        end
    end
    
    if config.masterTarget == "NPCs" or config.masterTarget == "Both" then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isNPCModel(obj) and not Players:GetPlayerFromCharacter(obj) then
                table.insert(targets, obj)
            end
        end
    end
    
    return targets
end

-- ================= ANTI-AFK =================
localPlayer.Idled:Connect(function()
    if config.antiafk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ================= LOW RENDER =================
local function LowRender()
    if config.LowRender then
        pcall(function()
            settings().Physics.AllowSleep = true
            settings().Rendering.QualityLevel = 1
            settings().Rendering.EagerBulkExecution = true
            settings().Rendering.EnableFRM = true
            settings().Rendering.MeshPartDetailLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Technology = Enum.Technology.Legacy
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end
        end)
    end
end

-- ================= FAST SPAWN =================
function respawn(plr)
    if not config.fastspawn then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ogpos = hrp.CFrame
    local ogpos2 = camera.CFrame
    local rejectDeletions = gethiddenproperty and 
                           gethiddenproperty(Workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
    
    if rejectDeletions and replicatesignal then
        replicatesignal(plr.ConnectDiedSignalBackend)
        task.wait(Players.RespawnTime - 0.01)
        replicatesignal(plr.Kill)
    else
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
        char:ClearAllChildren()
        local newgen = Instance.new("Model")
        newgen.Parent = Workspace
        plr.Character = newgen
        task.wait()
        plr.Character = char
        newgen:Destroy()
    end
    
    task.spawn(function()
        local newChar = plr.CharacterAdded:Wait()
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHrp then
            newHrp.CFrame = ogpos
            camera.CFrame = ogpos2
        end
    end)
end

-- ================= PART CLAIM =================
local function pc()
    task.spawn(function()
        while true do
            pcall(function()
                localPlayer.ReplicationFocus = Workspace
                localPlayer.MaximumSimulationRadius = math.huge
                localPlayer.SimulationRadius = config.gp
            end)
            task.wait(0.1)
        end
    end)
end
pc()

-- ================= ANIMATIONS =================
local function loadAnimation(id)
    if not tonumber(id) then return nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    return anim
end

local animationTrack = nil
local animationLoopConnection = nil

local function stopCurrentAnimation()
    if animationTrack then
        animationTrack:Stop()
        animationTrack:Destroy()
        animationTrack = nil
    end
    if animationLoopConnection then
        animationLoopConnection:Disconnect()
        animationLoopConnection = nil
    end
end

local function playAnimation(animationId, isR15)
    if not config.animations then return end
    stopCurrentAnimation()
    
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    
    local animation = loadAnimation(animationId)
    if not animation then return end
    
    animationTrack = animator:LoadAnimation(animation)
    if not animationTrack then return end
    
    animationTrack:AdjustSpeed(config.anim_speed)
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Core
    animationTrack:Play()
    
    animationLoopConnection = humanoid.Died:Connect(function()
        task.wait(0.1)
        if config.animations then playAnimation(animationId, isR15) end
    end)
    
    notify({
        Title = "Animation",
        Content = "Playing ID: " .. animationId,
        Length = 1,
        Image = "rbxassetid://4483362458",
        BarColor = Color3.fromRGB(0, 170, 255)
    })
end

local function updateAnimation()
    if not config.animations then
        stopCurrentAnimation()
    elseif animationTrack then
        animationTrack:AdjustSpeed(config.anim_speed)
    end
end

-- ================= WALL CHECK =================
local function wallCheck(targetPos, sourcePos)
    if not config.wallc then return true end
    if (targetPos - sourcePos).Magnitude <= 0 then return true end
    
    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {localPlayer.Character}
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then table.insert(ignoreList, otherPlayer.Character) end
    end
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end
    return true
end

-- ================= AIMBOT WALL CHECK =================
local function aimbotWallCheck(targetPos, sourcePos)
    if not config.aimbotWallCheck then return true end
    if (targetPos - sourcePos).Magnitude <= 0 then return true end
    
    local rayDirection = (targetPos - sourcePos)
    local ray = Ray.new(sourcePos, rayDirection.Unit * rayDirection.Magnitude)
    local ignoreList = {localPlayer.Character}
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.Character then table.insert(ignoreList, otherPlayer.Character) end
    end
    
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit and position then
        local distanceToTarget = (targetPos - sourcePos).Magnitude
        local distanceToHit = (position - sourcePos).Magnitude
        return distanceToHit >= (distanceToTarget - 2)
    end
    return true
end

-- ================= SILENT AIM (HB) FUNCTIONS =================
local function saveOriginalPartInfo(targetPlayer, part)
    if not targetPlayer or not part then return end
    config.originalSizes[targetPlayer] = {
        partName = part.Name,
        size = part.Size,
    }
end

local function chooseBodyPartInstance(target)
    local char = getTargetCharacter(target)
    if not char then return nil, "Head" end
    
    local bp = config.bodypart or "Head"
    
    if bp == "Head" then
        return char:FindFirstChild("Head"), "Head"
    elseif bp == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart"), "HumanoidRootPart"
    elseif bp == "Both" then
        local primary = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        return primary, primary and primary.Name or "Head"
    else
        return char:FindFirstChild(bp) or char:FindFirstChild("Head"), "Head"
    end
end

local function calculateDiameter(worldDist, screenRadius, cam)
    if not cam then cam = camera end
    if not cam then return 0.1 end
    
    local viewportSize = cam.ViewportSize
    local H = viewportSize.Y
    local vFovRad = math.rad(cam.FieldOfView)
    local halfVFov = vFovRad / 2
    local alpha = (screenRadius / (H / 2)) * halfVFov
    return math.max(0.01, worldDist * math.tan(alpha) * 2)
end

local function applySizeToPart(targetPlayer, targetDiameter, chosenPart)
    local char = getTargetCharacter(targetPlayer)
    if not char or targetPlayer == localPlayer or not plralive(targetPlayer) then return end
    
    local part = chosenPart or select(1, chooseBodyPartInstance(targetPlayer))
    if not part then return end
    
    if not config.originalSizes[targetPlayer] then
        saveOriginalPartInfo(targetPlayer, part)
    end
    
    local expansionSize = Vector3.new(targetDiameter, targetDiameter, targetDiameter)
    local chance = math.clamp(config.hitchance, 0, 100)
    local useExpanded = chance >= 100 or (chance > 0 and math.random(1, 100) <= chance)
    
    if useExpanded then
        config.targethbSizes[targetPlayer] = expansionSize
    else
        local original = config.originalSizes[targetPlayer]
        config.targethbSizes[targetPlayer] = original and original.size or Vector3.new(0.05, 0.05, 0.05)
    end
    
    config.activeApplied[targetPlayer] = true
end

local function restorePartForPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == localPlayer then return end
    
    local original = config.originalSizes[targetPlayer]
    if original then
        local char = getTargetCharacter(targetPlayer)
        local part = char and char:FindFirstChild(original.partName)
        if part and original.size then
            pcall(function()
                part.Size = original.size
                part.Transparency = 1
                part.CanCollide = false
                part.Massless = false
            end)
        end
    end
    
    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
    config.centerLocked[targetPlayer] = nil
end

-- ================= SILENT AIM (HK) FUNCTIONS =================
local function ArePlayersSameTeam(player1, player2)
    return player1 and player2 and player1.Team and player2.Team and player1.Team == player2.Team
end

local function ShouldTargetPlayerSA2(targetPlayer)
    if targetPlayer == localPlayer then return false end
    if config.SA2_TeamTarget == "All" then return true
    elseif config.SA2_TeamTarget == "Enemies" then return not ArePlayersSameTeam(localPlayer, targetPlayer)
    elseif config.SA2_TeamTarget == "Teams" then return ArePlayersSameTeam(localPlayer, targetPlayer) end
    return false
end

local function IsPlayerVisible(Player)
    local PlayerChar = Player.Character
    local LocalChar = localPlayer.Character
    if not (PlayerChar and LocalChar) then return false end
    
    local targetPart = PlayerChar:FindFirstChild(config.SA2_TargetPart) or PlayerChar:FindFirstChild("HumanoidRootPart")
    if not targetPart then return false end
    
    local CastPoints = {targetPart.Position, LocalChar, PlayerChar}
    local IgnoreList = {LocalChar, PlayerChar}
    local Obscuring = #camera:GetPartsObscuringTarget(CastPoints, IgnoreList)
    return Obscuring == 0
end

local function GetClosestPlayerSA2()
    if not localPlayer.Character then
        config.SA2_currentTarget = nil
        return nil
    end
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local allTargets = {}
    local cameraPos = camera.CFrame.Position
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= localPlayer and ShouldTargetPlayerSA2(Player) then
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChild("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    if config.SA2_Wallcheck and not IsPlayerVisible(Player) then continue end
                    
                    local foundPart = Character:FindFirstChild("HumanoidRootPart") or 
                                     Character:FindFirstChild("Head") or 
                                     Character:FindFirstChild("Torso")
                    if not foundPart then continue end
                    
                    local worldDist = (cameraPos - foundPart.Position).Magnitude
                    if worldDist > config.SA2_TargetRange then continue end
                    
                    if config.SA2_ThreeSixtyMode then
                        table.insert(allTargets, {
                            player = Player,
                            part = foundPart,
                            health = Humanoid.Health,
                            worldDist = worldDist,
                            in360Mode = true
                        })
                    else
                        local screenPos, onScreen = func.GetScreenPosition(foundPart.Position)
                        if onScreen then
                            screenPos = screenPos + Vector2.new(0, config.SA2_TArea or 35)
                            local distToFov = (screenCenter - screenPos).Magnitude
                            if distToFov <= config.SA2_FovRadius then
                                table.insert(allTargets, {
                                    player = Player,
                                    part = foundPart,
                                    health = Humanoid.Health,
                                    distanceToCenter = distToFov,
                                    worldDist = worldDist
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    if #allTargets == 0 then
        config.SA2_currentTarget = nil
        return nil
    end
    
    local best = nil
    local getTarget = config.masterGetTarget or config.SA2_GetTarget or "Closest"
    
    if getTarget == "Lowest Health" then
        local lowestHealth = math.huge
        for _, target in ipairs(allTargets) do
            if target.health < lowestHealth then
                lowestHealth = target.health
                best = target
            end
        end
    elseif getTarget == "TargetSeen" and not config.SA2_ThreeSixtyMode then
        local inFOV = {}
        for _, target in ipairs(allTargets) do
            if target.distanceToCenter then
                table.insert(inFOV, target)
            end
        end
        if #inFOV > 0 then
            table.sort(inFOV, function(a, b) return a.distanceToCenter < b.distanceToCenter end)
            best = inFOV[1]
        end
    else
        local closest = math.huge
        for _, target in ipairs(allTargets) do
            if config.SA2_ThreeSixtyMode then
                if target.worldDist < closest then
                    closest = target.worldDist
                    best = target
                end
            elseif target.distanceToCenter and target.distanceToCenter < closest then
                closest = target.distanceToCenter
                best = target
            end
        end
    end
    
    config.SA2_currentTarget = best and best.player
    return best and best.part
end

-- Expected arguments for hooking
local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean", "boolean"}},
    FindPartOnRayWithWhitelist = {ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean"}},
    FindPartOnRay = {ArgCountRequired = 2, Args = {"Instance", "Ray", "Instance", "boolean", "boolean"}},
    Raycast = {ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"}},
    Cast = {ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"}}
}

local function validate_args(Args, RayMethod)
    if not RayMethod or not Args or #Args < RayMethod.ArgCountRequired then return false end
    local matches = 0
    for i = 1, RayMethod.ArgCountRequired do
        if typeof(Args[i]) == RayMethod.Args[i] then
            matches = matches + 1
        end
    end
    return matches >= RayMethod.ArgCountRequired
end

local function calc_chance(chance)
    if chance >= 100 then return true
    elseif chance <= 0 then return false
    else return math.random(1, 100) <= chance end
end

-- Hook namecall for SA2
local OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    if not config.SA2_Enabled then return OldNamecall(...) end
    
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    
    if self == Workspace and not checkcaller() and calc_chance(config.SA2_HitChance) then
        local HitPart = GetClosestPlayerSA2()
        if HitPart then
            config.SA2_FovIsTargeted = true
            
            if config.SA2_WallbangEnabled then
                if Method == "Raycast" then
                    return {
                        Instance = HitPart,
                        Position = HitPart.Position,
                        Normal = (HitPart.Position - Arguments[2]).Unit,
                        Material = HitPart.Material
                    }
                end
            end
            
            if config.SA2_Method == "All" or config.SA2_Method == Method then
                if Method == "Raycast" or Method == "Cast" then
                    if validate_args(Arguments, ExpectedArguments[Method]) then
                        Arguments[3] = func.Direction(Arguments[2], HitPart.Position)
                        return OldNamecall(unpack(Arguments))
                    end
                elseif Method:find("FindPartOnRay") then
                    if validate_args(Arguments, ExpectedArguments[Method]) then
                        local A_Ray = Arguments[2]
                        Arguments[2] = Ray.new(A_Ray.Origin, func.Direction(A_Ray.Origin, HitPart.Position))
                        return OldNamecall(unpack(Arguments))
                    end
                end
            end
        else
            config.SA2_FovIsTargeted = false
        end
    end
    
    return OldNamecall(...)
end))

-- ================= AIMBOT FUNCTIONS =================
local function getAimbotTargetPart(target)
    if not target then return nil end
    local char = getTargetCharacter(target)
    if not char then return nil end
    local partName = config.aimbotTargetPart or "Head"
    
    if partName == "Head" then return char:FindFirstChild("Head")
    elseif partName == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart")
    elseif partName == "Torso" then return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else return char:FindFirstChild("Head") end
end

local function shouldTargetAimbot(target)
    if not target or target == localPlayer or not plralive(target) then return false end
    local char = getTargetCharacter(target)
    if config.ignoreForcefield and char and hasForcefield(char) then return false end
    if typeof(target) == "Instance" and target:IsA("Model") then
        return config.masterTarget == "NPCs" or config.masterTarget == "Both"
    end
    return shouldTargetPlayer(target, config.masterTeamTarget or "Enemies")
end

local function smoothAim(currentCFrame, targetCFrame, strength)
    return currentCFrame:Lerp(targetCFrame, math.clamp(strength or 0.5, 0, 1))
end

local aimbot360LoopRunning = false
local aimbot360LoopTask = nil

local function aimbotUpdate()
    if not config.aimbotEnabled or not camera then
        config.aimbotCurrentTarget = nil
        return
    end
    
    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local fovRadius = config.aimbot360Enabled and math.huge or config.aimbotFOVSize
    local cameraPos = camera.CFrame.Position
    
    local potentialTargets = {}
    
    for _, target in ipairs(getAllTargets()) do
        if shouldTargetAimbot(target) then
            local targetPart = getAimbotTargetPart(target)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local distPx = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                
                if config.aimbot360Enabled or (onScreen and distPx <= fovRadius) then
                    if aimbotWallCheck(targetPart.Position, cameraPos) then
                        local humanoid = getTargetCharacter(target) and 
                                       getTargetCharacter(target):FindFirstChildOfClass("Humanoid")
                        table.insert(potentialTargets, {
                            target = target,
                            part = targetPart,
                            worldDist = (targetPart.Position - cameraPos).Magnitude,
                            health = humanoid and humanoid.Health or math.huge
                        })
                    end
                end
            end
        end
    end
    
    local best = nil
    local mode = config.aimbotGetTarget or config.masterGetTarget or "Closest"
    
    if #potentialTargets > 0 then
        if mode == "Lowest Health" then
            local lowest = math.huge
            for _, t in ipairs(potentialTargets) do
                if t.health < lowest then
                    lowest = t.health
                    best = t
                end
            end
        else
            local closest = math.huge
            for _, t in ipairs(potentialTargets) do
                if t.worldDist < closest then
                    closest = t.worldDist
                    best = t
                end
            end
        end
    end
    
    config.aimbotCurrentTarget = best and best.target
    
    if best and best.part and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local targetCFrame = CFrame.lookAt(camera.CFrame.Position, best.part.Position)
            camera.CFrame = smoothAim(camera.CFrame, targetCFrame, config.aimbotStrength)
        end
    end
end

local function aimbot360UpdateLoop()
    if aimbot360LoopRunning or not config.aimbotEnabled or not config.aimbot360Enabled then return end
    
    aimbot360LoopRunning = true
    aimbot360LoopTask = task.spawn(function()
        while aimbot360LoopRunning and config.aimbotEnabled and config.aimbot360Enabled do
            aimbotUpdate()
            task.wait(0.1)
        end
        aimbot360LoopRunning = false
        aimbot360LoopTask = nil
    end)
end

local function toggle360Aimbot(state)
    config.aimbot360Enabled = state
    if state then
        config.aimbot360OriginalFOV = config.aimbotFOVSize
        config.aimbotFOVSize = math.huge
        if not config.aimbotEnabled then
            config.aimbotEnabled = true
        end
        aimbot360UpdateLoop()
    else
        config.aimbotFOVSize = config.aimbot360OriginalFOV or 100
        aimbot360LoopRunning = false
    end
    updateAimbotFOVRing()
end

local function handleAimbotToggle(state)
    config.aimbotEnabled = state
    if state and config.aimbot360Enabled then
        aimbot360UpdateLoop()
    elseif not state then
        aimbot360LoopRunning = false
    end
    updateAimbotFOVRing()
end

-- ================= HITBOX FUNCTIONS =================
local function tnormalsize(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if torso and not config.hitboxOriginalSizes[targetPlayer] then
        config.hitboxOriginalSizes[targetPlayer] = {
            part = torso,
            size = torso.Size
        }
    end
end

local function expandhb(targetPlayer, size)
    if not targetPlayer or targetPlayer == localPlayer or not plralive(targetPlayer) or not config.hitboxEnabled then
        return
    end
    
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    
    tnormalsize(targetPlayer)
    local expansionSize = Vector3.new(size, size, size)
    config.hitboxExpandedParts[targetPlayer] = {
        part = torso,
        targetSize = expansionSize
    }
    
    pcall(function()
        torso.Size = expansionSize
        torso.Transparency = 0.9
        torso.CanCollide = false
        torso.Massless = true
        if config.hitboxColor then
            torso.Color = config.hitboxColor
        end
    end)
end

local function restoreTorso(targetPlayer)
    if not targetPlayer then return end
    local original = config.hitboxOriginalSizes[targetPlayer]
    if original and original.part and original.part.Parent then
        pcall(function()
            original.part.Size = original.size
            original.part.Transparency = 0
            original.part.CanCollide = true
        end)
    end
    config.hitboxExpandedParts[targetPlayer] = nil
    config.hitboxOriginalSizes[targetPlayer] = nil
end

local function targethb(player)
    if not player or player == localPlayer or not plralive(player) then return false end
    local char = getTargetCharacter(player)
    if config.ignoreForcefield and char and hasForcefield(char) then return false end
    if typeof(player) == "Instance" and player:IsA("Model") then
        return config.masterTeamTarget ~= "Teams"
    end
    return shouldTargetPlayer(player, config.masterTeamTarget or "Enemies")
end

local function applyhb()
    if not config.hitboxEnabled then
        for player in pairs(config.hitboxExpandedParts) do
            restoreTorso(player)
        end
        return
    end
    
    for _, target in ipairs(getAllTargets()) do
        if targethb(target) then
            expandhb(target, config.hitboxSize)
        else
            restoreTorso(target)
        end
    end
end

local function updateHitboxes()
    if not config.hitboxEnabled then
        for player in pairs(config.hitboxExpandedParts) do
            restoreTorso(player)
        end
        return
    end
    
    for player, data in pairs(config.hitboxExpandedParts) do
        if player and plralive(player) and getTargetCharacter(player) then
            local torso = getTargetCharacter(player):FindFirstChild("Torso") or 
                         getTargetCharacter(player):FindFirstChild("UpperTorso")
            if torso and data.targetSize then
                pcall(function()
                    torso.Size = data.targetSize
                    torso.Transparency = 0.9
                    torso.CanCollide = false
                    torso.Massless = true
                end)
            end
        else
            restoreTorso(player)
        end
    end
end

-- ================= HB LOOP (SILENT AIM HB) =================
local function hb()
    for playerObj, targetSize in pairs(config.targethbSizes) do
        if playerObj and playerObj ~= localPlayer and getTargetCharacter(playerObj) and plralive(playerObj) then
            local part = getTargetCharacter(playerObj):FindFirstChild(config.originalSizes[playerObj] and config.originalSizes[playerObj].partName) or
                        getTargetCharacter(playerObj):FindFirstChild(config.bodypart) or
                        getTargetCharacter(playerObj):FindFirstChild("Head") or
                        getTargetCharacter(playerObj):FindFirstChild("HumanoidRootPart")
            
            if part then
                local newSize = part.Size:Lerp(targetSize, math.clamp(config.predic, 0, 1))
                pcall(function()
                    part.Size = newSize
                    part.Transparency = config.hbtrans
                    part.CanCollide = false
                    part.Massless = (part.Name ~= "HumanoidRootPart")
                end)
            end
        else
            restorePartForPlayer(playerObj)
        end
    end
    updateHitboxes()
end

-- ================= ANTI-AIM FUNCTIONS =================
local function raycastFromPlayer(player)
    if not player or not player.Character then return false end
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local lookVector = head.CFrame.LookVector
    local ray = Ray.new(head.Position, lookVector * 1000)
    local ignoreList = {player.Character}
    
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    if hit then
        local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
        if hitPlayer == localPlayer then
            return true, lookVector
        end
    end
    return false
end

local function teleportLocalPlayer(direction, distance)
    if not localPlayer.Character then return end
    local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not config.originalPosition then
        config.originalPosition = hrp.Position
    end
    
    pcall(function()
        hrp.CFrame = CFrame.new(hrp.Position + (direction * distance))
    end)
    config.isTeleported = true
end

local function returnToOriginalPosition()
    if not config.originalPosition or not localPlayer.Character then return end
    local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function() hrp.CFrame = CFrame.new(config.originalPosition) end)
    end
    config.originalPosition = nil
    config.isTeleported = false
    config.currentAntiAimTarget = nil
end

local function findClosestEnemy()
    if not localPlayer.Character then return nil end
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local best = nil
    local bestDist = math.huge
    local bestHealth = math.huge
    local mode = config.antiAimGetTarget or config.masterGetTarget or "Closest"
    
    for _, t in ipairs(getAllTargets()) do
        if t ~= localPlayer and plralive(t) then
            local tgtChar = getTargetCharacter(t)
            local root = tgtChar and (tgtChar:FindFirstChild("HumanoidRootPart") or tgtChar:FindFirstChild("Head"))
            local humanoid = tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and not (config.ignoreForcefield and hasForcefield(tgtChar)) then
                local dist = (localRoot.Position - root.Position).Magnitude
                if mode == "Lowest Health" then
                    if humanoid.Health < bestHealth then
                        bestHealth = humanoid.Health
                        best = t
                    end
                elseif dist < bestDist then
                    bestDist = dist
                    best = t
                end
            end
        end
    end
    return best
end

local function antiAimUpdate()
    if not config.antiAimEnabled then
        if config.isTeleported then returnToOriginalPosition() end
        return
    end
    
    if config.antiAimOrbitEnabled then
        local target = findClosestEnemy()
        if target then
            local tgtChar = getTargetCharacter(target)
            local targetPart = tgtChar:FindFirstChild("Head") or tgtChar:FindFirstChild("HumanoidRootPart")
            if targetPart and localPlayer.Character then
                config.currentAntiAimTarget = target
                if not config.originalPosition then
                    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then config.originalPosition = localRoot.Position end
                end
                local angle = tick() * config.antiAimOrbitSpeed
                local offset = Vector3.new(
                    math.cos(angle) * config.antiAimOrbitRadius,
                    config.antiAimOrbitHeight,
                    math.sin(angle) * config.antiAimOrbitRadius
                )
                local newPos = targetPart.Position + offset
                pcall(function()
                    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        localRoot.CFrame = CFrame.new(newPos, targetPart.Position)
                    end
                end)
                config.isTeleported = true
            end
        elseif config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if config.antiAimAbovePlayer then
        local target = findClosestEnemy()
        if target then
            local tgtChar = getTargetCharacter(target)
            local targetRoot = tgtChar and tgtChar:FindFirstChild("HumanoidRootPart")
            if targetRoot and localPlayer.Character then
                local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    if not config.originalPosition then config.originalPosition = localRoot.Position end
                    local abovePos = targetRoot.Position + Vector3.new(0, config.antiAimAboveHeight, 0)
                    pcall(function() localRoot.CFrame = CFrame.new(abovePos) end)
                    config.isTeleported = true
                    config.currentAntiAimTarget = target
                end
            end
        elseif config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if config.antiAimBehindPlayer then
        local target = findClosestEnemy()
        if target then
            local tgtChar = getTargetCharacter(target)
            local targetRoot = tgtChar and tgtChar:FindFirstChild("HumanoidRootPart")
            if targetRoot and localPlayer.Character then
                local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    if not config.originalPosition then config.originalPosition = localRoot.Position end
                    local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * config.antiAimBehindDistance)
                    pcall(function() localRoot.CFrame = CFrame.new(behindPos) end)
                    config.isTeleported = true
                    config.currentAntiAimTarget = target
                end
            end
        elseif config.isTeleported then
            returnToOriginalPosition()
        end
        return
    end
    
    if config.raycastAntiAim then
        local wasTargeted = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and plralive(player) then
                local isLooking, lookVector = raycastFromPlayer(player)
                if isLooking then
                    wasTargeted = true
                    config.currentAntiAimTarget = player
                    local dir = Vector3.new(-lookVector.Z, 0, lookVector.X)
                    if math.random(1, 2) == 1 then dir = -dir end
                    teleportLocalPlayer(dir.Unit, config.antiAimTPDistance)
                    break
                end
            end
        end
        if not wasTargeted and config.isTeleported then
            returnToOriginalPosition()
        end
    end
end

-- ================= AUTO FARM FUNCTIONS =================
local function saveTargetOriginalPosition(target)
    local tgtChar = getTargetCharacter(target)
    if not tgtChar then return end
    local root = tgtChar:FindFirstChild("HumanoidRootPart")
    if root then
        config.autoFarmOriginalPositions[target] = {
            cframe = root.CFrame,
            timestamp = tick()
        }
    end
end

local function restoreTargetOriginalPosition(target)
    local tgtChar = getTargetCharacter(target)
    if not tgtChar then return end
    local root = tgtChar:FindFirstChild("HumanoidRootPart")
    if root and config.autoFarmOriginalPositions[target] then
        pcall(function() root.CFrame = config.autoFarmOriginalPositions[target].cframe end)
        config.autoFarmOriginalPositions[target] = nil
    end
end

local function canSeeTarget(target)
    if not config.autoFarmWallCheck then return true end
    local tgtChar = getTargetCharacter(target)
    if not tgtChar or not localPlayer.Character then return false end
    
    local targetRoot = tgtChar:FindFirstChild("HumanoidRootPart") or tgtChar:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head")
    if not targetRoot or not localRoot then return false end
    
    local ray = Ray.new(localRoot.Position, (targetRoot.Position - localRoot.Position).Unit * 1000)
    local ignoreList = {localPlayer.Character}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignoreList, p.Character) end
    end
    
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit == nil or hit.Parent == tgtChar or hit.Parent.Parent == tgtChar
end

local function getValidAutoFarmTargets()
    local valid = {}
    local localRoot = localPlayer.Character and (localPlayer.Character:FindFirstChild("HumanoidRootPart") or localPlayer.Character:FindFirstChild("Head"))
    if not localRoot then return valid end
    
    for _, t in ipairs(getAllTargets()) do
        if t ~= localPlayer and plralive(t) and not config.autoFarmCompleted[t] then
            local should = false
            if config.masterTarget == "NPCs" then
                should = typeof(t) == "Instance" and t:IsA("Model")
            elseif config.masterTarget == "Players" then
                should = typeof(t) == "Instance" and t:IsA("Player") and 
                        (config.masterTeamTarget == "All" or not isTeammate(t))
            elseif config.masterTarget == "Both" then
                should = true
            end
            
            if should then
                local char = getTargetCharacter(t)
                if char and not (config.ignoreForcefield and hasForcefield(char)) then
                    local targetRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                    if targetRoot then
                        local dist = (localRoot.Position - targetRoot.Position).Magnitude
                        if (config.autoFarmMinRange <= 0 or dist >= config.autoFarmMinRange) and
                           (config.autoFarmMaxRange <= 0 or dist <= config.autoFarmMaxRange) and
                           (not config.autoFarmWallCheck or canSeeTarget(t)) then
                            table.insert(valid, t)
                        end
                    end
                end
            end
        end
    end
    
    table.sort(valid, function(a, b)
        local ra = getTargetCharacter(a) and (getTargetCharacter(a):FindFirstChild("HumanoidRootPart") or getTargetCharacter(a):FindFirstChild("Head"))
        local rb = getTargetCharacter(b) and (getTargetCharacter(b):FindFirstChild("HumanoidRootPart") or getTargetCharacter(b):FindFirstChild("Head"))
        if not ra then return false end
        if not rb then return true end
        return (localRoot.Position - ra.Position).Magnitude < (localRoot.Position - rb.Position).Magnitude
    end)
    
    return valid
end

local function tptocrossWithAlignment(target)
    local tgtChar = getTargetCharacter(target)
    if not tgtChar or not localPlayer.Character or not camera then return false end
    
    local targetRoot = tgtChar:FindFirstChild("HumanoidRootPart")
    local targetHead = tgtChar:FindFirstChild("Head")
    if not targetRoot then return false end
    
    if not canSeeTarget(target) then return false end
    
    local dist = (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position - targetRoot.Position).Magnitude
    if (config.autoFarmMinRange > 0 and dist < config.autoFarmMinRange) or
       (config.autoFarmMaxRange > 0 and dist > config.autoFarmMaxRange) then
        return false
    end
    
    if not config.autoFarmOriginalPositions[target] then
        saveTargetOriginalPosition(target)
    end
    
    local cameraCFrame = camera.CFrame
    local targetPos = cameraCFrame.Position + (cameraCFrame.LookVector * config.autoFarmDistance) +
                     Vector3.new(0, config.autoFarmVerticalOffset, 0)
    
    local alignPart = (config.autoFarmTargetPart == "Head" and targetHead) or targetRoot
    local newRootPos = targetPos - (alignPart.Position - targetRoot.Position)
    
    pcall(function()
        targetRoot.CFrame = CFrame.lookAt(newRootPos, cameraCFrame.Position)
    end)
    
    return true
end

local function teleportTargetToLocalPlayerFront(target)
    local tgtChar = getTargetCharacter(target)
    if not tgtChar or not localPlayer.Character then return false end
    
    local targetRoot = tgtChar:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then return false end
    
    local frontPos = localRoot.Position + (localRoot.CFrame.LookVector * config.autoFarmDistance)
    frontPos = Vector3.new(frontPos.X, targetRoot.Position.Y, frontPos.Z)
    
    pcall(function()
        targetRoot.CFrame = CFrame.new(frontPos, localRoot.Position)
    end)
    
    return true
end

local function autoFarmProcess()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    
    config.autoFarmLoop = RunService.Heartbeat:Connect(function()
        if not config.autoFarmEnabled or not localPlayer.Character then
            if config.autoFarmLoop then
                config.autoFarmLoop:Disconnect()
                config.autoFarmLoop = nil
            end
            return
        end
        
        local valid = getValidAutoFarmTargets()
        if #valid == 0 then
            config.currentAutoFarmTarget = nil
            config.autoFarmIndex = 1
            return
        end
        
        if config.currentAutoFarmTarget then
            local char = getTargetCharacter(config.currentAutoFarmTarget)
            if char and hasForcefield(char) then
                restoreTargetOriginalPosition(config.currentAutoFarmTarget)
                config.autoFarmCompleted[config.currentAutoFarmTarget] = true
                config.currentAutoFarmTarget = nil
            end
        end
        
        if not config.currentAutoFarmTarget or config.autoFarmCompleted[config.currentAutoFarmTarget] then
            for i = config.autoFarmIndex, #valid do
                local t = valid[i]
                if not config.autoFarmCompleted[t] then
                    config.currentAutoFarmTarget = t
                    config.autoFarmIndex = i
                    break
                end
            end
            if not config.currentAutoFarmTarget then
                for _, t in ipairs(valid) do
                    if not config.autoFarmCompleted[t] then
                        config.currentAutoFarmTarget = t
                        break
                    end
                end
            end
        end
        
        if config.currentAutoFarmTarget and getTargetCharacter(config.currentAutoFarmTarget) then
            if not plralive(config.currentAutoFarmTarget) then
                restoreTargetOriginalPosition(config.currentAutoFarmTarget)
                config.autoFarmCompleted[config.currentAutoFarmTarget] = true
                config.currentAutoFarmTarget = nil
                return
            end
            
            if not tptocrossWithAlignment(config.currentAutoFarmTarget) then
                teleportTargetToLocalPlayerFront(config.currentAutoFarmTarget)
            end
        end
    end)
end

local function stopAutoFarm()
    if config.autoFarmLoop then
        config.autoFarmLoop:Disconnect()
        config.autoFarmLoop = nil
    end
    for t in pairs(config.autoFarmOriginalPositions) do
        restoreTargetOriginalPosition(t)
    end
    config.autoFarmOriginalPositions = {}
    config.autoFarmCompleted = {}
    config.currentAutoFarmTarget = nil
    config.autoFarmIndex = 1
    config.autoFarmEnabled = false
end

-- ================= ESP FUNCTIONS =================
local function healthColor(humanoid)
    if not humanoid then return config.espc end
    local health = math.clamp(humanoid.Health / (humanoid.MaxHealth or 100), 0, 1)
    return Color3.new(1 - health, health, 0)
end

local function removeHighlightESP(targetPlayer)
    if not targetPlayer then return end
    local h = config.highlightData[targetPlayer]
    if h and h.Parent then pcall(function() h:Destroy() end) end
    config.highlightData[targetPlayer] = nil
end

local function high(targetPlayer)
    if not targetPlayer or not getTargetCharacter(targetPlayer) or not addesp(targetPlayer) then return end
    
    if config.highlightData[targetPlayer] then
        local existing = config.highlightData[targetPlayer]
        if existing and existing.Parent then
            existing.FillColor = (targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget) and 
                                config.esptargetc or config.espc
            return
        else
            config.highlightData[targetPlayer] = nil
        end
    end
    
    local character = getTargetCharacter(targetPlayer)
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = (targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget) and 
                         config.esptargetc or config.espc
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    highlight.Parent = character
    
    config.highlightData[targetPlayer] = highlight
end

local function removeESPLabel(targetPlayer)
    if not targetPlayer then return end
    local data = config.espData[targetPlayer]
    if data then
        if data.connection then pcall(function() data.connection:Disconnect() end) end
        if data.screenGui and data.screenGui.Parent then pcall(function() data.screenGui:Destroy() end) end
        config.espData[targetPlayer] = nil
    end
end

local function makeesp(targetPlayer)
    if not targetPlayer or not addesp(targetPlayer) then return end
    
    removeESPLabel(targetPlayer)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. getTargetName(targetPlayer)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.BackgroundTransparency = 1
    label.Text = getTargetName(targetPlayer)
    label.TextSize = 6
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Visible = false
    label.Size = UDim2.new(0, 200, 0, 20)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = screenGui
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESPBox"
    boxFrame.AnchorPoint = Vector2.new(0, 0)
    boxFrame.Size = UDim2.new(0, 0, 0, 0)
    boxFrame.Position = UDim2.new(0, 0, 0, 0)
    boxFrame.BackgroundTransparency = 0.6
    boxFrame.BorderSizePixel = 0
    boxFrame.Visible = false
    boxFrame.Parent = screenGui
    
    local boxOutline = Instance.new("UIStroke")
    boxOutline.Thickness = 1
    boxOutline.LineJoinMode = Enum.LineJoinMode.Round
    boxOutline.Color = config.espc
    boxOutline.Transparency = 0.1
    boxOutline.Parent = boxFrame
    
    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBG"
    healthBg.AnchorPoint = Vector2.new(0, 0)
    healthBg.Size = UDim2.new(0, 4, 0, 0)
    healthBg.Position = UDim2.new(0, 0, 0, 0)
    healthBg.BackgroundTransparency = 0.6
    healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.Parent = screenGui
    
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Size = UDim2.new(1, 0, 0, 0)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg
    
    local headDot = Instance.new("Frame")
    headDot.Name = "HeadDot"
    headDot.Size = UDim2.new(0, 6, 0, 6)
    headDot.AnchorPoint = Vector2.new(0.5, 0.5)
    headDot.BackgroundColor3 = config.espc
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.Parent = screenGui
    
    local conn = RunService.RenderStepped:Connect(function()
        local tchar = getTargetCharacter(targetPlayer)
        if not tchar or not tchar.Parent or not addesp(targetPlayer) then
            label.Visible = false
            boxFrame.Visible = false
            healthBg.Visible = false
            headDot.Visible = false
            return
        end
        
        local head = tchar:FindFirstChild("Head")
        local root = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso") or tchar:FindFirstChild("UpperTorso")
        if not head or not root then
            label.Visible = false
            boxFrame.Visible = false
            healthBg.Visible = false
            headDot.Visible = false
            return
        end
        
        local topPos = head.Position + Vector3.new(0, 0.4, 0)
        local bottomPos = root.Position - Vector3.new(0, 1.0, 0)
        local topV3, onTop = camera:WorldToViewportPoint(topPos)
        local bottomV3, onBottom = camera:WorldToViewportPoint(bottomPos)
        local midV3 = (topV3 + bottomV3) * 0.5
        local onScreen = onTop and onBottom and topV3.Z > 0 and bottomV3.Z > 0
        local topY = topV3.Y
        local bottomY = bottomV3.Y
        local centerX = midV3.X
        local heightPx = math.max(2, math.abs(bottomY - topY))
        local widthPx = math.clamp(heightPx * 0.45, 4, 400)
        
        local humanoid = tchar:FindFirstChildOfClass("Humanoid")
        local hpRatio = humanoid and math.clamp(humanoid.Health / (humanoid.MaxHealth or 100), 0, 1) or 1
        local hpColor = humanoid and healthColor(humanoid) or Color3.new(1,1,1)
        local isTargeted = targetPlayer == config.currentTarget or targetPlayer == config.aimbotCurrentTarget
        
        if config.espMasterEnabled and config.prefTextESP then
            local text = string.format("%s [%d]", getTargetName(targetPlayer), humanoid and math.floor(humanoid.Health) or 0)
            label.Text = text
            local absWidth = label.TextBounds and label.TextBounds.X > 0 and label.TextBounds.X + 8 or 200
            label.Size = UDim2.new(0, absWidth, 0, 18)
            label.Position = UDim2.new(0, centerX, 0, topY - 4)
            label.Visible = onScreen
            label.TextColor3 = config.prefColorByHealth and hpColor or (isTargeted and config.esptargetc or config.espc)
        else
            label.Visible = false
        end
        
        if config.espMasterEnabled and config.prefBoxESP then
            boxFrame.Size = UDim2.new(0, widthPx, 0, heightPx)
            boxFrame.Position = UDim2.new(0, centerX - widthPx/2, 0, topY)
            boxFrame.Visible = onScreen
            boxOutline.Color = config.prefColorByHealth and hpColor or (isTargeted and config.esptargetc or config.espc)
        else
            boxFrame.Visible = false
        end
        
        if config.espMasterEnabled and config.prefHealthESP and humanoid then
            healthBg.Size = UDim2.new(0, 4, 0, heightPx)
            healthBg.Position = UDim2.new(0, centerX + widthPx/2 + 4, 0, topY)
            healthBg.Visible = onScreen
            healthFill.Size = UDim2.new(1, 0, hpRatio, 0)
            healthFill.BackgroundColor3 = healthColor(humanoid)
        else
            healthBg.Visible = false
        end
        
        if config.espMasterEnabled and config.prefHeadDotESP and head then
            local headV3, onHead = camera:WorldToViewportPoint(head.Position)
            if onHead and headV3.Z > 0 then
                headDot.Position = UDim2.new(0, headV3.X, 0, headV3.Y)
                headDot.Visible = true
                headDot.BackgroundColor3 = config.prefColorByHealth and hpColor or (isTargeted and config.esptargetc or config.espc)
            else
                headDot.Visible = false
            end
        else
            headDot.Visible = false
        end
    end)
    
    config.espData[targetPlayer] = {
        screenGui = screenGui,
        connection = conn
    }
end

local function updateESPColors()
    for target, data in pairs(config.espData) do
        if not addesp(target) then
            removeESPLabel(target)
        end
    end
    for target in pairs(config.highlightData) do
        if not addesp(target) then
            removeHighlightESP(target)
        end
    end
end

local function espRefresher()
    if not config.espMasterEnabled then return end
    
    for _, target in ipairs(getAllTargets()) do
        if addesp(target) then
            if not config.espData[target] and (config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP) then
                makeesp(target)
            end
            if not config.highlightData[target] and config.prefHighlightESP then
                high(target)
            end
        end
    end
end

local function applyESPMaster(state)
    config.espMasterEnabled = state
    
    if state then
        for _, target in ipairs(getAllTargets()) do
            if addesp(target) then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                    makeesp(target)
                end
                if config.prefHighlightESP then
                    high(target)
                end
            end
        end
    else
        for target in pairs(config.espData) do removeESPLabel(target) end
        for target in pairs(config.highlightData) do removeHighlightESP(target) end
    end
end

-- ================= CLIENT FUNCTIONS =================
local function safeGetCharacter()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function TpWalkStart()
    if config._tpwalking then return end
    config._tpwalking = true
    
    task.spawn(function()
        while config._tpwalking and localPlayer and localPlayer.Character do
            local _, humanoid, rootPart = safeGetCharacter()
            if humanoid and humanoid.Health > 0 and rootPart and humanoid.MoveDirection.Magnitude > 0 then
                local delta = RunService.Heartbeat:Wait()
                local velocity = humanoid.MoveDirection.Unit * config.clientCFrameSpeed * 50
                pcall(function() rootPart.CFrame = rootPart.CFrame + velocity * delta end)
            else
                task.wait(0.1)
            end
        end
        config._tpwalking = false
    end)
end

local function TpWalkStop()
    config._tpwalking = false
end

local _noclipConn
local function startNoclip()
    if _noclipConn then return end
    _noclipConn = RunService.Stepped:Connect(function()
        local char = localPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
end

local function stopNoclip()
    if _noclipConn then
        pcall(function() _noclipConn:Disconnect() end)
        _noclipConn = nil
    end
end

local function applyClientMaster(state)
    if config.clientMasterEnabled == state then return end
    config.clientMasterEnabled = state
    
    if state then
        if config.clientNoclipEnabled then startNoclip() config.clientNoclip = true end
        if config.clientCFrameWalkToggle then TpWalkStart() config.clientCFrameWalkEnabled = true end
        if config.clientWalkEnabled and config.clientWalkSpeed > 0 then
            local _, humanoid = safeGetCharacter()
            if humanoid then
                config.clientOriginals.WalkSpeed = config.clientOriginals.WalkSpeed or humanoid.WalkSpeed
                pcall(function() humanoid.WalkSpeed = config.clientWalkSpeed end)
            end
        end
        if config.clientJumpEnabled and config.clientJumpPower > 0 then
            local _, humanoid = safeGetCharacter()
            if humanoid then
                config.clientOriginals.JumpPower = config.clientOriginals.JumpPower or (humanoid.JumpPower or humanoid.JumpHeight)
                pcall(function()
                    if humanoid.JumpPower ~= nil then
                        humanoid.JumpPower = config.clientJumpPower
                    else
                        humanoid.JumpHeight = config.clientJumpPower
                    end
                end)
            end
        end
        notify({Title = "Client Master", Content = "Enabled", Length = 1, BarColor = Color3.fromRGB(0, 170, 255)})
    else
        local _, humanoid = safeGetCharacter()
        if humanoid then
            if config.clientOriginals.WalkSpeed then
                pcall(function() humanoid.WalkSpeed = config.clientOriginals.WalkSpeed end)
                config.clientOriginals.WalkSpeed = nil
            end
            if config.clientOriginals.JumpPower then
                pcall(function()
                    if humanoid.JumpPower ~= nil then
                        humanoid.JumpPower = config.clientOriginals.JumpPower
                    else
                        humanoid.JumpHeight = config.clientOriginals.JumpPower
                    end
                end)
                config.clientOriginals.JumpPower = nil
            end
        end
        stopNoclip()
        TpWalkStop()
        config.clientNoclip = false
        config.clientCFrameWalkEnabled = false
        notify({Title = "Client Master", Content = "Disabled", Length = 1, BarColor = Color3.fromRGB(255, 0, 0)})
    end
end

-- ================= REACH FUNCTIONS =================
local visualizer = Instance.new("Part")
visualizer.Anchored = true
visualizer.CanCollide = false
visualizer.Size = Vector3.new(0.5, 0.5, 0.5)

RunService.RenderStepped:Connect(function()
    if not config.reach.enabled then
        visualizer.Parent = nil
        return
    end
    
    local char = localPlayer.Character
    if not char then visualizer.Parent = nil return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then visualizer.Parent = nil return end
    
    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part")
    if not handle then visualizer.Parent = nil return end
    
    if config.visualizer.enabled then
        visualizer.Parent = Workspace
        visualizer.Material = config.materials[config.visualizer.material] or Enum.Material.ForceField
        visualizer.Color = config.visualizer.color
        visualizer.Transparency = config.visualizer.transparency
        
        if config.reach.type == "Sphere" then
            visualizer.Shape = Enum.PartType.Ball
            visualizer.Size = Vector3.new(config.reach.distance, config.reach.distance, config.reach.distance) * 2
            visualizer.CFrame = handle.CFrame
        elseif config.reach.type == "Flat" then
            visualizer.Shape = Enum.PartType.Block
            visualizer.Size = Vector3.new(config.reach.distance, 0.2, config.reach.distance) * 2
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                visualizer.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
            end
        end
    else
        visualizer.Parent = nil
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - handle.Position).Magnitude <= config.reach.distance then
                pcall(function()
                    firetouchinterest(handle, hrp, 0)
                    firetouchinterest(handle, hrp, 1)
                end)
            end
        end
    end
end)

-- ================= DEATH LISTENER =================
local function setupDeathListener(targetPlayer)
    local char = getTargetCharacter(targetPlayer)
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
    end
    
    config.characterConnections[targetPlayer] = humanoid.Died:Connect(function()
        restorePartForPlayer(targetPlayer)
        restoreTorso(targetPlayer)
        if config.currentTarget == targetPlayer then config.currentTarget = nil end
        if config.aimbotCurrentTarget == targetPlayer then config.aimbotCurrentTarget = nil end
        if config.SA2_currentTarget == targetPlayer then config.SA2_currentTarget = nil end
        updateESPColors()
    end)
end

local function cleanplrdata(targetPlayer)
    if not targetPlayer then return end
    
    config.autoFarmOriginalPositions[targetPlayer] = nil
    config.autoFarmCompleted[targetPlayer] = nil
    if config.currentAutoFarmTarget == targetPlayer then config.currentAutoFarmTarget = nil end
    
    restorePartForPlayer(targetPlayer)
    restoreTorso(targetPlayer)
    removeESPLabel(targetPlayer)
    removeHighlightESP(targetPlayer)
    
    if config.playerConnections[targetPlayer] then
        for _, conn in ipairs(config.playerConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
        config.playerConnections[targetPlayer] = nil
    end
    
    if config.characterConnections[targetPlayer] then
        pcall(function() config.characterConnections[targetPlayer]:Disconnect() end)
        config.characterConnections[targetPlayer] = nil
    end
    
    config.activeApplied[targetPlayer] = nil
    config.originalSizes[targetPlayer] = nil
    config.targethbSizes[targetPlayer] = nil
    config.hitboxExpandedParts[targetPlayer] = nil
    config.hitboxOriginalSizes[targetPlayer] = nil
    
    if config.currentTarget == targetPlayer then config.currentTarget = nil end
    if config.aimbotCurrentTarget == targetPlayer then config.aimbotCurrentTarget = nil end
    if config.SA2_currentTarget == targetPlayer then config.SA2_currentTarget = nil end
    updateESPColors()
end

local function setupPlayerListeners(pl)
    if pl == localPlayer then return end
    
    if config.playerConnections[pl] then
        for _, conn in ipairs(config.playerConnections[pl]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    
    config.playerConnections[pl] = {}
    
    local charAddedConn = pl.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupDeathListener(pl)
        if config.hitboxEnabled and targethb(pl) then
            expandhb(pl, config.hitboxSize)
        end
        if config.espMasterEnabled then
            if addesp(pl) then
                if config.prefTextESP or config.prefBoxESP or config.prefHealthESP or config.prefHeadDotESP then
                    makeesp(pl)
                end
                if config.prefHighlightESP then
                    high(pl)
                end
            end
        end
    end)
    table.insert(config.playerConnections[pl], charAddedConn)
    
    local charRemovingConn = pl.CharacterRemoving:Connect(function()
        removeESPLabel(pl)
        removeHighlightESP(pl)
        restoreTorso(pl)
    end)
    table.insert(config.playerConnections[pl], charRemovingConn)
    
    if pl.Character then
        setupDeathListener(pl)
        if config.hitboxEnabled and targethb(pl) then
            expandhb(pl, config.hitboxSize)
        end
    end
end

-- ================= RESPAWN HANDLER =================
local wasEnabledBeforeDeath = false
local wasESPEnabledBeforeDeath = false
local respawnLock = false

local function SetupRespawnHandler()
    localPlayer.CharacterAdded:Connect(function()
        if respawnLock then
            task.wait(1.5)
            if wasEnabledBeforeDeath then config.SA2_Enabled = true end
            if wasESPEnabledBeforeDeath then config.espMasterEnabled = true end
            respawnLock = false
            wasEnabledBeforeDeath = false
            wasESPEnabledBeforeDeath = false
        end
    end)
    
    localPlayer.CharacterRemoving:Connect(function()
        if config.SA2_Enabled then wasEnabledBeforeDeath = true end
        if config.espMasterEnabled then wasESPEnabledBeforeDeath = true end
        config.SA2_Enabled = false
        config.espMasterEnabled = false
        respawnLock = true
    end)
end
SetupRespawnHandler()

-- ================= FOV RINGS =================
-- Silent Aim HB Ring
local fovScreenGui = Instance.new("ScreenGui")
fovScreenGui.Name = "FOVRing_HB"
fovScreenGui.ResetOnSpawn = false
fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local ringHolder = Instance.new("Frame")
ringHolder.Name = "RingHolder"
ringHolder.AnchorPoint = Vector2.new(0.5, 0.5)
ringHolder.Size = UDim2.new(0, config.fovsize * 2, 0, config.fovsize * 2)
ringHolder.Position = UDim2.new(0.5, 0, 0.5, -28)
ringHolder.BackgroundTransparency = 1
ringHolder.Visible = false
ringHolder.Parent = fovScreenGui

local ringCorner = Instance.new("UICorner")
ringCorner.CornerRadius = UDim.new(1, 0)
ringCorner.Parent = ringHolder

local ringStroke = Instance.new("UIStroke")
ringStroke.Thickness = 1
ringStroke.LineJoinMode = Enum.LineJoinMode.Round
ringStroke.Color = config.fovc
ringStroke.Transparency = 0
ringStroke.Parent = ringHolder

-- Aimbot Ring
local aimbotRingGui = Instance.new("ScreenGui")
aimbotRingGui.Name = "AimbotFOVRing"
aimbotRingGui.ResetOnSpawn = false
aimbotRingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
aimbotRingGui.Parent = localPlayer:WaitForChild("PlayerGui")

local aimbotRingFrame = Instance.new("Frame")
aimbotRingFrame.Name = "RingFrame"
aimbotRingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
aimbotRingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
aimbotRingFrame.Position = UDim2.new(0.5, 0, 0.5, -28)
aimbotRingFrame.BackgroundTransparency = 1
aimbotRingFrame.Visible = false
aimbotRingFrame.Parent = aimbotRingGui

local aimbotRingCorner = Instance.new("UICorner")
aimbotRingCorner.CornerRadius = UDim.new(1, 0)
aimbotRingCorner.Parent = aimbotRingFrame

local aimbotRingStroke = Instance.new("UIStroke")
aimbotRingStroke.Thickness = 1
aimbotRingStroke.LineJoinMode = Enum.LineJoinMode.Round
aimbotRingStroke.Color = Color3.fromRGB(255, 0, 0)
aimbotRingStroke.Transparency = 0.3
aimbotRingStroke.Parent = aimbotRingFrame

config.aimbotFOVRing = {
    ScreenGui = aimbotRingGui,
    RingFrame = aimbotRingFrame
}

local function updateAimbotFOVRing()
    if config.aimbotFOVRing and config.aimbotFOVRing.RingFrame then
        if config.aimbot360Enabled and config.aimbotEnabled then
            config.aimbotFOVRing.RingFrame.Visible = false
        elseif config.aimbotEnabled then
            config.aimbotFOVRing.RingFrame.Size = UDim2.new(0, config.aimbotFOVSize * 2, 0, config.aimbotFOVSize * 2)
            config.aimbotFOVRing.RingFrame.Visible = true
        else
            config.aimbotFOVRing.RingFrame.Visible = false
        end
    end
end

-- Silent Aim HK Ring
local SA2ScreenGui = Instance.new("ScreenGui")
SA2ScreenGui.Name = "FOVSys_SA2"
SA2ScreenGui.Parent = CoreGui
SA2ScreenGui.IgnoreGuiInset = true

local SA2Circle = Instance.new("Frame")
SA2Circle.Name = "FOVCircle"
SA2Circle.Parent = SA2ScreenGui
SA2Circle.AnchorPoint = Vector2.new(0.5, 0.5)
SA2Circle.BackgroundColor3 = config.SA2_FovColor
SA2Circle.BackgroundTransparency = 1
SA2Circle.BorderSizePixel = 0
SA2Circle.Visible = false

local SA2Corner = Instance.new("UICorner")
SA2Corner.CornerRadius = UDim.new(1, 0)
SA2Corner.Parent = SA2Circle

local SA2Stroke = Instance.new("UIStroke")
SA2Stroke.Color = config.SA2_FovColor
SA2Stroke.Thickness = 1
SA2Stroke.Transparency = 1 - config.SA2_FovTransparency
SA2Stroke.Parent = SA2Circle

-- ================= RENDER STEP FOR FOV =================
local function onRenderStep()
    if not camera then camera = Workspace.CurrentCamera end
    
    -- Silent Aim HB Ring
    if not config.startsa then
        ringHolder.Visible = false
    else
        ringHolder.Visible = true
        local viewport = camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local radius = config.fovsize
        local best = nil
        local bestDist = math.huge
        
        for _, target in ipairs(getAllTargets()) do
            local part, _ = chooseBodyPartInstance(target)
            if part and plralive(target) and not hasForcefield(getTargetCharacter(target)) then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= radius and wallCheck(part.Position, camera.CFrame.Position) then
                        if dist < bestDist then
                            bestDist = dist
                            best = target
                        end
                    end
                end
            end
        end
        
        ringStroke.Color = best and config.fovct or config.fovc
        
        if best ~= config.currentTarget then
            config.currentTarget = best
            updateESPColors()
        end
        
        if best then
            local diameter = calculateDiameter((best and (getTargetCharacter(best):FindFirstChild("HumanoidRootPart") or getTargetCharacter(best):FindFirstChild("Head")).Position and 
                                               (camera.CFrame.Position - (getTargetCharacter(best):FindFirstChild("HumanoidRootPart") or getTargetCharacter(best):FindFirstChild("Head")).Position).Magnitude or 0, 
                                               radius, camera)
            applySizeToPart(best, diameter)
        end
    end
    
    -- Silent Aim HK Ring
    if config.SA2_Enabled and config.SA2_FovVisible and not config.SA2_ThreeSixtyMode then
        local viewport = camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        SA2Circle.Visible = true
        SA2Circle.Position = UDim2.new(0, center.X, 0, center.Y)
        SA2Circle.Size = UDim2.new(0, config.SA2_FovRadius * 2, 0, config.SA2_FovRadius * 2)
        SA2Stroke.Color = config.SA2_currentTarget and config.SA2_FovColourTarget or config.SA2_FovColor
    else
        SA2Circle.Visible = false
    end
end

RunService:BindToRenderStep("FOVUpdater", Enum.RenderPriority.First.Value, onRenderStep)

-- ================= KEYBINDS =================
local function initKeybinds()
    local holdingModifier = false
    
    local function shouldTrigger(key)
        return config.KeybindsEnabled and (not config.HoldKeysEnabled or holdingModifier)
    end
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        
        if input.KeyCode == Enum.KeyCode[config.Keybinds.HoldKeybind] then
            holdingModifier = true
        end
        
        if config.HoldKeysEnabled and not holdingModifier then return end
        
        if input.KeyCode == Enum.KeyCode[config.Keybinds.silentaim] and shouldTrigger() then
            config.startsa = not config.startsa
            ringHolder.Visible = config.startsa
            if not config.startsa then
                for pl in pairs(config.activeApplied) do restorePartForPlayer(pl) end
            end
            WindUI:Notify({Title = "Silent Aim (HB)", Content = config.startsa and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimhk] and shouldTrigger() then
            config.SA2_Enabled = not config.SA2_Enabled
            WindUI:Notify({Title = "Silent Aim (HK)", Content = config.SA2_Enabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.aimbot] and shouldTrigger() then
            handleAimbotToggle(not config.aimbotEnabled)
            WindUI:Notify({Title = "Aimbot", Content = config.aimbotEnabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.autofarm] and shouldTrigger() then
            config.autoFarmEnabled = not config.autoFarmEnabled
            if config.autoFarmEnabled then autoFarmProcess() else stopAutoFarm() end
            WindUI:Notify({Title = "Auto Farm", Content = config.autoFarmEnabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.antiaim] and shouldTrigger() then
            config.antiAimEnabled = not config.antiAimEnabled
            if not config.antiAimEnabled then returnToOriginalPosition() end
            WindUI:Notify({Title = "Anti Aim", Content = config.antiAimEnabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.hitbox] and shouldTrigger() then
            config.hitboxEnabled = not config.hitboxEnabled
            if config.hitboxEnabled then applyhb() else
                for pl in pairs(config.hitboxExpandedParts) do restoreTorso(pl) end
            end
            WindUI:Notify({Title = "Hitbox", Content = config.hitboxEnabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.esp] and shouldTrigger() then
            applyESPMaster(not config.espMasterEnabled)
            WindUI:Notify({Title = "ESP", Content = config.espMasterEnabled and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.client] and shouldTrigger() then
            applyClientMaster(not config.clientMasterEnabled)
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimwallcheck] and shouldTrigger() then
            config.wallc = not config.wallc
            WindUI:Notify({Title = "SA Wall Check", Content = config.wallc and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.aimbotwallcheck] and shouldTrigger() then
            config.aimbotWallCheck = not config.aimbotWallCheck
            WindUI:Notify({Title = "Aimbot Wall Check", Content = config.aimbotWallCheck and "Enabled" or "Disabled", Duration = 1})
            
        elseif input.KeyCode == Enum.KeyCode[config.Keybinds.silentaimhkwallcheck] and shouldTrigger() then
            config.SA2_Wallcheck = not config.SA2_Wallcheck
            WindUI:Notify({Title = "SA HK Wall Check", Content = config.SA2_Wallcheck and "Enabled" or "Disabled", Duration = 1})
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode[config.Keybinds.HoldKeybind] then
            holdingModifier = false
        end
    end)
end

-- ================= QUICK TOGGLES (MOBILE) =================
local function isMobileDevice()
    return pcall(function() return UserInputService.TouchEnabled end) and UserInputService.TouchEnabled
end

local function CreateQT()
    if not isMobileDevice() or not config.QuickToggles then return end
    
    if gui.mobileGui and gui.mobileGui.ScreenGui then
        pcall(function() gui.mobileGui.ScreenGui:Destroy() end)
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AzyroX_QT"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    local function makeToggle(name, x, y, get, set)
        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 120, 0, 40)
        main.Position = UDim2.new(0, x, 0, y)
        main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        main.BorderSizePixel = 0
        main.Active = true
        main.Draggable = true
        main.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = main
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = main
        
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 38, 0, 18)
        toggleBg.Position = UDim2.new(1, -44, 0.5, -9)
        toggleBg.BackgroundColor3 = get() and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(15, 15, 15)
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = main
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 9)
        bgCorner.Parent = toggleBg
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = get() and UDim2.new(1, -18, 0, 1) or UDim2.new(0, 1, 0, 1)
        circle.BackgroundColor3 = get() and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBg
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        local function toggle()
            local new = not get()
            set(new)
            toggleBg.BackgroundColor3 = new and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(15, 15, 15)
            circle.BackgroundColor3 = new and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
            circle.Position = new and UDim2.new(1, -18, 0, 1) or UDim2.new(0, 1, 0, 1)
            label.Text = name .. (new and "<" or "")
        end
        
        toggleBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                toggle()
            end
        end)
        
        return main
    end
    
    makeToggle("Silent Aim", 10, 10, function() return config.startsa end, function(v) config.startsa = v end)
    makeToggle("Hitbox", 140, 10, function() return config.hitboxEnabled end, function(v) config.hitboxEnabled = v end)
    makeToggle("Anti Aim", 270, 10, function() return config.antiAimEnabled end, function(v) config.antiAimEnabled = v end)
    makeToggle("Aimbot", 400, 10, function() return config.aimbotEnabled end, handleAimbotToggle)
    makeToggle("ESP", 10, 60, function() return config.espMasterEnabled end, applyESPMaster)
    makeToggle("SA HK", 140, 60, function() return config.SA2_Enabled end, function(v) config.SA2_Enabled = v end)
    
    gui.mobileGui = {ScreenGui = screenGui}
end

local function UpdateQT()
    if isMobileDevice() and config.QuickToggles then
        if not gui.mobileGui or not gui.mobileGui.ScreenGui then
            CreateQT()
        end
    elseif gui.mobileGui and gui.mobileGui.ScreenGui then
        pcall(function() gui.mobileGui.ScreenGui:Destroy() end)
        gui.mobileGui = nil
    end
end

-- ================= UI CREATION =================
math.randomseed(os.time())
local btntitle = {"AzyroX Hub", "Open me", "Click here", "Menu", "AzyroX"}
local choose = btntitle[math.random(1, #btntitle)]

local Window = WindUI:CreateWindow({
    Title = "AzyroX Hub",
    Theme = "Dark",
    Icon = "shovel",
    Size = UDim2.fromOffset(600, 70),
    HideSearchBar = false,
    OpenButton = {
        Title = choose,
        Enabled = true,
        Draggable = true,
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default"
    }
})

-- Random popup message
local messages = {
    "Welcome to AzyroX Hub!",
    "Script by AzyroX",
    "Have fun!",
    "8000+ lines of code",
    "Free & Open Source",
    "Keyless script",
    "Enjoy!"
}
WindUI:Popup({
    Title = "AzyroX Hub",
    Icon = "shovel",
    Content = messages[math.random(1, #messages)],
    Buttons = {{Title = "OK", Icon = "check", Variant = "Primary"}}
})

Window:Tag({
    Title = "YT: @AzyroX\nVersion: Ultimate",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true
})

-- ================= MAIN TAB =================
local MainTab = Window:Tab({Title = "Main", Desc = "Main settings", Icon = "hammer", IconColor = Color3.fromRGB(200,200,200)})

MainTab:Paragraph({Title = "Global Settings", Desc = "Master targeting controls", Color = Color3.fromRGB(144,238,144)})

MainTab:Dropdown({
    Title = "Team Target",
    Values = {"Enemies", "Teams", "All"},
    Value = config.masterTeamTarget,
    Callback = function(v)
        config.masterTeamTarget = v
        config.targetMode = v
        config.aimbotTeamTarget = v
        config.hitboxTeamTarget = v
        config.SA2_TeamTarget = v
    end
})

MainTab:Dropdown({
    Title = "Target Type",
    Values = {"Players", "NPCs", "Both"},
    Value = config.masterTarget,
    Callback = function(v) config.masterTarget = v end
})

MainTab:Dropdown({
    Title = "Get Target",
    Values = {"Closest", "Lowest Health", "TargetSeen"},
    Value = config.masterGetTarget,
    Callback = function(v)
        config.masterGetTarget = v
        config.aimbotGetTarget = v
        config.silentGetTarget = v
        config.antiAimGetTarget = v
        config.SA2_GetTarget = v
    end
})

MainTab:Toggle({
    Title = "Ignore Forcefield",
    Value = config.ignoreForcefield,
    Callback = function(v) config.ignoreForcefield = v end
})

MainTab:Space()

MainTab:Paragraph({Title = "Auto Farm", Desc = "Automatically farm targets", Color = Color3.fromRGB(144,238,144)})

MainTab:Toggle({
    Title = "Auto Farm (F)",
    Value = config.autoFarmEnabled,
    Callback = function(v)
        config.autoFarmEnabled = v
        if v then autoFarmProcess() else stopAutoFarm() end
    end
})

MainTab:Toggle({
    Title = "Wall Check",
    Value = config.autoFarmWallCheck,
    Callback = function(v) config.autoFarmWallCheck = v end
})

MainTab:Dropdown({
    Title = "Align Part",
    Values = {"Head", "HumanoidRootPart"},
    Value = config.autoFarmTargetPart,
    Callback = function(v) config.autoFarmTargetPart = v end
})

MainTab:Slider({
    Title = "TP Distance",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = config.autoFarmDistance},
    Callback = function(v) config.autoFarmDistance = v end
})

MainTab:Slider({
    Title = "Vertical Offset",
    Step = 1,
    Value = {Min = -50, Max = 50, Default = config.autoFarmVerticalOffset},
    Callback = function(v) config.autoFarmVerticalOffset = v end
})

MainTab:Space()

MainTab:Paragraph({Title = "Keybinds", Desc = "Configure hotkeys", Color = Color3.fromRGB(144,238,144)})

MainTab:Toggle({
    Title = "Enable Keybinds",
    Value = config.KeybindsEnabled,
    Callback = function(v) config.KeybindsEnabled = v end
})

MainTab:Toggle({
    Title = "Hold Key Mode",
    Value = config.HoldKeysEnabled,
    Callback = function(v) config.HoldKeysEnabled = v end
})

MainTab:Keybind({
    Title = "Hold Modifier",
    Value = config.Keybinds.HoldKeybind,
    Callback = function(k) config.Keybinds.HoldKeybind = k end
})

MainTab:Keybind({
    Title = "Silent Aim (HB)",
    Value = config.Keybinds.silentaim,
    Callback = function(k) config.Keybinds.silentaim = k end
})

MainTab:Keybind({
    Title = "Silent Aim (HK)",
    Value = config.Keybinds.silentaimhk,
    Callback = function(k) config.Keybinds.silentaimhk = k end
})

MainTab:Keybind({
    Title = "Aimbot",
    Value = config.Keybinds.aimbot,
    Callback = function(k) config.Keybinds.aimbot = k end
})

MainTab:Keybind({
    Title = "Auto Farm",
    Value = config.Keybinds.autofarm,
    Callback = function(k) config.Keybinds.autofarm = k end
})

MainTab:Keybind({
    Title = "Anti Aim",
    Value = config.Keybinds.antiaim,
    Callback = function(k) config.Keybinds.antiaim = k end
})

MainTab:Keybind({
    Title = "Hitbox",
    Value = config.Keybinds.hitbox,
    Callback = function(k) config.Keybinds.hitbox = k end
})

MainTab:Keybind({
    Title = "ESP",
    Value = config.Keybinds.esp,
    Callback = function(k) config.Keybinds.esp = k end
})

MainTab:Keybind({
    Title = "Client",
    Value = config.Keybinds.client,
    Callback = function(k) config.Keybinds.client = k end
})

MainTab:Space()

MainTab:Paragraph({Title = "Misc", Desc = "Additional settings", Color = Color3.fromRGB(144,238,144)})

MainTab:Toggle({
    Title = "Quick Toggles (Mobile)",
    Value = config.QuickToggles,
    Callback = function(v) config.QuickToggles = v end
})

MainTab:Toggle({
    Title = "Anti AFK",
    Value = config.antiafk,
    Callback = function(v) config.antiafk = v end
})

MainTab:Toggle({
    Title = "Fast Spawn",
    Value = config.fastspawn,
    Callback = function(v) config.fastspawn = v end
})

MainTab:Toggle({
    Title = "Low Render",
    Value = config.LowRender,
    Callback = function(v) config.LowRender = v end
})

-- ================= VISUALS TAB =================
local VisualsTab = Window:Tab({Title = "Visuals", Desc = "ESP settings", Icon = "eye", IconColor = Color3.fromRGB(200,200,200)})

VisualsTab:Paragraph({Title = "ESP Master", Desc = "Enable/disable ESP", Color = Color3.fromRGB(144,238,144)})

VisualsTab:Toggle({
    Title = "ESP (Z)",
    Value = config.espMasterEnabled,
    Callback = applyESPMaster
})

VisualsTab:Space()

VisualsTab:Paragraph({Title = "ESP Components", Desc = "Individual ESP elements", Color = Color3.fromRGB(144,238,144)})

VisualsTab:Toggle({
    Title = "Text ESP",
    Value = config.prefTextESP,
    Callback = function(v)
        config.prefTextESP = v
        if config.espMasterEnabled then
            for _, t in ipairs(getAllTargets()) do
                if addesp(t) then makeesp(t) end
            end
        end
    end
})

VisualsTab:Toggle({
    Title = "Box ESP",
    Value = config.prefBoxESP,
    Callback = function(v)
        config.prefBoxESP = v
        if config.espMasterEnabled then
            for _, t in ipairs(getAllTargets()) do
                if addesp(t) and not config.espData[t] then makeesp(t) end
            end
        end
    end
})

VisualsTab:Toggle({
    Title = "Health ESP",
    Value = config.prefHealthESP,
    Callback = function(v)
        config.prefHealthESP = v
        if config.espMasterEnabled then
            for _, t in ipairs(getAllTargets()) do
                if addesp(t) and not config.espData[t] then makeesp(t) end
            end
        end
    end
})

VisualsTab:Toggle({
    Title = "Head Dot",
    Value = config.prefHeadDotESP,
    Callback = function(v)
        config.prefHeadDotESP = v
        if config.espMasterEnabled then
            for _, t in ipairs(getAllTargets()) do
                if addesp(t) and not config.espData[t] then makeesp(t) end
            end
        end
    end
})

VisualsTab:Toggle({
    Title = "Highlight ESP",
    Value = config.prefHighlightESP,
    Callback = function(v)
        config.prefHighlightESP = v
        if config.espMasterEnabled then
            for _, t in ipairs(getAllTargets()) do
                if addesp(t) and getTargetCharacter(t) then high(t) end
            end
        else
            for t in pairs(config.highlightData) do removeHighlightESP(t) end
        end
    end
})

VisualsTab:Toggle({
    Title = "Color by Health",
    Value = config.prefColorByHealth,
    Callback = function(v) config.prefColorByHealth = v end
})

VisualsTab:Space()

VisualsTab:Paragraph({Title = "Colors", Desc = "Customize ESP colors", Color = Color3.fromRGB(144,238,144)})

VisualsTab:Colorpicker({
    Title = "Default Color",
    Default = config.espc,
    Callback = function(c) config.espc = c end
})

VisualsTab:Colorpicker({
    Title = "Target Color",
    Default = config.esptargetc,
    Callback = function(c) config.esptargetc = c end
})

VisualsTab:Colorpicker({
    Title = "Team Color",
    Default = config.espteamc,
    Callback = function(c) config.espteamc = c end
})

VisualsTab:Colorpicker({
    Title = "FOV Color",
    Default = config.fovc,
    Callback = function(c) config.fovc = c end
})

VisualsTab:Colorpicker({
    Title = "FOV Target Color",
    Default = config.fovct,
    Callback = function(c) config.fovct = c end
})

VisualsTab:Colorpicker({
    Title = "SA2 FOV Color",
    Default = config.SA2_FovColor,
    Callback = function(c) config.SA2_FovColor = c end
})

VisualsTab:Colorpicker({
    Title = "SA2 Target Color",
    Default = config.SA2_FovColourTarget,
    Callback = function(c) config.SA2_FovColourTarget = c end
})

VisualsTab:Colorpicker({
    Title = "Hitbox Color",
    Default = config.hitboxColor,
    Callback = function(c) config.hitboxColor = c end
})

-- ================= ANTI AIM TAB =================
local AntiAimTab = Window:Tab({Title = "Anti Aim", Desc = "Evasion settings", Icon = "shield", IconColor = Color3.fromRGB(200,200,200)})

AntiAimTab:Paragraph({Title = "Anti Aim Master", Desc = "Enable/disable anti aim", Color = Color3.fromRGB(144,238,144)})

AntiAimTab:Toggle({
    Title = "Anti Aim (L)",
    Value = config.antiAimEnabled,
    Callback = function(v)
        config.antiAimEnabled = v
        if not v then returnToOriginalPosition() end
    end
})

AntiAimTab:Space()

AntiAimTab:Paragraph({Title = "Modes", Desc = "Choose evasion method", Color = Color3.fromRGB(144,238,144)})

AntiAimTab:Toggle({
    Title = "Raycast",
    Value = config.raycastAntiAim,
    Callback = function(v)
        config.raycastAntiAim = v
        if v then
            config.antiAimAbovePlayer = false
            config.antiAimBehindPlayer = false
            config.antiAimOrbitEnabled = false
        end
    end
})

AntiAimTab:Toggle({
    Title = "Above Player",
    Value = config.antiAimAbovePlayer,
    Callback = function(v)
        config.antiAimAbovePlayer = v
        if v then
            config.raycastAntiAim = false
            config.antiAimBehindPlayer = false
            config.antiAimOrbitEnabled = false
        end
    end
})

AntiAimTab:Toggle({
    Title = "Behind Player",
    Value = config.antiAimBehindPlayer,
    Callback = function(v)
        config.antiAimBehindPlayer = v
        if v then
            config.raycastAntiAim = false
            config.antiAimAbovePlayer = false
            config.antiAimOrbitEnabled = false
        end
    end
})

AntiAimTab:Toggle({
    Title = "Orbit",
    Value = config.antiAimOrbitEnabled,
    Callback = function(v)
        config.antiAimOrbitEnabled = v
        if v then
            config.raycastAntiAim = false
            config.antiAimAbovePlayer = false
            config.antiAimBehindPlayer = false
        end
    end
})

AntiAimTab:Space()

AntiAimTab:Paragraph({Title = "Settings", Desc = "Adjust anti aim parameters", Color = Color3.fromRGB(144,238,144)})

AntiAimTab:Slider({
    Title = "TP Distance",
    Step = 0.5,
    Value = {Min = 0.5, Max = 50, Default = config.antiAimTPDistance},
    Callback = function(v) config.antiAimTPDistance = v end
})

AntiAimTab:Slider({
    Title = "Above Height",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = config.antiAimAboveHeight},
    Callback = function(v) config.antiAimAboveHeight = v end
})

AntiAimTab:Slider({
    Title = "Behind Distance",
    Step = 0.5,
    Value = {Min = 0.5, Max = 50, Default = config.antiAimBehindDistance},
    Callback = function(v) config.antiAimBehindDistance = v end
})

AntiAimTab:Slider({
    Title = "Orbit Speed",
    Step = 0.5,
    Value = {Min = 0.5, Max = 20, Default = config.antiAimOrbitSpeed},
    Callback = function(v) config.antiAimOrbitSpeed = v end
})

AntiAimTab:Slider({
    Title = "Orbit Radius",
    Step = 0.5,
    Value = {Min = 0.5, Max = 50, Default = config.antiAimOrbitRadius},
    Callback = function(v) config.antiAimOrbitRadius = v end
})

AntiAimTab:Slider({
    Title = "Orbit Height",
    Step = 1,
    Value = {Min = -50, Max = 50, Default = config.antiAimOrbitHeight},
    Callback = function(v) config.antiAimOrbitHeight = v end
})

-- ================= AIMBOT TAB =================
local AimbotTab = Window:Tab({Title = "Aimbot", Desc = "Aimbot settings", Icon = "crosshair", IconColor = Color3.fromRGB(200,200,200)})

AimbotTab:Paragraph({Title = "Aimbot Master", Desc = "Enable/disable aimbot", Color = Color3.fromRGB(144,238,144)})

AimbotTab:Toggle({
    Title = "Aimbot (Q)",
    Value = config.aimbotEnabled,
    Callback = handleAimbotToggle
})

AimbotTab:Space()

AimbotTab:Paragraph({Title = "Settings", Desc = "Configure aimbot behavior", Color = Color3.fromRGB(144,238,144)})

AimbotTab:Toggle({
    Title = "Wall Check (H)",
    Value = config.aimbotWallCheck,
    Callback = function(v) config.aimbotWallCheck = v end
})

AimbotTab:Toggle({
    Title = "360° Mode",
    Value = config.aimbot360Enabled,
    Callback = toggle360Aimbot
})

AimbotTab:Dropdown({
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Value = config.aimbotTargetPart,
    Callback = function(v) config.aimbotTargetPart = v end
})

AimbotTab:Slider({
    Title = "Strength",
    Step = 0.05,
    Value = {Min = 0, Max = 1, Default = config.aimbotStrength},
    Callback = function(v) config.aimbotStrength = v end
})

AimbotTab:Slider({
    Title = "FOV Size",
    Step = 10,
    Value = {Min = 1, Max = 500, Default = config.aimbotFOVSize},
    Callback = function(v) config.aimbotFOVSize = v; updateAimbotFOVRing() end
})

-- ================= SILENT AIM (HB) TAB =================
local SilentHBTab = Window:Tab({Title = "Silent Aim (HB)", Desc = "Hitbox-based silent aim", Icon = "circle", IconColor = Color3.fromRGB(200,200,200)})

SilentHBTab:Paragraph({Title = "Master Control", Desc = "Enable/disable silent aim (HB)", Color = Color3.fromRGB(144,238,144)})

SilentHBTab:Toggle({
    Title = "Silent Aim (E)",
    Value = config.startsa,
    Callback = function(v)
        config.startsa = v
        ringHolder.Visible = v
        if not v then
            for pl in pairs(config.activeApplied) do restorePartForPlayer(pl) end
        end
    end
})

SilentHBTab:Space()

SilentHBTab:Paragraph({Title = "Settings", Desc = "Configure silent aim (HB)", Color = Color3.fromRGB(144,238,144)})

SilentHBTab:Toggle({
    Title = "Wall Check (B)",
    Value = config.wallc,
    Callback = function(v) config.wallc = v end
})

SilentHBTab:Dropdown({
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart", "Both"},
    Value = config.bodypart,
    Callback = function(v)
        for pl in pairs(config.activeApplied) do restorePartForPlayer(pl) end
        config.bodypart = v
    end
})

SilentHBTab:Slider({
    Title = "Hit Chance",
    Step = 1,
    Suffix = "%",
    Value = {Min = 0, Max = 100, Default = config.hitchance},
    Callback = function(v) config.hitchance = v end
})

SilentHBTab:Slider({
    Title = "FOV Size",
    Step = 10,
    Value = {Min = 1, Max = 500, Default = config.fovsize},
    Callback = function(v)
        config.fovsize = v
        ringHolder.Size = UDim2.new(0, v * 2, 0, v * 2)
    end
})

SilentHBTab:Slider({
    Title = "Hitbox Transparency",
    Step = 0.1,
    Value = {Min = 0, Max = 1, Default = config.hbtrans},
    Callback = function(v) config.hbtrans = v end
})

-- ================= SILENT AIM (HK) TAB =================
local SilentHKTab = Window:Tab({Title = "Silent Aim (HK)", Desc = "Hook-based silent aim", Icon = "target", IconColor = Color3.fromRGB(200,200,200)})

SilentHKTab:Paragraph({Title = "Master Control", Desc = "Enable/disable silent aim (HK)", Color = Color3.fromRGB(144,238,144)})

SilentHKTab:Toggle({
    Title = "Silent Aim (R)",
    Value = config.SA2_Enabled,
    Callback = function(v) config.SA2_Enabled = v end
})

SilentHKTab:Space()

SilentHKTab:Paragraph({Title = "Settings", Desc = "Configure silent aim (HK)", Color = Color3.fromRGB(144,238,144)})

SilentHKTab:Toggle({
    Title = "Wall Check (T)",
    Value = config.SA2_Wallcheck,
    Callback = function(v) config.SA2_Wallcheck = v end
})

SilentHKTab:Toggle({
    Title = "Wallbang",
    Value = config.SA2_WallbangEnabled,
    Callback = function(v) config.SA2_WallbangEnabled = v end
})

SilentHKTab:Toggle({
    Title = "360 Mode",
    Value = config.SA2_ThreeSixtyMode,
    Callback = function(v) config.SA2_ThreeSixtyMode = v end
})

SilentHKTab:Dropdown({
    Title = "Method",
    Values = {"Raycast", "FindPartOnRay", "FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "All"},
    Value = config.SA2_Method,
    Callback = function(v) config.SA2_Method = v end
})

SilentHKTab:Dropdown({
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart"},
    Value = config.SA2_TargetPart,
    Callback = function(v) config.SA2_TargetPart = v end
})

SilentHKTab:Slider({
    Title = "Hit Chance",
    Step = 1,
    Suffix = "%",
    Value = {Min = 0, Max = 100, Default = config.SA2_HitChance},
    Callback = function(v) config.SA2_HitChance = v end
})

SilentHKTab:Slider({
    Title = "FOV Radius",
    Step = 10,
    Value = {Min = 0, Max = 500, Default = config.SA2_FovRadius},
    Callback = function(v) config.SA2_FovRadius = v end
})

SilentHKTab:Slider({
    Title = "Target Range",
    Step = 50,
    Value = {Min = 5, Max = 9999, Default = config.SA2_TargetRange},
    Callback = function(v) config.SA2_TargetRange = v end
})

-- ================= HITBOX TAB =================
local HitboxTab = Window:Tab({Title = "Hitbox", Desc = "Hitbox expansion", Icon = "box", IconColor = Color3.fromRGB(200,200,200)})

HitboxTab:Paragraph({Title = "Master Control", Desc = "Enable/disable hitbox expansion", Color = Color3.fromRGB(144,238,144)})

HitboxTab:Toggle({
    Title = "Hitbox (G)",
    Value = config.hitboxEnabled,
    Callback = function(v)
        config.hitboxEnabled = v
        if v then applyhb() else
            for pl in pairs(config.hitboxExpandedParts) do restoreTorso(pl) end
        end
    end
})

HitboxTab:Space()

HitboxTab:Paragraph({Title = "Settings", Desc = "Configure hitbox expansion", Color = Color3.fromRGB(144,238,144)})

HitboxTab:Slider({
    Title = "Size",
    Step = 5,
    Value = {Min = 1, Max = 500, Default = config.hitboxSize},
    Callback = function(v)
        config.hitboxSize = v
        if config.hitboxEnabled then
            for pl, data in pairs(config.hitboxExpandedParts) do
                if pl and targethb(pl) then
                    local newSize = Vector3.new(v, v, v)
                    data.targetSize = newSize
                    local torso = getTargetCharacter(pl) and (getTargetCharacter(pl):FindFirstChild("Torso") or getTargetCharacter(pl):FindFirstChild("UpperTorso"))
                    if torso then pcall(function() torso.Size = newSize end) end
                end
            end
        end
    end
})

-- ================= REACH TAB =================
local ReachTab = Window:Tab({Title = "Reach", Desc = "Extended melee range", Icon = "sword", IconColor = Color3.fromRGB(200,200,200)})

ReachTab:Paragraph({Title = "Master Control", Desc = "Enable/disable reach", Color = Color3.fromRGB(144,238,144)})

ReachTab:Toggle({
    Title = "Enable Reach",
    Value = config.reach.enabled,
    Callback = function(v) config.reach.enabled = v end
})

ReachTab:Space()

ReachTab:Paragraph({Title = "Settings", Desc = "Configure reach", Color = Color3.fromRGB(144,238,144)})

ReachTab:Dropdown({
    Title = "Reach Type",
    Values = {"Sphere", "Flat"},
    Value = config.reach.type,
    Callback = function(v) config.reach.type = v end
})

ReachTab:Slider({
    Title = "Distance",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = config.reach.distance},
    Callback = function(v) config.reach.distance = v end
})

ReachTab:Space()

ReachTab:Paragraph({Title = "Visualizer", Desc = "Reach visual settings", Color = Color3.fromRGB(144,238,144)})

ReachTab:Toggle({
    Title = "Show Visualizer",
    Value = config.visualizer.enabled,
    Callback = function(v) config.visualizer.enabled = v end
})

ReachTab:Dropdown({
    Title = "Material",
    Values = {"ForceField", "Plastic", "Glass", "Neon", "SmoothPlastic", "Metal", "DiamondPlate"},
    Value = config.visualizer.material,
    Callback = function(v) config.visualizer.material = v end
})

ReachTab:Slider({
    Title = "Transparency",
    Step = 0.05,
    Value = {Min = 0, Max = 1, Default = config.visualizer.transparency},
    Callback = function(v) config.visualizer.transparency = v end
})

ReachTab:Colorpicker({
    Title = "Color",
    Default = config.visualizer.color,
    Callback = function(c) config.visualizer.color = c end
})

-- ================= CLIENT TAB =================
local ClientTab = Window:Tab({Title = "Client", Desc = "Client-side modifications", Icon = "user", IconColor = Color3.fromRGB(200,200,200)})

ClientTab:Paragraph({Title = "Master Control", Desc = "Enable/disable client features", Color = Color3.fromRGB(144,238,144)})

ClientTab:Toggle({
    Title = "Client Master (V)",
    Value = config.clientMasterEnabled,
    Callback = applyClientMaster
})

ClientTab:Space()

ClientTab:Paragraph({Title = "Features", Desc = "Individual client features", Color = Color3.fromRGB(144,238,144)})

ClientTab:Toggle({
    Title = "Noclip",
    Value = config.clientNoclipEnabled,
    Callback = function(v)
        config.clientNoclipEnabled = v
        if config.clientMasterEnabled then
            if v then startNoclip() config.clientNoclip = true else stopNoclip() config.clientNoclip = false end
        end
    end
})

ClientTab:Toggle({
    Title = "WalkSpeed",
    Value = config.clientWalkEnabled,
    Callback = function(v)
        config.clientWalkEnabled = v
        if config.clientMasterEnabled and v then
            local _, h = safeGetCharacter()
            if h then
                config.clientOriginals.WalkSpeed = config.clientOriginals.WalkSpeed or h.WalkSpeed
                pcall(function() h.WalkSpeed = config.clientWalkSpeed end)
            end
        end
    end
})

ClientTab:Toggle({
    Title = "JumpPower",
    Value = config.clientJumpEnabled,
    Callback = function(v)
        config.clientJumpEnabled = v
        if config.clientMasterEnabled and v then
            local _, h = safeGetCharacter()
            if h then
                config.clientOriginals.JumpPower = config.clientOriginals.JumpPower or (h.JumpPower or h.JumpHeight)
                pcall(function()
                    if h.JumpPower ~= nil then h.JumpPower = config.clientJumpPower else h.JumpHeight = config.clientJumpPower end
                end)
            end
        end
    end
})

ClientTab:Toggle({
    Title = "CFrame Walk",
    Value = config.clientCFrameWalkToggle,
    Callback = function(v)
        config.clientCFrameWalkToggle = v
        if config.clientMasterEnabled then
            if v then TpWalkStart() config.clientCFrameWalkEnabled = true else TpWalkStop() config.clientCFrameWalkEnabled = false end
        end
    end
})

ClientTab:Space()

ClientTab:Paragraph({Title = "Values", Desc = "Adjust client values", Color = Color3.fromRGB(144,238,144)})

ClientTab:Slider({
    Title = "WalkSpeed",
    Step = 5,
    Value = {Min = 0, Max = 500, Default = config.clientWalkSpeed},
    Callback = function(v)
        config.clientWalkSpeed = v
        if config.clientMasterEnabled and config.clientWalkEnabled then
            local _, h = safeGetCharacter()
            if h then pcall(function() h.WalkSpeed = v end) end
        end
    end
})

ClientTab:Slider({
    Title = "JumpPower",
    Step = 5,
    Value = {Min = 0, Max = 500, Default = config.clientJumpPower},
    Callback = function(v)
        config.clientJumpPower = v
        if config.clientMasterEnabled and config.clientJumpEnabled then
            local _, h = safeGetCharacter()
            if h then
                pcall(function()
                    if h.JumpPower ~= nil then h.JumpPower = v else h.JumpHeight = v end
                end)
            end
        end
    end
})

ClientTab:Slider({
    Title = "CFrame Speed",
    Step = 5,
    Value = {Min = 0, Max = 500, Default = config.clientCFrameSpeed},
    Callback = function(v) config.clientCFrameSpeed = v end
})

-- ================= MISC TAB =================
local MiscTab = Window:Tab({Title = "Misc", Desc = "Miscellaneous features", Icon = "settings", IconColor = Color3.fromRGB(200,200,200)})

MiscTab:Paragraph({Title = "Animations", Desc = "Character animation controls", Color = Color3.fromRGB(144,238,144)})

MiscTab:Toggle({
    Title = "Enable Animations",
    Value = config.animations,
    Callback = function(v)
        config.animations = v
        if not v then stopCurrentAnimation() end
    end
})

MiscTab:Dropdown({
    Title = "R6 Presets",
    Values = config.Ids_R6,
    Value = "",
    Callback = function(v)
        if v and v ~= "" then
            config.R15 = false
            playAnimation(v, false)
        end
    end
})

MiscTab:Dropdown({
    Title = "R15 Presets",
    Values = config.Ids_R15,
    Value = "",
    Callback = function(v)
        if v and v ~= "" then
            config.R15 = true
            playAnimation(v, true)
        end
    end
})

MiscTab:Input({
    Title = "Custom ID",
    Placeholder = "Animation ID",
    Callback = function(v)
        if v and v ~= "" and tonumber(v) then
            playAnimation(v, config.R15)
        end
    end
})

MiscTab:Slider({
    Title = "Speed",
    Step = 0.1,
    Value = {Min = 0.1, Max = 5, Default = config.anim_speed},
    Callback = function(v) config.anim_speed = v; updateAnimation() end
})

MiscTab:Button({
    Title = "Stop Animation",
    Callback = stopCurrentAnimation
})

-- ================= INFO TAB =================
local InfoTab = Window:Tab({Title = "Info", Desc = "Information", Icon = "info", IconColor = Color3.fromRGB(200,200,200)})

InfoTab:Paragraph({
    Title = "AzyroX Hub",
    Desc = "Ultimate unified version\nYouTube: @AzyroX\nAll features combined",
    Color = Color3.fromRGB(255, 182, 193)
})

InfoTab:Space()

InfoTab:Paragraph({
    Title = "Features",
    Desc = "• Silent Aim (HB & HK)\n• Aimbot (360° mode)\n• Anti Aim (4 modes)\n• Hitbox Expansion\n• Reach (Melee)\n• ESP (Full customization)\n• Auto Farm\n• Client Modifications\n• Keybinds\n• Quick Toggles (Mobile)",
    Color = Color3.fromRGB(175, 221, 255)
})

InfoTab:Space()

InfoTab:Paragraph({
    Title = "Credits",
    Desc = "Original Gravel.cc by hmmm5651\nRebranded & Enhanced by AzyroX\nUI: WindUI\nNotifications: Alurt",
    Color = Color3.fromRGB(144, 238, 144)
})

-- ================= INITIALIZATION =================
local function init()
    -- Setup player listeners
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
        end
    end
    
    Players.PlayerAdded:Connect(function(pl)
        if pl ~= localPlayer then
            setupPlayerListeners(pl)
        end
    end)
    
    Players.PlayerRemoving:Connect(cleanplrdata)
    
    -- Start loops
    RunService.Heartbeat:Connect(hb)
    RunService.Heartbeat:Connect(antiAimUpdate)
    RunService.Heartbeat:Connect(updateHitboxes)
    RunService.RenderStepped:Connect(updateESPColors)
    
    -- Initialize keybinds
    initKeybinds()
    
    -- Start background processes
    task.spawn(function()
        while true do
            UpdateQT()
            espRefresher()
            LowRender()
            task.wait(0.5)
        end
    end)
    
    notify({
        Title = "AzyroX Hub",
        Content = "Script loaded successfully!",
        Length = 2,
        BarColor = Color3.fromRGB(0, 255, 0)
    })
end

-- Start everything
pcall(init)

-- Return config for external use
return config
