local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local heartbeatConnection

local Window = Rayfield:CreateWindow({
   Name = "Blade Ball Thitiwat Hub",
   LoadingTitle = "thitiwat Hub",
   LoadingSubtitle = "X2n_z. is gay",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "Universe Hub",
      FileName = "Universe Hub"
   },
   Discord = {
      Enabled = true,
      Invite = "qysx7R5PF7",
      RememberJoins = false
   },
   KeySystem = true,
   KeySettings = {
      Title = "thitiwat key",
      Subtitle = "get key in discord",
      Note = "put key here!",
      FileName = "",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = "Thitiwat No.1"
   }
})

local AutoParry = Window:CreateTab("Main", 13014537525)

local function startAutoParry()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local runService = game:GetService("RunService")
    local parryButtonPress = replicatedStorage.Remotes.ParryButtonPress
    local ballsFolder = workspace:WaitForChild("Balls")


    local function onCharacterAdded(newCharacter)
        character = newCharacter
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    local focusedBall = nil  

    local function chooseNewFocusedBall()
        local balls = ballsFolder:GetChildren()
        focusedBall = nil
        for _, ball in ipairs(balls) do
            if ball:GetAttribute("realBall") == true then
                focusedBall = ball
                break
            end
        end
    end

    chooseNewFocusedBall()

    local function timeUntilImpact(ballVelocity, distanceToPlayer, playerVelocity)
        local directionToPlayer = (character.HumanoidRootPart.Position - focusedBall.Position).Unit
        local velocityTowardsPlayer = ballVelocity:Dot(directionToPlayer) - playerVelocity:Dot(directionToPlayer)
        
        if velocityTowardsPlayer <= 0 then
            return math.huge
        end
        
        local distanceToBeCovered = distanceToPlayer - 40
        return distanceToBeCovered / velocityTowardsPlayer
    end

    local BASE_THRESHOLD = 0.15
    local VELOCITY_SCALING_FACTOR = 0.002

    local function getDynamicThreshold(ballVelocityMagnitude)
        local adjustedThreshold = BASE_THRESHOLD - (ballVelocityMagnitude * VELOCITY_SCALING_FACTOR)
        return math.max(0.12, adjustedThreshold)
    end

    local function checkBallDistance()
        if not character:FindFirstChild("Highlight") then return end
        local charPos = character.PrimaryPart.Position
        local charVel = character.PrimaryPart.Velocity

        if focusedBall and not focusedBall.Parent then
            chooseNewFocusedBall()
        end

        if not focusedBall then return end

        local ball = focusedBall
        local distanceToPlayer = (ball.Position - charPos).Magnitude

        if distanceToPlayer < 10 then
            parryButtonPress:Fire()
            return
        end

        local timeToImpact = timeUntilImpact(ball.Velocity, distanceToPlayer, charVel)
        local dynamicThreshold = getDynamicThreshold(ball.Velocity.Magnitude)

        if timeToImpact < dynamicThreshold then
            parryButtonPress:Fire()
        end
    end
    heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        checkBallDistance()
    end)
end

local function stopAutoParry()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

local AutoParryToggle = AutoParry:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParryFlag",
    Callback = function(Value)
        if Value then
            startAutoParry()
        else
            stopAutoParry()
        end
    end,
})

local Debug = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local Balls = workspace:WaitForChild("Balls", 9e9)

local isAutoParryEnabled = false

local function print(...)
    if Debug then
        warn(...)
    end
end

local function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
end

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    if isAutoParryEnabled then
        Remotes:WaitForChild("ParryButtonPress"):Fire()
    end
end

Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    print(`Ball Spawned: {Ball}`)

    local OldPosition = Ball.Position
    local OldTick = tick()

    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local Distance = (Ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude 
            local Velocity = (OldPosition - Ball.Position).Magnitude

            print(`Distance: {Distance}\nVelocity: {Velocity}\nTime: {Distance / Velocity}`)

            if (Distance / Velocity) <= 10 then
                Parry()
            end
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
end)

AutoParry:CreateToggle({
    Name = "Auto Parry 2",
    CurrentValue = false, 
    Flag = "Toggle2",
    Callback = function(value)
        isAutoParryEnabled = value
    end
})


