local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local FRAME_TIME = 0.5
local RAW_URL = "https://raw.githubusercontent.com/radmin1337/serverhop/refs/heads/main/portalgun.lua"
if not game:IsLoaded() then game.Loaded:Wait() end
local portalGunTemplate = nil
local portalPartTemplate = nil

local function loadAssets()
    local success, assets = pcall(function()
        return game:GetObjects("rbxassetid://100648707792532")
    end)
    if success and assets then
        for _, root in ipairs(assets) do
            local all = root:GetDescendants()
            table.insert(all, root)
            for _, obj in ipairs(all) do
                if obj:IsA("Tool") and obj.Name == "Portal Gun" then 
                    portalGunTemplate = obj 
                end
            end
        end
        if portalGunTemplate then
            local inner = portalGunTemplate:FindFirstChild("Portal", true)
            if inner then
                portalPartTemplate = inner:Clone()
                inner:Destroy() 
            end
        end
    end
end
loadAssets()

local function playSound(id, isGlobal)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = 2
    s.Parent = isGlobal and SoundService or (player.Character and player.Character:FindFirstChild("HumanoidRootPart"))
    if not s.Parent then s.Parent = SoundService end
    s:Play()
    Debris:AddItem(s, 5)
end

local intro = {"rbxassetid://104651786116792", "rbxassetid://106781038483440"}
local loopFrames = {"rbxassetid://112204270873166", "rbxassetid://136733250763134"}
local outro = {"rbxassetid://74852451754370", "rbxassetid://135958825930181"}

local function runPortalLogic(part, isExit)
    local guis = {part:WaitForChild("SurfaceGui1"), part:WaitForChild("SurfaceGui2")}
    local labels, overlays = {}, {}

    for _, gui in ipairs(guis) do
        local base = gui:WaitForChild("PortalLabel")
        local ov = base:Clone()
        ov.Parent = gui; ov.ZIndex = base.ZIndex + 1
        ov.BackgroundTransparency = 1; ov.ImageTransparency = 1
        table.insert(labels, base); table.insert(overlays, ov)
    end

    local function transition(newImage, duration)
        for i, lbl in ipairs(labels) do
            overlays[i].Image = lbl.Image; overlays[i].ImageTransparency = 0
            lbl.Image = newImage
            TweenService:Create(overlays[i], TweenInfo.new(duration or FRAME_TIME), {ImageTransparency = 1}):Play()
        end
        task.wait(duration or FRAME_TIME)
    end

    if not isExit then
        for _, id in ipairs(intro) do
            for _, lbl in ipairs(labels) do lbl.Image = id end
            for _, lbl in ipairs(labels) do TweenService:Create(lbl, TweenInfo.new(0.25), {ImageTransparency = 0}):Play() end
            task.wait(FRAME_TIME)
        end
    else
        for _, lbl in ipairs(labels) do lbl.ImageTransparency = 0 end
    end

    local loops = isExit and 4 or 9
    for i = 1, loops do
        if _G.PortalFailSignal then break end
        for _, id in ipairs(loopFrames) do 
            if _G.PortalFailSignal then break end
            transition(id) 
        end
    end

    playSound(81393928489003, false)
    transition(outro[1])
    for _, lbl in ipairs(labels) do lbl.Image = outro[2] end
    for _, lbl in ipairs(labels) do TweenService:Create(lbl, TweenInfo.new(0.5), {ImageTransparency = 1}):Play() end
    task.wait(0.5)
    part:Destroy()
end

local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "RickPortalUI"
sg.DisplayOrder = 2147483647 
sg.ResetOnSpawn = false
sg.Enabled = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 240)
main.Position = UDim2.new(0.5, -160, 0.7, 0)
main.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)

local redDisp = Instance.new("Frame", main)
redDisp.Size = UDim2.new(0, 280, 0, 130)
redDisp.Position = UDim2.new(0.5, -140, 0, 15)
redDisp.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Instance.new("UICorner", redDisp)

local inP = Instance.new("TextBox", redDisp)
inP.Size = UDim2.new(0.9, 0, 0.4, 0); inP.Position = UDim2.new(0.05, 0, 0.1, 0)
inP.BackgroundTransparency = 1; inP.TextColor3 = Color3.new(1,1,1); inP.TextScaled = true
inP.PlaceholderText = tostring(game.PlaceId) 
inP.Text = ""

local inJ = Instance.new("TextBox", redDisp)
inJ.Size = UDim2.new(0.9, 0, 0.4, 0); inJ.Position = UDim2.new(0.05, 0, 0.5, 0)
inJ.BackgroundTransparency = 1; inJ.TextColor3 = Color3.new(1,1,1); inJ.TextScaled = true
inJ.PlaceholderText = game.JobId 
inJ.Text = ""

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0, 280, 0, 60); btn.Position = UDim2.new(0.5, -140, 0, 160)
btn.BackgroundColor3 = Color3.new(1, 1, 1); btn.Text = "FIRE"; btn.TextColor3 = Color3.new(0,0,0)
btn.TextScaled = true; btn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", btn)

local currentTool = nil
local function giveTool()
    if portalGunTemplate then
        currentTool = portalGunTemplate:Clone()
        currentTool.Parent = player.Backpack
        local anim = Instance.new("Animation")
        anim.AnimationId = (player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and "rbxassetid://507768375" or "rbxassetid://182393478"
        local track = player.Character.Humanoid:LoadAnimation(anim)
        currentTool.Equipped:Connect(function() sg.Enabled = true; track:Play() end)
        currentTool.Unequipped:Connect(function() sg.Enabled = false; track:Stop() end)
    end
end

player.CharacterAdded:Connect(function() task.wait(1) giveTool() end)
giveTool()

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.N and (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
        if currentTool then
            if currentTool.Parent == player.Backpack then
                player.Character.Humanoid:EquipTool(currentTool)
            elseif currentTool.Parent == player.Character then
                player.Character.Humanoid:UnequipTools()
            end
        end
    end
end)

local function fire()
    _G.PortalFailSignal = false
    local tP = tonumber(inP.Text) or game.PlaceId
    local tJ = (inJ.Text ~= "") and inJ.Text or game.JobId
    
    playSound(119130398859498, false)

    local p = portalPartTemplate:Clone()
    p.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, -6)
    p.Parent = workspace

    local active = true
    p.Touched:Connect(function(hit)
        if active and hit.Parent == player.Character then
            active = false
            if queue_on_teleport then
                queue_on_teleport([[
                    shared.IsPortalExit = true
                    loadstring(game:HttpGet("]]..RAW_URL..[["))()
                ]])
            end
            pcall(function()
                if tJ ~= "" and tJ ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(tP, tJ, player)
                else
                    TeleportService:Teleport(tP, player)
                end
            end)
            task.delay(2, function()
                if p.Parent then
                    _G.PortalFailSignal = true
                end
            end)
        end
    end)
    runPortalLogic(p, false)
end

btn.MouseButton1Click:Connect(fire)
UserInputService.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.E and currentTool and currentTool.Parent == player.Character then 
        fire() 
    end 
end)

if shared.IsPortalExit then
    shared.IsPortalExit = nil
    task.spawn(function()
        local root = player.Character:WaitForChild("HumanoidRootPart")
        local ep = portalPartTemplate:Clone()
        ep.CFrame = root.CFrame * CFrame.new(0, 1, -2)
        ep.Parent = workspace
        playSound(88870484245841, true) 
        player.Character.Humanoid:MoveTo((ep.CFrame * CFrame.new(0, 0, 7)).Position)
        runPortalLogic(ep, true)
    end)
end
