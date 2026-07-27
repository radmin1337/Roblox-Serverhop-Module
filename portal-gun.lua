--[[ 
    RICK & MORTY PORTAL GUN - OFFICIAL DEPLOY
    URL: https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local FRAME_TIME = 0.5
local GITHUB_URL = "https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua"

-- --- ЗАГРУЗКА АССЕТА ---
local portalGun = nil
local portalTemplate = nil

local success, assets = pcall(function()
    return game:GetObjects("rbxassetid://95480961882251")
end)

if success and assets then
    local root = assets[1]
    portalGun = (root:IsA("Tool") and root) or root:FindFirstChild("Portal Gun", true)
    if portalGun then
        local found = portalGun:FindFirstChild("Portal")
        if found then
            portalTemplate = found:Clone()
            found:Destroy()
        end
    end
end

if not portalGun or not portalTemplate then return end

-- --- КАДРЫ АНИМАЦИИ ---
local intro = {"rbxassetid://104651786116792", "rbxassetid://106781038483440"}
local loopFrames = {"rbxassetid://112204270873166", "rbxassetid://136733250763134"}
local outro = {"rbxassetid://74852451754370", "rbxassetid://135958825930181"}

-- --- ЛОГИКА ВИЗУАЛА (ТВОИ ФУНКЦИИ ДЛЯ 2-Х СТОРОН) ---
local function runPortalLogic(part)
    local guis = {part:WaitForChild("SurfaceGui1"), part:WaitForChild("SurfaceGui2")}
    local labels = {}
    local overlays = {}

    for _, gui in ipairs(guis) do
        local base = gui:WaitForChild("PortalLabel")
        local ov = base:Clone()
        ov.Parent = base.Parent
        ov.ZIndex = base.ZIndex + 1
        ov.BackgroundTransparency = 1
        ov.ImageTransparency = 1
        table.insert(labels, base)
        table.insert(overlays, ov)
    end

    local function fadeIn(imageId)
        for _, lbl in ipairs(labels) do lbl.Image = imageId; lbl.ImageTransparency = 1 end
        local tweens = {}
        for _, lbl in ipairs(labels) do
            table.insert(tweens, TweenService:Create(lbl, TweenInfo.new(FRAME_TIME/2, Enum.EasingStyle.Linear), {ImageTransparency = 0}))
        end
        for _, t in ipairs(tweens) do t:Play() end
        tweens[1].Completed:Wait()
        task.wait(FRAME_TIME/2)
    end

    local function normalTransition(newImage)
        for i, lbl in ipairs(labels) do
            overlays[i].Image = lbl.Image
            overlays[i].ImageTransparency = 0
            lbl.Image = newImage
            TweenService:Create(overlays[i], TweenInfo.new(FRAME_TIME, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
        end
        task.wait(FRAME_TIME)
    end

    local function fadeOutLast(imageId)
        for _, lbl in ipairs(labels) do lbl.Image = imageId; lbl.ImageTransparency = 0 end
        task.wait(FRAME_TIME/2)
        local tweens = {}
        for _, lbl in ipairs(labels) do
            table.insert(tweens, TweenService:Create(lbl, TweenInfo.new(FRAME_TIME/2, Enum.EasingStyle.Linear), {ImageTransparency = 1}))
        end
        for _, t in ipairs(tweens) do t:Play() end
        tweens[1].Completed:Wait()
    end

    -- Сама анимация
    fadeIn(intro[1])
    normalTransition(intro[2])
    for i = 1, 9 do
        for _, id in ipairs(loopFrames) do normalTransition(id) end
    end
    normalTransition(outro[1])
    fadeOutLast(outro[2])
    part:Destroy()
end

-- --- ИНТЕРФЕЙС ---
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Enabled = false
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 260, 0, 190); frame.Position = UDim2.new(0.5, -130, 0.7, 0); frame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

local disp = Instance.new("Frame", frame)
disp.Size = UDim2.new(0.9, 0, 0.3, 0); disp.Position = UDim2.new(0.05, 0, 0.05, 0); disp.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Instance.new("UICorner", disp)

local srv = Instance.new("TextLabel", disp)
srv.Size = UDim2.new(1, 0, 1, 0); srv.BackgroundTransparency = 1; srv.TextColor3 = Color3.new(1,1,1); srv.TextScaled = true; srv.Text = "SRV: " .. (game.JobId:sub(1,10))

local inP = Instance.new("TextBox", frame)
inP.Size = UDim2.new(0.9, 0, 0.15, 0); inP.Position = UDim2.new(0.05, 0, 0.4, 0); inP.Text = tostring(game.PlaceId)
Instance.new("UICorner", inP)

local inJ = Instance.new("TextBox", frame)
inJ.Size = UDim2.new(0.9, 0, 0.15, 0); inJ.Position = UDim2.new(0.05, 0, 0.58, 0); inJ.Text = game.JobId
Instance.new("UICorner", inJ)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.7, 0, 0.2, 0); btn.Position = UDim2.new(0.15, 0, 0.78, 0); btn.BackgroundColor3 = Color3.new(1, 1, 1)
btn.Text = "FIRE"; btn.Font = Enum.Font.SourceSansBold; btn.TextColor3 = Color3.new(0, 0, 0)
Instance.new("UICorner", btn); local str = Instance.new("UIStroke", btn); str.Thickness = 2 -- Черная квадратная обводка

-- --- ВЫСТРЕЛ ---
local tool = portalGun:Clone()
tool.Parent = player.Backpack
local animId = (humanoid.RigType == Enum.HumanoidRigType.R15) and "rbxassetid://507768375" or "rbxassetid://182393478"
local track = humanoid:LoadAnimation(Instance.new("Animation", tool))
track.Animation.AnimationId = animId

tool.Equipped:Connect(function() sg.Enabled = true; track:Play() end)
tool.Unequipped:Connect(function() sg.Enabled = false; track:Stop() end)

local function fire()
    local snd = tool:FindFirstChild("PortalSound", true) or tool:FindFirstChild("Portal", true)
    if snd then snd:Play() end

    local p = portalTemplate:Clone()
    p.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 1, -6)
    p.Parent = workspace

    local teleported = false
    p.Touched:Connect(function(hit)
        if not teleported and hit.Parent == character then
            teleported = true
            if queue_on_teleport then
                queue_on_teleport([[
                    repeat task.wait() until game:IsLoaded()
                    shared.IsPortalExit = true
                    loadstring(game:HttpGet("]]..GITHUB_URL..[["))()
                ]])
            end
            local tP = tonumber(inP.Text) or game.PlaceId
            local tJ = inJ.Text
            if tJ ~= "" and tJ ~= game.JobId then TeleportService:TeleportToPlaceInstance(tP, tJ, player)
            else TeleportService:Teleport(tP, player) end
        end
    end)
    runPortalLogic(p)
end

btn.MouseButton1Click:Connect(fire)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.E and tool.Parent == character then fire() end end)

-- --- ЛОГИКА ВЫХОДА ---
if shared.IsPortalExit then
    shared.IsPortalExit = nil
    task.spawn(function()
        repeat task.wait() until game:IsLoaded()
        local root = character:WaitForChild("HumanoidRootPart")
        local ep = portalTemplate:Clone()
        ep.CFrame = root.CFrame * CFrame.new(0, 1, -2)
        ep.Parent = workspace
        
        local snd = portalGun:FindFirstChild("PortalSound", true) or portalGun:FindFirstChild("Portal", true)
        if snd then snd:Play() end
        
        humanoid:MoveTo((ep.CFrame * CFrame.new(0, 0, 7)).Position)
        runPortalLogic(ep)
    end)
end
