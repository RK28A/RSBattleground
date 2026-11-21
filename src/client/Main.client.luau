local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Anim = require(Shared:WaitForChild("Anim"))
local Fx = require(script.Parent:WaitForChild("Fx"))
require(script.Parent:WaitForChild("FxSovereign"))
local Hud = require(script.Parent:WaitForChild("Hud"))
local Input = require(script.Parent:WaitForChild("Input"))

local player = Players.LocalPlayer

Net.Anim.OnClientEvent:Connect(function(character, name, play)
	if typeof(character) ~= "Instance" then
		return
	end
	if play then
		Anim.play(character, name)
	else
		Anim.stop(character, name)
	end
end)

Net.Fx.OnClientEvent:Connect(function(kind, data)
	local handler = Fx[kind]
	if type(handler) == "function" and type(data) == "table" then
		handler(data)
	end
end)

Net.Ragdoll.OnClientEvent:Connect(function(on)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if on then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	elseif humanoid.Health > 0 then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

Hud.start()
Input.start(Hud)
