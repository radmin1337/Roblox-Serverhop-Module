--[[ 
    RICK & MORTY - GITHUB DEPLOY (ALWAYS EXITS FROM PORTAL)
    Asset: 95480961882251
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local GITHUB_URL = "https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua" 

-- Ждем загрузки игры
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

-- --- ФУНКЦИЯ ОЧЕНЬ БЫСТРОГО ПОРТАЛА ---
local function runPortalFast(p)
    local guis = {p:WaitForChild("SurfaceGui1"), p:WaitForChild("SurfaceGui2")}
    local lbs = {}
    for _, g in ipairs(guis) do table.insert(lbs, g:WaitForChild("PortalLabel")) end

    -- Быстрое открытие
    for _, l in ipairs(lbs) do
        l.Image = "rbxassetid://104651786116792"
        TweenService:Create(l, TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
    end
    task.wait(0.2)

    -- Один кадр цикла
    for _, l in ipairs(lbs) do l.Image = "rbxassetid://112204270873166" end
    task.wait(0.2)

    -- Быстрое закрытие
    for _, l in ipairs(lbs) do
        l.Image = "rbxassetid://135958825930181"
        TweenService:Create(l, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
    end
    task.wait(0.2)
    p:Destroy()
end

-- --- ЛОГИКА ВЫХОДА (ВЫПОЛНЯЕТСЯ СРАЗУ) ---
task.spawn(function()
    local root = character:WaitForChild("HumanoidRootPart")
    local ep = portalTemplate:Clone()
    -- Спавн на 1 студ выше
    ep.CFrame = root.CFrame * CFrame.new(0, 1, -2) 
    ep.Parent = workspace
    
    -- Звук при выходе (берем из пушки)
    local s = portalGun:FindFirstChild("PortalSound", true)
    if s then s:Play() end
    
    -- Персонаж выходит
    humanoid:MoveTo((ep.CFrame * CFrame.new(0, 0, 7)).Position)
    runPortalFast(ep)
end)

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
srv.Size = UDim2.new(1, 0, 1, 0); srv.BackgroundTransparency = 1; srv.TextColor3 = Color3.new(1,1,1); srv.TextScaled = true; srv.Text = game.JobId:sub(1,10)

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
local anim = Instance.new("Animation")
anim.AnimationId = (humanoid.RigType == Enum.HumanoidRigType.R15) and "rbxassetid://507768375" or "rbxassetid://182393478"
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
    runPortalFast(p)
end

btn.MouseButton1Click:Connect(fire)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.E and tool.Parent == character then fire() end end)
