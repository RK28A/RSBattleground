local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local names = { "M1", "Block", "Dash", "Skill", "Ult", "SelectCharacter", "Anim", "Fx", "Ragdoll" }

local Net = {}

if RunService:IsServer() then
	local folder = Instance.new("Folder")
	folder.Name = "Net"
	for _, name in names do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		Net[name] = remote
	end
	folder.Parent = ReplicatedStorage

	function Net.fireExcept(remote, except, ...)
		for _, player in Players:GetPlayers() do
			if player ~= except then
				remote:FireClient(player, ...)
			end
		end
	end
else
	local folder = ReplicatedStorage:WaitForChild("Net")
	for _, name in names do
		Net[name] = folder:WaitForChild(name)
	end
end

return Net
