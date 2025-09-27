--[[
-- There a config.lua
getgenv().Sleep_For_UGC = {
    ["AutoFarm"] = true,
    ["Speed"] = 40,
    ["Auto Reconnect"] = false,
    ["AntiAFK"]= true,
}
-]]
if game.PlaceId == 108903312165288 then
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = workspace

    local player = Players.LocalPlayer
    local targetNames = { CommonCoin=true, RareCoin=true, EpicCoin=true, LegendaryCoin=true, MythicalCoin=true }

    local char, hrp, bv
    local sleeping = false

    local function ensureCharacter()
        char = player.Character or player.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")

        if bv and bv.Parent ~= hrp then
            bv.Parent = hrp
        elseif not bv then
            bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Parent = hrp
        end
    end
    ensureCharacter()
    player.CharacterAdded:Connect(ensureCharacter)

    if getgenv().Sleep_For_UGC.AntiAFK then
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
    end

    RunService.Stepped:Connect(function()
        if char and char.Parent then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end)

    local function safeFireProximity(prompt)
        pcall(function() fireproximityprompt(prompt) end)
    end

    local function tweenToPart(part)
        if not part or not hrp then return end
        local speed = getgenv().Sleep_For_UGC.Speed or 40
        local dist = (hrp.Position - part.Position).Magnitude
        local tweenTime = math.max(0.05, dist / speed)
        local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = part.CFrame + Vector3.new(0,5,0)})
        tween:Play()
        tween.Completed:Wait()
    end

    local function tweenToModel(model)
        if not model or not model.PrimaryPart or not hrp then return end
        local speed = getgenv().Sleep_For_UGC.Speed or 40
        local dist = (hrp.Position - model.PrimaryPart.Position).Magnitude
        local tweenTime = math.max(0.05, dist / speed)
        local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = model.PrimaryPart.CFrame})
        tween:Play()
        bv.Velocity = (model.PrimaryPart.Position - hrp.Position).Unit * speed
        tween.Completed:Wait()
        bv.Velocity = Vector3.zero
    end

    local function anyCoinsExist()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if targetNames[obj.Name] and obj:IsA("Model") then return true end
        end
        return false
    end

    local function findOwnedBed()
        for _, child in ipairs(Workspace:GetChildren()) do
            local bed = child:FindFirstChild("MainBedPart")
            if bed then
                local ownerTag = bed:FindFirstChild("OwnerNameTag")
                if ownerTag then
                    local txt = ownerTag:FindFirstChild("TextLabel")
                    if txt and txt.Text:lower():find(player.Name:lower()) then
                        return bed
                    end
                end
            end
        end
    end

    local function findNearestUnclaimedBed()
        local closest, shortest = nil, math.huge
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.ObjectText=="Unclaimed Bed" and prompt.ActionText=="Claim Bed" then
                local ok, pos = pcall(function() return prompt.Parent.Position end)
                if ok and hrp then
                    local d = (hrp.Position - pos).Magnitude
                    if d then
                        shortest = d
                        closest = prompt
                    end
                end
            end
        end
        return closest
    end

    local function sleepAtBed()
        local bed = findOwnedBed()
        if not bed then
            local prompt = findNearestUnclaimedBed()
            if prompt then
                tweenToPart(prompt.Parent)
                safeFireProximity(prompt)
                task.wait(0.1)
                bed = findOwnedBed()
            end
        end
        if bed then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ObjectText=="Your Bed" and prompt.ActionText=="Sleep" then
                    safeFireProximity(prompt)
                    sleeping = true
                end
            end
        end
    end

    local function wakeUpIfCoins()
        if sleeping and anyCoinsExist() then
            local remotes = ReplicatedStorage:WaitForChild("Remotes")
            if remotes:FindFirstChild("EndSleep") then
                pcall(function() remotes.EndSleep:FireServer() end)
                task.wait(0.2)
                sleeping = false
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.2)

            wakeUpIfCoins()

            local coinsFound = false
            if getgenv().Sleep_For_UGC.AutoFarm and not sleeping then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if targetNames[obj.Name] and obj:IsA("Model") then
                        coinsFound = true
                        tweenToModel(obj)
                        task.wait(0.05)
                    end
                end
            end

            if getgenv().Sleep_For_UGC.AutoFarm and not coinsFound and not sleeping then
                sleepAtBed()
            end
        end
    end)
end
