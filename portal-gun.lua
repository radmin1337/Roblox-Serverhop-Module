--[[ 
    RICK & MORTY PORTAL GUN - GITHUB EDITION
    Asset ID: 95480961882251
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local FRAME_TIME = 0.5
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portal-gun.lua"
local portalGun = nil
local portalTemplate = nil

local success, assets = pcall(function()
    return game:GetObjects("rbxassetid://95480961882251")
end)

if success and assets then
    local root = assets[1]
    if root:IsA("Tool") then
        portalGun = root
    else
        portalGun = root:FindFirstChild("Portal Gun", true)
    end

    if portalGun then
        local foundPortal = portalGun:FindFirstChild("Portal")
        if foundPortal then
            portalTemplate = foundPortal:Clone()
            foundPortal:Destroy() 
        end
    end
end

if not portalGun or not portalTemplate then
    warn("Ошибка загрузки ассетов!")
    return
end

local intro = {"rbxassetid://104651786116792", "rbxassetid://106781038483440"}
local loop = {"rbxassetid://112204270873166", "rbxassetid://136733250763134"}
local outro = {"rbxassetid://74852451754370", "rbxassetid://135958825930181"}

local function runPortal(p)
    local guis = {p:WaitForChild("SurfaceGui1"), p:WaitForChild("SurfaceGui2")}
    local lbs, ovs = {}, {}
    for _, g in ipairs(guis) do
        local b = g:WaitForChild("PortalLabel")
        local o = b:Clone()
        o.Parent = g; o.ZIndex = b.ZIndex + 1; o.ImageTransparency = 1
        table.insert(lbs, b); table.insert(ovs, o)
    end
    local function step(id)
        for i, l in ipairs(lbs) do
            ovs[i].Image = l.Image; ovs[i].ImageTransparency = 0
            l.Image = id
            TweenService:Create(ovs[i], TweenInfo.new(FRAME_TIME), {ImageTransparency = 1}):Play()
        end
        task.wait(FRAME_TIME)
    end
    for _, id in ipairs(intro) do 
        for _, l in ipairs(lbs) do l.Image = id; TweenService:Create(l, TweenInfo.new(0.3), {ImageTransparency = 0}):Play() end
        task.wait(FRAME_TIME)
    end
    for i = 1, 8 do for _, id in ipairs(loop) do step(id) end end
    for _, id in ipairs(outro) do 
        step(id)
        for _, l in ipairs(lbs) do TweenService:Create(l, TweenInfo.new(0.3), {ImageTransparency = 1}):Play() end
    end
    p:Destroy()
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Enabled = false
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 260, 0, 190); frame.Position = UDim2.new(0.5, -130, 0.7, 0); frame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)
local disp = Instance.new("Frame", frame)
disp.Size = UDim2.new(0.9, 0, 0.3, 0); disp.Position = UDim2.new(0.05, 0, 0.05, 0); disp.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Instance.new("UICorner", disp)
local srvTxt = Instance.new("TextLabel", disp)
srvTxt.Size = UDim2.new(1, 0, 1, 0); srvTxt.BackgroundTransparency = 1; srvTxt.TextColor3 = Color3.new(1, 1, 1); srvTxt.TextScaled = true; srvTxt.Text = "SRV: " .. (game.JobId:sub(1,10))
local inP = Instance.new("TextBox", frame)
inP.Size = UDim2.new(0.9, 0, 0.15, 0); inP.Position = UDim2.new(0.05, 0, 0.4, 0); inP.Text = tostring(game.PlaceId)
Instance.new("UICorner", inP)
local inJ = Instance.new("TextBox", frame)
inJ.Size = UDim2.new(0.9, 0, 0.15, 0); inJ.Position = UDim2.new(0.05, 0, 0.58, 0); inJ.Text = game.JobId
Instance.new("UICorner", inJ)
local fireBtn = Instance.new("TextButton", frame)
fireBtn.Size = UDim2.new(0.7, 0, 0.2, 0); fireBtn.Position = UDim2.new(0.15, 0, 0.78, 0); fireBtn.BackgroundColor3 = Color3.new(1, 1, 1)
fireBtn.Text = "FIRE"; fireBtn.Font = Enum.Font.SourceSansBold; fireBtn.TextColor3 = Color3.new(0, 0, 0)
Instance.new("UICorner", fireBtn)

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
                    if not game:IsLoaded() then game.Loaded:Wait() end
                    _G.ExitPortal = true
                    pcall(function()
                        loadstring(game:HttpGet("]] .. GITHUB_RAW_URL .. [["))()
                    end)
                ]])
            end
            TeleportService:TeleportToPlaceInstance(tonumber(inP.Text), inJ.Text, player)
        end
    end)
    runPortal(p)
end

fireBtn.MouseButton1Click:Connect(fire)
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.E and tool.Parent == character then fire() end
end)

if _G.ExitPortal then
    _G.ExitPortal = nil
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        local root = character:WaitForChild("HumanoidRootPart")
        local ep = portalTemplate:Clone()
        ep.CFrame = root.CFrame * CFrame.new(0, 1, -2)
        ep.Parent = workspace
        humanoid:MoveTo((ep.CFrame * CFrame.new(0, 0, 7)).Position)
        runPortal(ep)
    end)
end
