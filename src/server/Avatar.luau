local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Characters = require(ReplicatedStorage.Shared.Characters)
local State = require(script.Parent.State)
local Ragdoll = require(script.Parent.Ragdoll)

local BODY_PARTS = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
local ACCESSORY_SLOTS = { "HatAccessory", "FaceAccessory", "NeckAccessory", "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory" }

local Avatar = {}
local descriptions = {}
local spawning = {}

local function sanitize(description)
	local hair = description.HairAccessory
	pcall(function()
		description:SetAccessories({}, true)
	end)
	for _, property in BODY_PARTS do
		description[property] = 0
	end
	for _, property in ACCESSORY_SLOTS do
		description[property] = ""
	end
	description.HairAccessory = Config.KeepHair and hair or ""
	return description
end

local function descriptionFor(player)
	local cached = descriptions[player]
	if cached then
		return cached
	end
	local ok, description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if not ok or not description then
		description = Instance.new("HumanoidDescription")
	end
	descriptions[player] = sanitize(description)
	return descriptions[player]
end

local function strip(character)
	for _, child in character:GetChildren() do
		if child:IsA("CharacterMesh") then
			child:Destroy()
		elseif child:IsA("Accessory") then
			local isHair = child.AccessoryType == Enum.AccessoryType.Hair
			if not (Config.KeepHair and isHair) then
				child:Destroy()
			end
		end
	end
end

local function randomSpawn()
	return CFrame.new(math.random(-26, 26), 5, math.random(-26, 26))
end

function Avatar.prepare(character, onDied)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then
		return
	end
	strip(character)
	humanoid.MaxHealth = Config.MaxHealth
	humanoid.Health = Config.MaxHealth
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.UseJumpPower = true
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end
	State.get(character)
	State.refresh(character)
	humanoid.Died:Once(function()
		Ragdoll.start(character, math.huge)
		if onDied then
			onDied()
		end
	end)
end

function Avatar.spawn(player)
	if spawning[player] then
		return
	end
	spawning[player] = true
	local description = descriptionFor(player)
	pcall(function()
		player:LoadCharacterWithHumanoidDescription(description)
	end)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		if character then
			character:Destroy()
		end
		local ok, model = pcall(function()
			return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6)
		end)
		if ok and model then
			model.Name = player.Name
			player.Character = model
			model.Parent = workspace
			character = model
		else
			character = nil
		end
	end
	spawning[player] = nil
	if not character or player.Parent ~= Players then
		return
	end
	if not player:GetAttribute("Character") then
		player:SetAttribute("Character", Characters.Default)
	end
	player:SetAttribute("Ult", Config.TestUltFull and Config.Ult.Max or 0)
	player:SetAttribute("UltMode", false)
	player:SetAttribute("UltPhase", "")
	player:SetAttribute("UltEvasion", false)
	player:SetAttribute("UltRebirth", false)
	for index = 1, 4 do
		player:SetAttribute("CD" .. index, 0)
	end
	if Config.TestArena then
		character:PivotTo(randomSpawn())
	end
	Avatar.prepare(character, function()
		task.delay(Config.RespawnTime, function()
			if player.Parent == Players and player.Character == character then
				Avatar.spawn(player)
			end
		end)
	end)
end

function Avatar.spawnDummy(index)
	local ok, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
	end)
	if not ok or not model then
		return
	end
	model.Name = "Dummy"
	model:PivotTo(CFrame.new(index * 10 - 15, 5, -20))
	model.Parent = workspace
	Avatar.prepare(model, function()
		task.delay(Config.RespawnTime, function()
			model:Destroy()
			Avatar.spawnDummy(index)
		end)
	end)
end

function Avatar.forget(player)
	descriptions[player] = nil
	spawning[player] = nil
end

return Avatar
