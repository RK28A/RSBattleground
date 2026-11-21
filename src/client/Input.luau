local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Net = require(Shared:WaitForChild("Net"))
local Characters = require(Shared:WaitForChild("Characters"))
local Anim = require(Shared:WaitForChild("Anim"))
local Fx = require(script.Parent:WaitForChild("Fx"))

local M1 = Config.M1
local FLAT = Vector3.new(1, 0, 1)
local SKILL_KEYS = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
}

local player = Players.LocalPlayer

local Input = {}

local holdingM1 = false
local holdingBlock = false
local blocking = false
local blockSentAt = 0
local combo = 0
local lastM1 = 0
local attackUntil = 0
local comboLock = 0
local dashReady = { DashSide = 0, DashFront = 0 }

local function now()
	return workspace:GetServerTimeNow()
end

local function parts()
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or humanoid.Health <= 0 then
		return nil
	end
	return character, humanoid, root
end

local function canAct()
	local character = parts()
	return character ~= nil and not character:GetAttribute("Stunned") and not character:GetAttribute("Ragdolled")
end

local function impulse(root, direction, speed, duration)
	local attachment = Instance.new("Attachment")
	local force = Instance.new("LinearVelocity")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	force.LineDirection = direction
	force.LineVelocity = speed
	force.MaxForce = 1e6
	force.Parent = attachment
	attachment.Parent = root
	Debris:AddItem(attachment, duration)
end

local function tryM1()
	if blocking or not canAct() then
		return
	end
	local time = now()
	if time < attackUntil or time < comboLock then
		return
	end
	local character, humanoid, root = parts()
	if time - lastM1 > M1.ComboReset then
		combo = 0
	end
	combo += 1
	lastM1 = time
	attackUntil = time + M1.Interval

	local def = Characters.get(player:GetAttribute("Character"))
	local clip = def.M1Set .. combo
	local hint = nil
	local heavy = false
	local airborne = humanoid.FloorMaterial == Enum.Material.Air
	if combo >= 4 then
		combo = 0
		comboLock = time + M1.ComboCooldown
		heavy = true
		if airborne and root.AssemblyLinearVelocity.Y < -4 then
			hint, clip = "Down", "Downslam"
		elseif airborne or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			hint, clip = "Up", "Uppercut"
		end
	end

	Anim.play(character, clip)
	Fx.Swing({ Character = character, Heavy = heavy })
	if not airborne then
		impulse(root, (root.CFrame.LookVector * FLAT).Unit, M1.Lunge, M1.LungeTime)
	end
	Net.M1:FireServer(hint)
end

local function startBlock()
	if blocking or not canAct() or now() < attackUntil then
		return
	end
	local character = parts()
	blocking = true
	blockSentAt = now()
	Anim.play(character, "Block")
	Net.Block:FireServer(true)
end

local function stopBlock()
	if not blocking then
		return
	end
	blocking = false
	local character = player.Character
	if character then
		Anim.stop(character, "Block")
	end
	Net.Block:FireServer(false)
end

local function tryDash()
	if blocking or not canAct() then
		return
	end
	local character, _, root = parts()
	local camera = workspace.CurrentCamera
	local forward = (camera.CFrame.LookVector * FLAT).Unit
	local right = (camera.CFrame.RightVector * FLAT).Unit
	local direction = forward
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		direction = -forward
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		direction = -right
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		direction = right
	end

	local facing = root.CFrame.LookVector:Dot(direction)
	local name = "Front"
	if facing < -0.5 then
		name = "Back"
	elseif facing < 0.5 then
		name = root.CFrame.RightVector:Dot(direction) > 0 and "Right" or "Left"
	end

	local key = (name == "Left" or name == "Right") and "DashSide" or "DashFront"
	local time = now()
	if time < dashReady[key] then
		return
	end
	dashReady[key] = time + Config.Dash.Cooldown[name]

	impulse(root, direction, Config.Dash.Speed, Config.Dash.Duration)
	Anim.play(character, "Dash" .. name)
	Fx.Dash({ Character = character })
	Net.Dash:FireServer(name)
end

local function resetLocal()
	blocking = false
	combo = 0
	lastM1 = 0
	attackUntil = 0
	comboLock = 0
	dashReady.DashSide = 0
	dashReady.DashFront = 0
end

local function watch(character)
	resetLocal()
	character:GetAttributeChangedSignal("Combo"):Connect(function()
		combo = character:GetAttribute("Combo") or 0
	end)
	character:GetAttributeChangedSignal("Stunned"):Connect(function()
		if character:GetAttribute("Stunned") then
			combo = character:GetAttribute("Combo") or 0
		end
	end)
end

function Input.start(hud)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdingM1 = true
			tryM1()
		elseif input.KeyCode == Enum.KeyCode.F then
			holdingBlock = true
			startBlock()
		elseif input.KeyCode == Enum.KeyCode.Q then
			tryDash()
		elseif input.KeyCode == Enum.KeyCode.G then
			hud.requestUlt()
		elseif input.KeyCode == Enum.KeyCode.M then
			hud.toggleRoster()
		elseif SKILL_KEYS[input.KeyCode] then
			local index = SKILL_KEYS[input.KeyCode]
			if not hud.pickUlt(index) and canAct() and not blocking then
				Net.Skill:FireServer(index)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdingM1 = false
		elseif input.KeyCode == Enum.KeyCode.F then
			holdingBlock = false
			stopBlock()
		end
	end)

	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if not character then
			return
		end
		if blocking then
			if character:GetAttribute("Stunned") or character:GetAttribute("Ragdolled") then
				blocking = false
				Anim.stop(character, "Block")
			elseif not character:GetAttribute("Blocking") and now() - blockSentAt > 0.35 then
				blockSentAt = now()
				if not Anim.isPlaying(character, "Block") then
					Anim.play(character, "Block")
				end
				Net.Block:FireServer(true)
			end
		elseif holdingBlock then
			startBlock()
		end
		if holdingM1 then
			tryM1()
		end
	end)

	player.CharacterAdded:Connect(watch)
	if player.Character then
		watch(player.Character)
	end
end

return Input
