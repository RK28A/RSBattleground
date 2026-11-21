local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local State = {}
local data = setmetatable({}, { __mode = "k" })

function State.now()
	return workspace:GetServerTimeNow()
end

function State.get(character)
	local st = data[character]
	if not st then
		st = {
			StunUntil = 0,
			AttackUntil = 0,
			RagdollUntil = 0,
			IFrameUntil = 0,
			ComboLockUntil = 0,
			LastM1 = 0,
			Combo = 0,
			Token = 0,
			Blocking = false,
			Cooldowns = {},
		}
		data[character] = st
	end
	return st
end

function State.humanoid(character)
	return character and character:FindFirstChildOfClass("Humanoid")
end

function State.alive(character)
	local humanoid = State.humanoid(character)
	return humanoid ~= nil and humanoid.Health > 0 and character.Parent ~= nil
end

function State.stunned(character)
	return State.get(character).StunUntil > State.now()
end

function State.ragdolled(character)
	return State.get(character).RagdollUntil > State.now()
end

function State.canAct(character)
	return State.alive(character) and not State.stunned(character) and not State.ragdolled(character)
end

function State.refresh(character)
	local humanoid = State.humanoid(character)
	if not humanoid then
		return
	end
	local st = State.get(character)
	local now = State.now()
	local stunned = st.StunUntil > now
	local ragdolled = st.RagdollUntil > now
	local speed, jump = Config.WalkSpeed, Config.JumpPower
	if stunned or ragdolled then
		speed, jump = 0, 0
	elseif st.Blocking then
		speed, jump = Config.BlockWalkSpeed, 0
	elseif st.AttackUntil > now then
		speed = Config.AttackWalkSpeed
	end
	humanoid.WalkSpeed = speed
	humanoid.JumpPower = jump
	character:SetAttribute("Stunned", stunned)
	character:SetAttribute("Ragdolled", ragdolled)
	character:SetAttribute("Blocking", st.Blocking)
end

function State.schedule(character, delay)
	task.delay(delay + 0.03, function()
		if character.Parent then
			State.refresh(character)
		end
	end)
end

function State.stun(character, duration)
	local st = State.get(character)
	st.StunUntil = math.max(st.StunUntil, State.now() + duration)
	st.Token += 1
	State.refresh(character)
	State.schedule(character, duration)
end

return State
