local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local Characters = require(ReplicatedStorage.Shared.Characters)
local Avatar = require(script.Parent.Avatar)
local Combat = require(script.Parent.Combat)
local Skills = require(script.Parent.Skills)
local Destruction = require(script.Parent.Destruction)

Players.CharacterAutoLoads = false

PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:RegisterCollisionGroup("Debris")
PhysicsService:CollisionGroupSetCollidable("Players", "Debris", false)

local function block(parent, size, cframe, color, destructible)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.Concrete
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if destructible then
		Destruction.tag(part)
	end
	part.Parent = parent
	return part
end

local function buildTestArena()
	local arena = Instance.new("Folder")
	arena.Name = "TestArena"
	block(arena, Vector3.new(320, 8, 320), CFrame.new(0, -4, 0), Color3.fromRGB(58, 60, 66), false)
	block(arena, Vector3.new(160, 4, 160), CFrame.new(0, 2, 60 + 80), Color3.fromRGB(92, 94, 100), true)
	block(arena, Vector3.new(32, 16, 4), CFrame.new(0, 8, -40), Color3.fromRGB(140, 132, 120), true)
	block(arena, Vector3.new(4, 16, 32), CFrame.new(-36, 8, -24), Color3.fromRGB(140, 132, 120), true)
	for i = -1, 1 do
		block(arena, Vector3.new(8, 24, 8), CFrame.new(40, 12, i * 22), Color3.fromRGB(120, 124, 134), true)
	end
	arena.Parent = workspace
end

if Config.TestArena then
	buildTestArena()
	for index = 1, Config.TestDummies do
		task.spawn(Avatar.spawnDummy, index)
	end
end

Combat.start()
Skills.start()

local lastSelect = {}

Net.SelectCharacter.OnServerEvent:Connect(function(player, id)
	if type(id) ~= "string" or not Characters.List[id] then
		return
	end
	local now = os.clock()
	if now - (lastSelect[player] or 0) < 2 then
		return
	end
	lastSelect[player] = now
	player:SetAttribute("Character", id)
	Avatar.spawn(player)
end)

local function onPlayer(player)
	player:SetAttribute("Character", Characters.Default)
	Avatar.spawn(player)
end

Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
	lastSelect[player] = nil
	Avatar.forget(player)
end)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
