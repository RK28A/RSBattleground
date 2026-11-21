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

function Combat.addUlt(character, amount)
	local player = Players:GetPlayerFromCharacter(character)
	if not player or player:GetAttribute("UltMode") then
		return
	end
	local value = (player:GetAttribute("Ult") or 0) + amount
	player:SetAttribute("Ult", math.clamp(value, 0, Config.Ult.Max))
end

function Combat.damage(attacker, victim, params)
	if attacker == victim or not State.alive(victim) then
		return nil
	end
	local victimState = State.get(victim)
	if victimState.IFrameUntil > State.now() then
		return nil
	end
	local victimRoot, attackerRoot = rootOf(victim), rootOf(attacker)
	if not victimRoot or not attackerRoot then
		return nil
	end

	local offset = (attackerRoot.Position - victimRoot.Position) * FLAT
	local toAttacker = offset.Magnitude > 0.05 and offset.Unit or -victimRoot.CFrame.LookVector
	local stun = params.Stun or 0

	if victimState.Blocking then
		local facing = victimRoot.CFrame.LookVector:Dot(toAttacker) > Config.Block.FrontDot
		if facing and not params.GuardBreak then
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

	State.humanoid(victim):TakeDamage(params.Damage or 0)
	if stun > 0 then
		State.stun(victim, stun)
	end
	if params.Knockback then
		Combat.push(victim, params.Knockback, 0.18)
	end
	if params.Ragdoll then
		Ragdoll.start(victim, params.Ragdoll)
	elseif State.alive(victim) then
		Combat.playAnim(victim, math.random() < 0.5 and "Hurt1" or "Hurt2")
	end

	Net.Fx:FireAllClients("Hit", {
		Attacker = attacker,
		Victim = victim,
		Position = victimRoot.Position,
		Heavy = params.Heavy == true,
	})
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
	if st.Blocking or now < st.AttackUntil - 0.05 or now < st.ComboLockUntil - 0.05 then
		return
	end
	if now - st.LastM1 > M1.ComboReset then
		st.Combo = 0
	end
	st.Combo += 1
	st.LastM1 = now
	st.AttackUntil = now + M1.Interval

	local def = Characters.get(player:GetAttribute("Character"))
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
	Net.fireExcept(Net.Fx, player, "Swing", { Character = character, Heavy = variant ~= "Normal" })
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
		for _, victim in victims do
			local params = { Damage = def.M1Damage, Stun = M1.Stun, Knockback = look * 6 }
			if variant == "Finisher" then
				params.Damage = def.FinisherDamage
				params.Knockback = look * M1.FinisherKnockback + Vector3.new(0, M1.FinisherLift, 0)
				params.Ragdoll = M1.FinisherRagdoll
				params.Heavy = true
			elseif variant == "Uppercut" then
				params.Damage = def.FinisherDamage
				params.Knockback = Vector3.new(0, M1.UppercutLift, 0)
				params.Ragdoll = M1.UppercutRagdoll
				params.Heavy = true
			elseif variant == "Downslam" then
				params.Damage = def.FinisherDamage
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
		if st.Blocking or not State.canAct(character) or State.now() < st.AttackUntil then
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
	if st.Blocking then
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
