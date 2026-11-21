local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local Characters = require(ReplicatedStorage.Shared.Characters)
local State = require(script.Parent.State)
local Hitbox = require(script.Parent.Hitbox)
local Ragdoll = require(script.Parent.Ragdoll)
local Destruction = require(script.Parent.Destruction)

local M1 = Config.M1
local FLAT = Vector3.new(1, 0, 1)

local Combat = {}

local function rootOf(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

function Combat.playAnim(character, name, except)
	Net.fireExcept(Net.Anim, except, character, name, true)
end

function Combat.stopAnim(character, name)
	Net.Anim:FireAllClients(character, name, false)
end

function Combat.push(character, velocity, duration)
	local root = rootOf(character)
	if not root then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "Push"
	local force = Instance.new("LinearVelocity")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.MaxForce = 1e6
	force.VectorVelocity = velocity
	force.Parent = attachment
	attachment.Parent = root
	Debris:AddItem(attachment, duration or 0.18)
end

function Combat.brake(character, duration)
	local root = rootOf(character)
	if not root then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "Brake"
	local force = Instance.new("LinearVelocity")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	force.PrimaryTangentAxis = Vector3.xAxis
	force.SecondaryTangentAxis = Vector3.zAxis
	force.PlaneVelocity = Vector2.zero
	force.MaxForce = 1e6
	force.Parent = attachment
	attachment.Parent = root
	Debris:AddItem(attachment, duration)
end

function Combat.addUlt(character, amount)
	local player = Players:GetPlayerFromCharacter(character)
	if not player or player:GetAttribute("UltMode") then
		return
	end
	local value = (player:GetAttribute("Ult") or 0) + amount
	player:SetAttribute("Ult", math.clamp(value, 0, Config.Ult.Max))
end

local attackCounter = 0

function Combat.attackId()
	attackCounter += 1
	return attackCounter
end

function Combat.knock(direction, studs)
	return direction * (studs / 0.2)
end

local damageListeners = {}

function Combat.onDamaged(listener)
	damageListeners[listener] = true
	return function()
		damageListeners[listener] = nil
	end
end

function Combat.characters()
	local list = {}
	for _, child in workspace:GetChildren() do
		if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
			table.insert(list, child)
		end
	end
	return list
end

function Combat.worldParams(extra)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = Combat.characters()
	for _, instance in extra or {} do
		table.insert(ignore, instance)
	end
	params.FilterDescendantsInstances = ignore
	params.CollisionGroup = "Players"
	return params
end

function Combat.lineOfSight(from, to)
	local offset = to - from
	if offset.Magnitude < 0.1 then
		return true
	end
	return workspace:Raycast(from, offset, Combat.worldParams()) == nil
end

function Combat.standable(position)
	local ground = workspace:Raycast(position + Vector3.new(0, 3, 0), Vector3.new(0, -14, 0), Combat.worldParams())
	if not ground then
		return nil
	end
	local stand = ground.Position + Vector3.new(0, 3, 0)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = Combat.characters()
	overlap.CollisionGroup = "Players"
	for _, part in workspace:GetPartBoundsInBox(CFrame.new(stand + Vector3.new(0, 0.4, 0)), Vector3.new(2.4, 4.4, 2), overlap) do
		if part.CanCollide then
			return nil
		end
	end
	return stand
end

function Combat.safeSpot(candidates, sightFrom, fallback)
	for _, position in candidates do
		local stand = Combat.standable(position)
		if stand and (not sightFrom or Combat.lineOfSight(sightFrom, stand)) then
			return stand
		end
	end
	if fallback then
		for _, offset in { Vector3.zero, Vector3.new(4, 0, 0), Vector3.new(-4, 0, 0), Vector3.new(0, 0, 4), Vector3.new(0, 0, -4) } do
			local stand = Combat.standable(fallback + offset)
			if stand then
				return stand
			end
		end
	end
	return nil
end

function Combat.around(targetRoot, distance)
	local cframe = targetRoot.CFrame
	local position = cframe.Position
	local back, right = -cframe.LookVector, cframe.RightVector
	return {
		position + back * distance,
		position + (back + right).Unit * distance,
		position + (back - right).Unit * distance,
		position + right * distance,
		position - right * distance,
		position - back * distance,
	}
end

function Combat.face(character, position)
	local root = rootOf(character)
	if not root then
		return
	end
	local flat = Vector3.new(position.X, root.Position.Y, position.Z)
	if (flat - root.Position).Magnitude > 0.1 then
		character:PivotTo(CFrame.lookAt(root.Position, flat))
	end
end

function Combat.damage(attacker, victim, params)
	if attacker == victim or not State.alive(victim) then
		return nil
	end
	local victimState = State.get(victim)
	local now = State.now()
	local victimRoot, attackerRoot = rootOf(victim), rootOf(attacker)
	if not victimRoot or not attackerRoot then
		return nil
	end
	if State.invulnerable(victim) then
		return "Immune"
	end
	params.AttackId = params.AttackId or Combat.attackId()

	if not params.Direct and not params.IsCounter then
		local counter = victimState.Counter
		if counter and not params.Uncounterable then
			if counter.Until > now then
				victimState.Counter = nil
				task.spawn(counter.Trigger, attacker, params)
				return "Countered"
			end
			victimState.Counter = nil
		end
		if victimState.Intercept then
			local outcome = victimState.Intercept(attacker, params)
			if outcome then
				return outcome
			end
		end
	end

	local offset = (attackerRoot.Position - victimRoot.Position) * FLAT
	local toAttacker = offset.Magnitude > 0.05 and offset.Unit or -victimRoot.CFrame.LookVector
	local stun = params.Stun or 0

	if victimState.Blocking and not params.Direct then
		local facing = victimRoot.CFrame.LookVector:Dot(toAttacker) > Config.Block.FrontDot
		local breaks = params.GuardBreak or params.Unblockable
		if facing and not breaks then
			Combat.push(victim, -toAttacker * Config.Block.Pushback, 0.12)
			Net.Fx:FireAllClients("Block", {
				Attacker = attacker,
				Victim = victim,
				Position = victimRoot.Position + toAttacker * 1.5,
			})
			return "Blocked"
		end
		victimState.Blocking = false
		Combat.stopAnim(victim, "Block")
		if params.GuardBreak then
			stun = math.max(stun, Config.Block.GuardBreakStun)
		end
	end

	local humanoid = State.humanoid(victim)
	local amount = math.min(params.Damage or 0, humanoid.Health)
	if amount >= humanoid.Health and amount > 0 and victimState.OnLethal then
		if victimState.OnLethal(attacker, params) then
			return "Resurrected"
		end
	end

	victimState.LastAttacker = attacker
	if amount > 0 then
		humanoid.Health -= amount
		for listener in damageListeners do
			task.spawn(listener, victim, attacker, amount)
		end
	end
	if stun > 0 then
		State.stun(victim, stun)
	end
	if params.Knockback then
		Combat.push(victim, params.Knockback, params.KnockTime or 0.18)
		if params.KnockTime then
			task.delay(params.KnockTime, Combat.brake, victim, 0.2)
		end
	end
	if params.Ragdoll then
		Ragdoll.start(victim, params.Ragdoll)
	elseif State.alive(victim) and not params.Silent then
		Combat.playAnim(victim, math.random() < 0.5 and "Hurt1" or "Hurt2")
	end

	if not params.Silent then
		Net.Fx:FireAllClients("Hit", {
			Attacker = attacker,
			Victim = victim,
			Position = victimRoot.Position,
			Heavy = params.Heavy == true,
		})
	end
	Combat.addUlt(attacker, Config.Ult.PerHitDealt)
	Combat.addUlt(victim, Config.Ult.PerHitTaken)
	State.refresh(victim)
	return "Hit"
end

local function swing(player, hint)
	local character = player.Character
	if not character or not State.canAct(character) then
		return
	end
	local st = State.get(character)
	local now = State.now()
	if st.Blocking or st.Charging or now < st.BusyUntil or now < st.AttackUntil - 0.05 or now < st.ComboLockUntil - 0.05 then
		return
	end
	if now - st.LastM1 > M1.ComboReset then
		st.Combo = 0
	end
	st.Combo += 1
	st.LastM1 = now
	st.AttackUntil = now + M1.Interval

	local def = Characters.get(player:GetAttribute("Character"))
	local index = st.Combo
	local perHit = type(def.M1Damage) == "table"
	local baseDamage = perHit and def.M1Damage[index] or def.M1Damage
	local finisherDamage = perHit and def.M1Damage[4] or def.FinisherDamage
	local variant = "Normal"
	local clip = def.M1Set .. st.Combo
	if st.Combo >= 4 then
		st.Combo = 0
		st.ComboLockUntil = now + M1.ComboCooldown
		if hint == "Down" then
			variant, clip = "Downslam", "Downslam"
		elseif hint == "Up" then
			variant, clip = "Uppercut", "Uppercut"
		else
			variant = "Finisher"
		end
	end
	character:SetAttribute("Combo", st.Combo)

	st.Token += 1
	local token = st.Token
	Combat.playAnim(character, clip, player)
	Net.fireExcept(Net.Fx, player, "Swing", { Character = character, Heavy = variant ~= "Normal", Clip = clip })
	State.refresh(character)
	State.schedule(character, M1.Interval)

	task.delay(M1.Windup, function()
		if st.Token ~= token or not State.canAct(character) then
			return
		end
		local root = rootOf(character)
		if not root then
			return
		end
		local look = root.CFrame.LookVector
		local victims = Hitbox.box(character, root.CFrame * CFrame.new(0, 0, -M1.Offset), M1.Size)
		local attackId = Combat.attackId()
		for _, victim in victims do
			local params = { Damage = baseDamage, Stun = M1.Stun, Knockback = look * 6, AttackId = attackId }
			if variant == "Finisher" then
				params.Damage = finisherDamage
				params.Knockback = look * M1.FinisherKnockback + Vector3.new(0, M1.FinisherLift, 0)
				params.Ragdoll = M1.FinisherRagdoll
				params.Heavy = true
			elseif variant == "Uppercut" then
				params.Damage = finisherDamage
				params.Knockback = Vector3.new(0, M1.UppercutLift, 0)
				params.Ragdoll = M1.UppercutRagdoll
				params.Heavy = true
			elseif variant == "Downslam" then
				params.Damage = finisherDamage
				params.Knockback = Vector3.new(0, -M1.DownslamForce, 0)
				params.Ragdoll = M1.DownslamRagdoll
				params.Heavy = true
			end
			local result = Combat.damage(character, victim, params)
			if result == "Hit" and variant == "Downslam" then
				local victimRoot = rootOf(victim)
				task.delay(0.15, function()
					if victimRoot and victimRoot.Parent then
						Destruction.blast(victimRoot.Position - Vector3.new(0, 3, 0), M1.DownslamCrater, 36)
					end
				end)
			end
		end
	end)
end

local function block(player, on)
	local character = player.Character
	if not character then
		return
	end
	local st = State.get(character)
	if on == true then
		if st.Blocking or st.Charging or not State.canAct(character) or State.now() < st.AttackUntil or State.now() < st.BusyUntil then
			return
		end
		st.Blocking = true
		Combat.playAnim(character, "Block", player)
	else
		if not st.Blocking then
			return
		end
		st.Blocking = false
		Combat.stopAnim(character, "Block")
	end
	State.refresh(character)
end

local function dash(player, direction)
	if type(direction) ~= "string" then
		return
	end
	local cooldown = Config.Dash.Cooldown[direction]
	local character = player.Character
	if not cooldown or not character or not State.canAct(character) then
		return
	end
	local st = State.get(character)
	if st.Blocking or st.Charging or State.now() < st.BusyUntil then
		return
	end
	local key = (direction == "Left" or direction == "Right") and "DashSide" or "DashFront"
	local now = State.now()
	if now < (st.Cooldowns[key] or 0) - 0.2 then
		return
	end
	st.Cooldowns[key] = now + cooldown
	Combat.playAnim(character, "Dash" .. direction, player)
	Net.fireExcept(Net.Fx, player, "Dash", { Character = character })
end

function Combat.start()
	Net.M1.OnServerEvent:Connect(swing)
	Net.Block.OnServerEvent:Connect(block)
	Net.Dash.OnServerEvent:Connect(dash)
end

return Combat