getgenv().god = false

local function ToggleGod(value)
    getgenv().god = value
    if value then
        while getgenv().god and task.wait() do
            for _,ball in next, workspace.Balls:GetChildren() do
                if ball then
                    if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, ball.Position)
                        if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Highlight") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(10, -10, (ball.Velocity).Magnitude * -0.140)
                            game:GetService("ReplicatedStorage").Remotes.ParryButtonPress:Fire()
                        end
                    end
                end
            end
        end
    end
end

AutoParry:CreateToggle({
    Name = "Rage Auto Parry",
    CurrentValue = false, 
    Flag = "Toggle223",
    Callback = ToggleGod
})

while getgenv().god and task.wait() do
    for _,ball in next, workspace.Balls:GetChildren() do
        if ball then
            if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, ball.Position)
                if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Highlight") then
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(10, -10, (ball.Velocity).Magnitude * -0.140)
                    game:GetService("ReplicatedStorage").Remotes.ParryButtonPress:Fire()
                end
            end
        end
    end
end

local Skill = Window:CreateTab("Skills", 13014537525)

local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local abilitiesFolder = character:WaitForChild("Abilities")

    Skill:CreateButton({
        Name = "Dash",
        Callback = function()
        ChosenAbility = "Dash"
        end
    })

    Skill:CreateButton({
        Name = "Rapture",
        Callback = function()
        ChosenAbility = "Rapture"
        end
    })

    Skill:CreateButton({
        Name = "Pull",
        Callback = function()
        ChosenAbility = "Pull"
        end
    })

    Skill:CreateButton({
        Name = "Phase Bypass",
        Callback = function()
        ChosenAbility = "Phase Bypass"
        end
    })

    Skill:CreateButton({
        Name = "Shadow Step",
        Callback = function()
        ChosenAbility = "Shadow Step"
        end
    })

    Skill:CreateButton({
        Name = "Wind Cloak",
        Callback = function()
        ChosenAbility = "Wind Cloak"
        end
    })

    Skill:CreateButton({
        Name = "Invisibility",
        Callback = function()
        ChosenAbility = "Invisibility"
        end
    })

    Skill:CreateButton({
        Name = "Platform",
        Callback = function()
        ChosenAbility = "Platform"
        end
    })

    Skill:CreateButton({
        Name = "Raging Deflection",
        Callback = function()
        ChosenAbility = "Raging Deflection"
        end
    })
    Skill:CreateButton({
        Name = "Super Jump",
        Callback = function()
        ChosenAbility = "Super Jump"
        end
    })
    Skill:CreateButton({
        Name = "Telekinesis",
        Callback = function()
        ChosenAbility = "Telekinesis"
        end
    })
    Skill:CreateButton({
        Name = "Thunder Dash",
        Callback = function()
        ChosenAbility = "Thunder Dash"
        end
    })

    Skill:CreateButton({
        Name = "Waypoint",
        Callback = function()
        ChosenAbility = "Waypoint"
        end
    })

    Skill:CreateButton({
        Name = "Infinity",
        Callback = function()
        ChosenAbility = "Infinity"
        end
    })


local function onCharacterAdded(newCharacter)
    character = newCharacter
    abilitiesFolder = character:WaitForChild("Abilities")
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

local function AbilityUpdater()
    while true do
        if abilitiesFolder then
            for _, obj in pairs(abilitiesFolder:GetChildren()) do
                if obj:IsA("LocalScript") then
                    if obj.Name == ChosenAbility then
                        obj.Disabled = false
                    else
                        obj.Disabled = true
                    end
                end
            end
        end
        task.wait()
    end
end

spawn(AbilityUpdater)

AutoParry:CreateToggle({
    Name = "Skill No CoolDown",
    CurrentValue = false, 
    Flag = "Toggle2",
    Callback = function(value)
        xx = value
    end
})

while task.wait(2) do
    if xx then
        for _, obj in pairs(abilitiesFolder:GetChildren()) do
            if obj:IsA("LocalScript") then
                obj.Disabled = not obj.Disabled
            end
        end
    end
end 
