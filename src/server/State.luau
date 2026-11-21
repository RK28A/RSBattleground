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
			LockUntil = 0,
			BusyUntil = 0,
			CinematicUntil = 0,
			ComboLockUntil = 0,
			LastM1 = 0,
			Combo = 0,
			Token = 0,
			Blocking = false,
			Cooldowns = {},
			Reactivate = {},
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

function State.locked(character)
	local st = State.get(character)
	local now = State.now()
	return st.LockUntil > now or st.CinematicUntil > now
end

function State.invulnerable(character)
	local st = State.get(character)
	local now = State.now()
	return st.IFrameUntil > now or st.CinematicUntil > now
end

function State.canAct(character)
	return State.alive(character)
		and not State.stunned(character)
		and not State.ragdolled(character)
		and not State.locked(character)
end

local interruptHandlers = {}

function State.onInterrupt(handler)
	table.insert(interruptHandlers, handler)
end

function State.interrupt(character)
	State.get(character).Token += 1
	for _, handler in interruptHandlers do
		task.spawn(handler, character)
	end
end

function State.lock(character, duration)
	local st = State.get(character)
	st.LockUntil = math.max(st.LockUntil, State.now() + duration)
	State.refresh(character)
	State.schedule(character, duration)
end

function State.busy(character, duration, speed)
	local st = State.get(character)
	st.BusyUntil = State.now() + duration
	st.BusySpeed = speed
	State.refresh(character)
	if duration > 0 then
		State.schedule(character, duration)
	end
end

function State.cinematic(character, duration)
	local st = State.get(character)
	st.CinematicUntil = State.now() + duration
	State.refresh(character)
	if duration > 0 then
		State.schedule(character, duration)
	end
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
	local locked = st.LockUntil > now or st.CinematicUntil > now
	local speed, jump = Config.WalkSpeed, Config.JumpPower
	if stunned or ragdolled or locked then
		speed, jump = 0, 0
	elseif st.Blocking then
		speed, jump = Config.BlockWalkSpeed, 0
	elseif st.BusyUntil > now then
		speed, jump = st.BusySpeed or Config.AttackWalkSpeed, 0
	elseif st.AttackUntil > now then
		speed = Config.AttackWalkSpeed
	end
	humanoid.WalkSpeed = speed
	humanoid.JumpPower = jump
	character:SetAttribute("Stunned", stunned or locked or st.BusyUntil > now)
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
	State.interrupt(character)
	State.refresh(character)
	State.schedule(character, duration)
end

return State
