local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local State = require(script.Parent.State)

local Ragdoll = {}

local LIMBS = { "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "Neck" }

local function build(character)
	local torso = character:FindFirstChild("Torso")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not torso then
		return nil
	end
	local folder = Instance.new("Folder")
	folder.Name = "RagdollRig"
	for _, name in LIMBS do
		local motor = torso:FindFirstChild(name)
		if motor and motor:IsA("Motor6D") and motor.Part1 then
			local limb = motor.Part1

			local a0 = Instance.new("Attachment")
			a0.CFrame = motor.C0
			a0.Parent = torso
			local a1 = Instance.new("Attachment")
			a1.CFrame = motor.C1
			a1.Parent = limb

			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			socket.LimitsEnabled = true
			socket.UpperAngle = name == "Neck" and 30 or 70
			socket.TwistLimitsEnabled = true
			socket.TwistLowerAngle = -35
			socket.TwistUpperAngle = 35
			socket.Parent = folder

			local collider = Instance.new("Part")
			collider.Name = "RagdollCollider"
			collider.Size = limb.Size * 0.7
			collider.Transparency = 1
			collider.Massless = true
			collider.CanQuery = false
			collider.CanTouch = false
			collider.CollisionGroup = "Players"
			collider.CFrame = limb.CFrame
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = limb
			weld.Part1 = collider
			weld.Parent = collider
			for _, other in { torso, root } do
				if other then
					local noCollide = Instance.new("NoCollisionConstraint")
					noCollide.Part0 = collider
					noCollide.Part1 = other
					noCollide.Parent = collider
				end
			end
			collider.Parent = folder

			local marker = Instance.new("ObjectValue")
			marker.Name = "Motor"
			marker.Value = motor
			marker.Parent = socket
			local m0 = Instance.new("ObjectValue")
			m0.Name = "A0"
			m0.Value = a0
			m0.Parent = socket
			local m1 = Instance.new("ObjectValue")
			m1.Name = "A1"
			m1.Value = a1
			m1.Parent = socket

			motor.Enabled = false
		end
	end
	folder.Parent = character
	return folder
end

local function clear(character)
	local folder = character:FindFirstChild("RagdollRig")
	if not folder then
		return
	end
	for _, socket in folder:GetChildren() do
		if socket:IsA("BallSocketConstraint") then
			local motor = socket:FindFirstChild("Motor")
			if motor and motor.Value then
				motor.Value.Enabled = true
			end
			for _, name in { "A0", "A1" } do
				local ref = socket:FindFirstChild(name)
				if ref and ref.Value then
					ref.Value:Destroy()
				end
			end
		end
	end
	folder:Destroy()
end

function Ragdoll.stop(character)
	local humanoid = State.humanoid(character)
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	State.get(character).RagdollUntil = 0
	clear(character)
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		Net.Ragdoll:FireClient(player, false)
	else
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
	State.refresh(character)
end

function Ragdoll.start(character, duration)
	local humanoid = State.humanoid(character)
	if not humanoid then
		return
	end
	local st = State.get(character)
	local already = character:FindFirstChild("RagdollRig") ~= nil
	st.RagdollUntil = math.max(st.RagdollUntil, State.now() + duration)
	st.Blocking = false
	State.interrupt(character)
	if already then
		return
	end
	if not build(character) then
		return
	end
	humanoid.PlatformStand = true
	humanoid.AutoRotate = false
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		Net.Ragdoll:FireClient(player, true)
	end
	State.refresh(character)
	task.spawn(function()
		while character.Parent and humanoid.Health > 0 and State.now() < st.RagdollUntil do
			task.wait(0.05)
		end
		if character.Parent then
			Ragdoll.stop(character)
		end
	end)
end

return Ragdoll
