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

    local targetNames = {
        CommonCoin = true,
        RareCoin = true,
        EpicCoin = true,
        LegendaryCoin = true,
        MythicalCoin = true,
    }

    local char, hrp, bv
    local antiAfkConn, noclipConn

    local function ensureCharacter()
        char = player.Character or player.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")

        if bv and bv.Parent ~= hrp then
            bv.Parent = hrp
        elseif not bv then
            bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
        end
    end

    ensureCharacter()
    player.CharacterAdded:Connect(ensureCharacter)

    if getgenv().Sleep_For_UGC["Auto Reconnect"] then
        pcall(function()
            local url = "https://raw.githubusercontent.com/norwaylua/Alwi-script/refs/heads/main/Auto%20Reconnect.lua"
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and type(res) == "string" and #res > 10 then
                pcall(loadstring(res))
            end
        end)
    end

    if getgenv().Sleep_For_UGC.AntiAFK then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            antiAfkConn = player.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end

    noclipConn = RunService.Stepped:Connect(function()
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

    local function tweenToModel(target)
        if not target or not target:IsA("Model") then return end
        if not target.PrimaryPart then
            pcall(function() target.PrimaryPart = target:FindFirstChildWhichIsA("BasePart") end)
        end
        if not target.PrimaryPart or not hrp then return end

        local speed = math.max(1, tonumber(getgenv().Sleep_For_UGC.Speed) or 40)
        local dist = (hrp.Position - target.PrimaryPart.Position).Magnitude
        local time = math.max(0.05, dist / speed)

        char:PivotTo(hrp.CFrame)
        local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = target.PrimaryPart.CFrame})
        tween:Play()

        local ok, unit = pcall(function() return (target.PrimaryPart.Position - hrp.Position).Unit end)
        if ok and unit then bv.Velocity = unit * speed end

        tween.Completed:Wait()
        if bv then bv.Velocity = Vector3.zero end
    end

    local function tweenToPart(part)
        if not part or not char or not char.PrimaryPart then return end
        local speed = math.max(1, tonumber(getgenv().Sleep_For_UGC.Speed) or 40)
        local dist = (char.PrimaryPart.Position - part.Position).Magnitude
        local time = math.max(0.05, dist / speed)
        local tween = TweenService:Create(char.PrimaryPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = part.CFrame + Vector3.new(0, 5, 0)})
        tween:Play()
        tween.Completed:Wait()
    end

    local function findOwnedBed()
        for _, child in ipairs(Workspace:GetChildren()) do
            local bedPart = child:FindFirstChild("MainBedPart")
            if bedPart then
                local ownerTag = bedPart:FindFirstChild("OwnerNameTag")
                if ownerTag then
                    local textLabel = ownerTag:FindFirstChild("TextLabel")
                    if textLabel and type(textLabel.Text) == "string" and textLabel.Text:lower():find(player.Name:lower()) then
                        return bedPart
                    end
                end
            end
        end
        return nil
    end

    local function findNearestUnclaimedBed()
        local closest, shortest = nil, math.huge
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.ObjectText == "Unclaimed Bed" and prompt.ActionText == "Claim Bed" then
                local ok, pos = pcall(function() return prompt.Parent.Position end)
                if ok and hrp then
                    local d = (hrp.Position - pos).Magnitude
                    if d < shortest then
                        shortest = d
                        closest = prompt
                    end
                end
            end
        end
        return closest
    end

    local function anyCoinsExist()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if targetNames[obj.Name] and obj:IsA("Model") then return true end
        end
        return false
    end

    local function wakeUp(attempts, delay)
        attempts = tonumber(attempts) or 6
        delay = tonumber(delay) or 0.22
        if not ReplicatedStorage:FindFirstChild("Remotes") or not ReplicatedStorage.Remotes:FindFirstChild("EndSleep") then return false end
        for i = 1, attempts do
            pcall(function() ReplicatedStorage.Remotes.EndSleep:FireServer() end)
            task.wait(delay)
            if anyCoinsExist() then return true end
        end
        pcall(function() ReplicatedStorage.Remotes.EndSleep:FireServer() end)
        return anyCoinsExist()
    end

    task.spawn(function()
        local sleeping = false
        while true do
            task.wait(0.25)
            local autoFarm = getgenv().Sleep_For_UGC.AutoFarm

            if sleeping then
                if autoFarm and anyCoinsExist() then
                    if wakeUp(6, 0.22) then
                        sleeping = false
                        task.wait(0.2)
                    end
                elseif not autoFarm then
                    sleeping = false
                end
            end

            local acted = false
            if autoFarm and not sleeping then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if targetNames[obj.Name] and obj:IsA("Model") then
                        acted = true
                        tweenToModel(obj)
                        task.wait(0.08)
                    end
                end
            end
            if acted then continue end

            local bed = findOwnedBed()
            if not bed then
                local prompt = findNearestUnclaimedBed()
                if prompt then
                    tweenToPart(prompt.Parent)
                    safeFireProximity(prompt)
                    task.wait(0.12)
                end
                bed = findOwnedBed()
            end

            if bed then
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.ObjectText == "Your Bed" and prompt.ActionText == "Sleep" then
                        safeFireProximity(prompt)
                        sleeping = true
                        break
                    end
                end
            end
        end
    end)
end
