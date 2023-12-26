game:GetService("StarterGui"):SetCore("DevConsoleVisible",true); warn("Exed")

local workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Local = Players.LocalPlayer

local Camera = workspace.CurrentCamera
local Balls = workspace:WaitForChild("Balls")

getgenv().Signal = Signal or {}

function PlayerPoints()
	local tbl = {}
	for i, v in pairs(Players:GetPlayers()) do
		local UserId, HumanoidRootPart = tostring(v.UserId), v.Character and v.Character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart and v == Local then
			warn(v)
			tbl[UserId] = Camera:WorldToScreenPoint(HumanoidRootPart.Position)
		end
	end
	
	print(unpack(tbl))
	table.foreach(tbl, print)
	return tbl
end

function Parry()
if Local.Character then
	local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ParryAttempt")
	local WorldToScreenPoint = Camera:WorldToScreenPoint(Local.Character.HumanoidRootPart.Position)
	local args = {
		[1] = 0.5,
		[2] = workspace.CurrentCamera.CFrame,
		[3] = PlayerPoints(),
		[4] = {
			[1] = WorldToScreenPoint.X,
			[2] = WorldToScreenPoint.Y
		}
	}
	
	warn("Players:", unpack(args[3]))
	Remote:FireServer(unpack(args))
	end
end

local Debounce, LastPlayer, LastTime = false
function Anticipate(Time)
	if Debounce then return end
	
	if LastTime then
		local Sum = (Time - LastTime)
		if (Sum >= -25 and Sum <= 25) then
			print("Anticipated Time:", Sum, "Time:", Time, "LastTime:", LastTime)
			if Sum >= 25 or Sum <= -25 then
				return true
			end
		end
	end
	
	LastTime = Time
end

-- Function to calculate the time for projectile to reach a target
function calculateProjectileTime(initialPosition, targetPosition, initialVelocity)
	local distance = (targetPosition - initialPosition).Magnitude
	local time = distance / initialVelocity.Magnitude
	return time
end

-- Function to calculate the distance between projectile and object
function calculateDistance(projectilePosition, objectPosition)
	return math.abs((projectilePosition - objectPosition).Magnitude)
end

-- Function to check if the object can intercept (parry) the projectile
function canObjectParry(projectilePosition, objectPosition, projectileVelocity, objectVelocity)
	local timeToIntercept = calculateProjectileTime(projectilePosition, objectPosition, projectileVelocity)
	local distanceToIntercept = calculateDistance(projectilePosition + projectileVelocity * timeToIntercept, objectPosition + objectVelocity * timeToIntercept)
	local Anticipate = Anticipate(timeToIntercept)
	
	print("CanParry:", distanceToIntercept, timeToIntercept, Anticipate)
	
	local conditions = {
		(Anticipate and distanceToIntercept <= 75);
		(distanceToIntercept >= 35 and distanceToIntercept <= 50 and timeToIntercept <= 0.6);
		(distanceToIntercept >= 50 and distanceToIntercept <= 75 and timeToIntercept >= 0.6 and timeToIntercept <= 0.75);
		(distanceToIntercept <= 35 and timeToIntercept <= 0.5);
		(distanceToIntercept <= 12.5 and timeToIntercept >= 0.5 and timeToIntercept <= 0.75);
		(distanceToIntercept <= 0.025 and timeToIntercept <= 0.75);
		(distanceToIntercept >= 75 and distanceToIntercept <= 100 and timeToIntercept <= 0.5);
	}
	
	local r
	for i, v in pairs(conditions) do
		if v == true then
			warn(i, v)
			r = true
		end
	end
	
	if r then return true end
end

function chooseNewFocusedBall()
	local balls = workspace.Balls:GetChildren()
	for _, ball in ipairs(balls) do
		if ball:GetAttribute("realBall") ~= nil and ball:GetAttribute("realBall") == true then
			focusedBall = ball
			break
		elseif ball:GetAttribute("target") ~= nil then
			focusedBall = ball
			break
		end
	end
	
	return focusedBall
end

function foreach(Ball)
	local Ball = chooseNewFocusedBall()
	if (Ball) and not Debounce then
		for i, v in pairs(Signal) do table.remove(Signal, i); v:Disconnect() end
		local function Calculation(Delta)
			local Start, HumanoidRootPart, Player = os.clock(), Local.Character and Local.Character:FindFirstChild("HumanoidRootPart"), Players:FindFirstChild(Ball:GetAttribute("target"))
			if (Ball and Ball:FindFirstChild("zoomies") and Ball:GetAttribute("target") == Local.Name) and HumanoidRootPart and not Debounce then
				local timeToReachTarget = calculateProjectileTime(Ball.Position, HumanoidRootPart.Position, Ball.Velocity)
				local distanceToTarget = calculateDistance(Ball.Position, HumanoidRootPart.Position)
				local canParry = canObjectParry(Ball.Position, HumanoidRootPart.Position, Ball.Velocity, HumanoidRootPart.Velocity)

				warn(timeToReachTarget, "Distance:", canParry)
				if canParry then
					Parry()
					LastTime = nil
					Debounce = true
					local Signal = nil
					Signal = RunService.Stepped:Connect(function()
						warn("False:", Ball:GetAttribute("target"), os.clock()-Start, Ball, workspace.Dead:FindFirstChild(Local.Name))
						if Ball:GetAttribute("target") ~= Local.Name or os.clock()-Start >= 1.25 or not Ball or not workspace.Alive:FindFirstChild(Local.Name) then
							warn("Set to false")
							Debounce = false
							Signal:Disconnect()
						end
					end)
				end
			elseif (Ball and Ball:FindFirstChild("zoomies") and Ball:GetAttribute("target") ~= Local.Name) and HumanoidRootPart then
				--local HumanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
				--local Distance = CalculateDistance(HumanoidRootPart, Delta)
				LastPlayer = Player
			end
		end
		Signal[#Signal+1] = RunService.Stepped:Connect(Calculation)
	end
end

Parry()

function Init()
	Balls.ChildAdded:Connect(foreach)
	
	for i, v in pairs(Balls:GetChildren()) do
		foreach(v)
	end
end

Init()

--Local.ChildAdded:Connect(Init)
