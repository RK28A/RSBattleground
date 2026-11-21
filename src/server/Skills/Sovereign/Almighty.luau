local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logic = require(ReplicatedStorage.Shared.Logic.Almighty)

local FLAT = Vector3.new(1, 0, 1)
local rng = Random.new()

local Almighty = {}

local function rootOf(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function clearAttributes(player)
	if player.Parent then
		player:SetAttribute("UltMode", false)
		player:SetAttribute("UltPhase", "")
		player:SetAttribute("UltEvasion", false)
		player:SetAttribute("UltRebirth", false)
		player:SetAttribute("UltStart", 0)
		player:SetAttribute("UltEnd", 0)
		player:SetAttribute("Ult", 0)
	end
end

function Almighty.finish(ctx, machine, dead)
	local st = ctx.StateData
	if st.Almighty ~= machine then
		return
	end
	st.Almighty = nil
	st.Intercept = nil
	st.OnLethal = nil
	if st.Counter and st.Counter.Almighty then
		st.Counter = nil
	end
	for _, cleanup in st.UltCleanup or {} do
		task.spawn(cleanup)
	end
	st.UltCleanup = nil
	for key in st.Reactivate do
		if string.sub(key, 1, 1) == "U" then
			st.Reactivate[key] = nil
		end
	end
	if dead then
		Logic.kill(machine)
	else
		Logic.finish(machine)
	end
	clearAttributes(ctx.Player)
	ctx.Skills.syncCooldowns(ctx.Player)
	ctx.Fx("AlmightyEnd")
end

local function fateReversal(ctx, attacker)
	local config = ctx.Definition.Ult
	local character, root, st = ctx.Character, ctx.Root, ctx.StateData
	local Combat, State = ctx.Combat, ctx.State

	st.IFrameUntil = math.max(st.IFrameUntil, State.now() + config.CounterTime)
	State.lock(character, config.CounterTime)
	ctx.Fx("FateReversal", { Target = attacker, Duration = config.CounterTime })

	local targetRoot = rootOf(attacker)
	local reachable = targetRoot ~= nil
		and State.alive(attacker)
		and (targetRoot.Position - root.Position).Magnitude <= config.CounterReach
	if reachable then
		State.lock(attacker, config.CounterStrikeAt + 0.1)
		local position = targetRoot.Position
		local right = targetRoot.CFrame.RightVector
		local spot = Combat.safeSpot({ position + right * 3.2, position - right * 3.2 }, position, nil)
		if spot then
			character:PivotTo(CFrame.lookAt(spot, Vector3.new(position.X, spot.Y, position.Z)))
		end
	end
	Combat.playAnim(character, "FateCounter")
	task.wait(config.CounterStrikeAt)

	if not reachable or not State.alive(character) or not State.alive(attacker) or not targetRoot.Parent then
		return
	end
	local offset = (targetRoot.Position - root.Position) * FLAT
	if offset.Magnitude > 10 then
		return
	end
	local direction = offset.Magnitude > 0.1 and offset.Unit or root.CFrame.LookVector
	Combat.damage(character, attacker, {
		Damage = config.CounterDamage,
		Knockback = Combat.knock(direction, config.CounterKnockback) + Vector3.new(0, 14, 0),
		KnockTime = 0.2,
		Ragdoll = config.CounterRagdoll,
		IsCounter = true,
		GuardBreak = true,
		Heavy = true,
	})
end

local function intercept(ctx, machine, attacker, params)
	if params.Unavoidable then
		return nil
	end
	local outcome, fresh = Logic.resolve(machine, ctx.State.now(), params.AttackId, function()
		return rng:NextNumber()
	end)
	if outcome == "Evade" then
		if fresh then
			ctx.Fx("Evade", { Duration = ctx.Definition.Ult.EvasionTime })
		end
		return "Evaded"
	elseif outcome == "Counter" then
		if fresh then
			task.spawn(fateReversal, ctx, attacker)
		end
		return "Countered"
	end
	return nil
end

local function resurrect(ctx, machine, attacker)
	local config = ctx.Definition.Ult
	local timing = config.Resurrection
	local character, root, st, player = ctx.Character, ctx.Root, ctx.StateData, ctx.Player
	local Combat, State, Ragdoll = ctx.Combat, ctx.State, ctx.Ragdoll
	local humanoid = ctx.Humanoid
	local total = timing.Death + timing.Rewrite + timing.Reappear + timing.Panic + timing.Recover

	local function present()
		return character.Parent ~= nil and root.Parent ~= nil and humanoid.Health > 0
	end

	local function killerValid()
		local killerRoot = rootOf(attacker)
		return attacker ~= nil
			and attacker.Parent ~= nil
			and killerRoot ~= nil
			and State.alive(attacker)
			and (killerRoot.Position - root.Position).Magnitude < 400
	end

	local finished = false
	local function finish()
		if finished then
			return
		end
		finished = true
		if root.Parent then
			root.Anchored = false
		end
		st.CinematicUntil = 0
		Almighty.finish(ctx, machine, not present())
		if character.Parent then
			State.refresh(character)
		end
	end
	task.delay(total + 1.5, finish)

	State.cinematic(character, total + 0.5)
	st.StunUntil = 0
	st.Blocking = false
	st.Charging = nil
	Ragdoll.stop(character)
	humanoid.Health = 1
	player:SetAttribute("UltPhase", "Rebirth")
	player:SetAttribute("UltRebirth", false)

	local deathPosition = root.Position
	root.AssemblyLinearVelocity = Vector3.zero
	root.Anchored = true
	ctx.Fx("ResDeath", {
		Killer = attacker,
		Position = deathPosition,
		Death = timing.Death,
		Rewrite = timing.Rewrite,
	})

	task.wait(timing.Death + timing.Rewrite)
	if not present() then
		finish()
		return
	end

	local withKiller = killerValid()
	local destination
	if withKiller then
		local killerRoot = rootOf(attacker)
		local spot = Combat.safeSpot(Combat.around(killerRoot, timing.Behind), killerRoot.Position, nil)
		if spot then
			local target = killerRoot.Position
			destination = CFrame.lookAt(spot, Vector3.new(target.X, spot.Y, target.Z))
		else
			withKiller = false
		end
	end
	if not destination then
		local spot = Combat.safeSpot({}, nil, deathPosition)
		destination = spot and CFrame.new(spot) or root.CFrame
	end

	root.Anchored = false
	character:PivotTo(destination)
	root.AssemblyLinearVelocity = Vector3.zero
	humanoid.Health = timing.Health
	ctx.Fx("ResAppear", { Position = destination.Position, Duration = timing.Reappear })
	if withKiller then
		State.lock(attacker, timing.Reappear + timing.PushAt + timing.PushTime + 0.2)
	end

	task.wait(timing.Reappear)
	if not present() then
		finish()
		return
	end

	if withKiller and killerValid() then
		local killerRoot = rootOf(attacker)
		local away = (killerRoot.Position - root.Position) * FLAT
		away = away.Magnitude > 0.1 and away.Unit or root.CFrame.LookVector
		Combat.face(character, killerRoot.Position)
		Combat.face(attacker, root.Position)
		Combat.playAnim(character, "ResPush")
		Combat.playAnim(attacker, "Panic")
		ctx.Fx("ResPush", { Killer = attacker })
		task.wait(timing.PushAt)
		if killerValid() then
			Combat.push(attacker, away * timing.PushSpeed, timing.PushTime)
			task.wait(timing.PushTime)
			if killerValid() then
				Ragdoll.start(attacker, timing.Fall)
				Combat.push(attacker, away * 10 + Vector3.new(0, 6, 0), 0.15)
			end
			task.wait(math.max(timing.Panic - timing.PushAt - timing.PushTime, 0))
		else
			task.wait(math.max(timing.Panic - timing.PushAt, 0))
		end
	else
		Combat.playAnim(character, "ResPush")
		task.wait(timing.Panic * 0.5)
	end

	task.wait(timing.Recover)
	finish()
end

local function lethal(ctx, machine, attacker)
	if not Logic.beginResurrection(machine, ctx.State.now()) then
		return false
	end
	task.spawn(resurrect, ctx, machine, attacker)
	return true
end

local function timeline(ctx, machine)
	local player, character, st = ctx.Player, ctx.Character, ctx.StateData
	local humanoid = ctx.Humanoid
	local config = ctx.Definition.Ult
	local last = machine.State
	local evasion = false
	while st.Almighty == machine do
		if not character.Parent or humanoid.Health <= 0 then
			Almighty.finish(ctx, machine, true)
			return
		end
		local now = ctx.State.now()
		local state = Logic.update(machine, now)
		if state ~= last then
			last = state
			if state == Logic.States.Almighty then
				player:SetAttribute("UltPhase", "Almighty")
			elseif state == Logic.States.AlmightyMastered then
				player:SetAttribute("UltPhase", "Mastered")
				player:SetAttribute("UltRebirth", true)
				ctx.Fx("Mastered", { Remaining = config.Duration - config.MasteredStart })
			elseif state == Logic.States.Normal then
				Almighty.finish(ctx, machine, false)
				return
			end
		end
		if not evasion and Logic.evasionActive(machine, now) then
			evasion = true
			player:SetAttribute("UltEvasion", true)
		end
		task.wait(0.1)
	end
end

function Almighty.activate(ctx)
	local config = ctx.Definition.Ult
	local player, character, st = ctx.Player, ctx.Character, ctx.StateData
	if st.Almighty then
		return
	end
	local now = ctx.State.now()
	local machine = Logic.new(config)
	Logic.activate(machine, now)
	st.Almighty = machine
	st.UltCleanup = {}
	for index = 1, 4 do
		st.Cooldowns["U" .. index] = 0
	end

	player:SetAttribute("UltStart", now)
	player:SetAttribute("UltEnd", now + config.Duration)
	player:SetAttribute("UltPhase", "Startup")
	player:SetAttribute("UltEvasion", false)
	player:SetAttribute("UltRebirth", false)
	player:SetAttribute("UltMode", true)
	ctx.Skills.syncCooldowns(player)

	ctx.State.lock(character, config.Startup)
	ctx.Combat.playAnim(character, "AlmightyStart")
	ctx.Fx("AlmightyStart", { Duration = config.Startup, Total = config.Duration })

	st.Intercept = function(attacker, params)
		return intercept(ctx, machine, attacker, params)
	end
	st.OnLethal = function(attacker)
		return lethal(ctx, machine, attacker)
	end
	task.spawn(timeline, ctx, machine)
end

return Almighty
