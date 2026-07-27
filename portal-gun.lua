--[[ 
    RICK & MORTY PORTAL GUN - GITHUB DEPLOY
    URL: https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local GITHUB_URL = "https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua"

-- Ждем загрузки
if not game:IsLoaded() then game.Loaded:Wait() end

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

-- --- ФУНКЦИЯ ПОРТАЛА (ТАЙМИНГИ 0.5s и 1.0s) ---
local function runPortal(p)
    local guis = {p:WaitForChild("SurfaceGui1"), p:WaitForChild("SurfaceGui2")}
    local lbs, ovs = {}, {}

    for _, g in ipairs(guis) do
        local b = g:WaitForChild("PortalLabel")
        local o = b:Clone()
        o.Parent = g; o.ZIndex = b.ZIndex + 1; o.ImageTransparency = 1
        table.insert(lbs, b); table.insert(ovs, o)
    end

    local function transition(id, duration)
        for i, l in ipairs(lbs) do
            ovs[i].Image = l.Image; ovs[i].ImageTransparency = 0
            l.Image = id
            TweenService:Create(ovs[i], TweenInfo.new(duration, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
        end
        task.wait(duration)
    end

    -- 1. Появление
    for _, l in ipairs(lbs) do l.Image = "rbxassetid://104651786116792"; TweenService:Create(l, TweenInfo.new(0.3), {ImageTransparency = 0}):Play() end
    task.wait(0.3)
    
    -- 2. Переключение середины (0.5s каждое)
    transition("rbxassetid://106781038483440", 0.5)
    transition("rbxassetid://112204270873166", 0.5)
    transition("rbxassetid://136733250763134", 0.5)

    -- 3. Закрытие (1.0s каждое)
    transition("rbxassetid://74852451754370", 1.0)
    transition("rbxassetid://135958825930181", 1.0)

    -- Исчезновение финального кадра
    for _, l in ipairs(lbs) do TweenService:Create(l, TweenInfo.new(0.5), {ImageTransparency = 1}):Play() end
    task.wait(0.5)
    p:Destroy()
end

-- --- ЛОГИКА ВЫХОДА ---
if not shared.SkipExit then
    task.spawn(function()
        local root = character:WaitForChild("HumanoidRootPart")
        local ep = portalTemplate:Clone()
        -- Спавн на 1 студ выше
        ep.CFrame = root.CFrame * CFrame.new(0, 1, -2) 
        ep.Parent = workspace
        
        local s = portalGun:FindFirstChild("PortalSound", true)
        if s then s:Play() end
        
        humanoid:MoveTo((ep.CFrame * CFrame.new(0, 0, 7)).Position)
        runPortal(ep)
    end)
end
shared.SkipExit = nil -- Сбрасываем флаг

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
Instance.new("UICorner", btn)

-- --- ЛОГИКА ПУШКИ ---
local tool = portalGun:Clone()
tool.Parent = player.Backpack
local animId = (humanoid.RigType == Enum.HumanoidRigType.R15) and "rbxassetid://507768375" or "rbxassetid://182393478"
local anim = Instance.new("Animation")
anim.AnimationId = animId
local track = humanoid:LoadAnimation(anim)

tool.Equipped:Connect(function() sg.Enabled = true; track:Play() end)
tool.Unequipped:Connect(function() sg.Enabled = false; track:Stop() end)

local function fire()
    local snd = tool:FindFirstChild("PortalSound", true)
    if snd then snd:Play() end

    local p = portalTemplate:Clone()
    p.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 1, -6)
    p.Parent = workspace

    local active = true
    p.Touched:Connect(function(hit)
        if active and hit.Parent == character then
            active = false
            if queue_on_teleport then
                queue_on_teleport([[
                    pcall(function()
                        loadstring(game:HttpGet("]]..GITHUB_URL..[["))()
                    end)
                ]])
            end
            TeleportService:TeleportToPlaceInstance(tonumber(inP.Text), inJ.Text, player)
        end
    end)
    runPortal(p)
end

btn.MouseButton1Click:Connect(fire)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.E and tool.Parent == character then fire() end end)
