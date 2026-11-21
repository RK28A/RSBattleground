local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local Characters = require(ReplicatedStorage.Shared.Characters)
local State = require(script.Parent.State)
local Combat = require(script.Parent.Combat)
local Hitbox = require(script.Parent.Hitbox)
local Ragdoll = require(script.Parent.Ragdoll)
local Destruction = require(script.Parent.Destruction)
local Projectile = require(script.Parent.Projectile)

local FLAT = Vector3.new(1, 0, 1)

local Skills = {}

local function handlerFor(def, name)
	local folder = script:FindFirstChild(def.Id)
	local module = folder and folder:FindFirstChild(name)
	if module and module:IsA("ModuleScript") then
		return require(module)
	end
	return nil
end

function Skills.syncCooldowns(player)
	local character = player.Character
	if not character then
		return
	end
	local st = State.get(character)
	local prefix = player:GetAttribute("UltMode") and "U" or "S"
	for index = 1, 4 do
		player:SetAttribute("CD" .. index, st.Cooldowns[prefix .. index] or 0)
	end
end

local function sanitizeAim(root, aim)
	local look = root.CFrame.LookVector
	if typeof(aim) ~= "Vector3" or aim.Magnitude < 0.5 or aim ~= aim then
		return look
	end
	aim = aim.Unit
	local flat = aim * FLAT
	if flat.Magnitude < 0.2 then
		return look
	end
	local pitch = math.clamp(aim.Y, -0.5, 0.5)
	return (flat.Unit * math.sqrt(1 - pitch * pitch) + Vector3.new(0, pitch, 0)).Unit
end

local function context(player, character, def, skill, key, index, aim)
	local st = State.get(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	local ctx = {
		Player = player,
		Character = character,
		Root = root,
		Humanoid = State.humanoid(character),
		Definition = def,
		Skill = skill,
		Key = key,
		Index = index,
		Aim = root and sanitizeAim(root, aim) or Vector3.zAxis,
		StateData = st,
		State = State,
		Combat = Combat,
		Hitbox = Hitbox,
		Ragdoll = Ragdoll,
		Destruction = Destruction,
		Projectile = Projectile,
		Net = Net,
		Config = Config,
		Skills = Skills,
	}

	function ctx.StartCooldown(duration)
		local ends = State.now() + (duration or skill.Cooldown)
		st.Cooldowns[key] = ends
		local prefix = player:GetAttribute("UltMode") and "U" or "S"
		if string.sub(key, 1, 1) == prefix then
			player:SetAttribute("CD" .. index, ends)
		end
	end

	function ctx.Begin(duration, speed)
		State.busy(character, duration, speed)
		ctx.Token = st.Token
	end

	function ctx.Valid()
		return State.alive(character) and st.Token == ctx.Token and root.Parent ~= nil
	end

	function ctx.Wait(seconds)
		task.wait(seconds)
		return ctx.Valid()
	end

	function ctx.Fx(kind, data)
		data = data or {}
		data.Character = character
		Net.Fx:FireAllClients(kind, data)
	end

	ctx.Token = st.Token
	return ctx
end

local function ready(character)
	local st = State.get(character)
	local now = State.now()
	return State.canAct(character) and not st.Blocking and not st.Charging and now >= st.AttackUntil and now >= st.BusyUntil
end

local function release(character, aim, interrupted)
	local st = State.get(character)
	local charge = st.Charging
	if not charge then
		return
	end
	st.Charging = nil
	local ctx = charge.Context
	if aim and ctx.Root then
		ctx.Aim = sanitizeAim(ctx.Root, aim)
	end
	ctx.StartCooldown()
	if interrupted or not State.alive(character) then
		State.busy(character, 0)
		if charge.Handler.Cancel then
			task.spawn(charge.Handler.Cancel, ctx)
		end
		return
	end
	task.spawn(charge.Handler.Release, ctx, State.now() - charge.Started)
end

local function useSkill(player, index, down, aim)
	if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > 4 then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local st = State.get(character)
	if down == false then
		if st.Charging and st.Charging.Index == index then
			release(character, aim, false)
		end
		return
	end

	local def = Characters.get(player:GetAttribute("Character"))
	local mode = player:GetAttribute("UltMode") == true
	local list = mode and def.Ult.Skills or def.Skills
	local skill = list and list[index]
	if not skill then
		return
	end
	local key = (mode and "U" or "S") .. index

	local again = st.Reactivate[key]
	if again then
		if State.canAct(character) then
			task.spawn(again)
		end
		return
	end
	if not ready(character) then
		return
	end
	if State.now() < (st.Cooldowns[key] or 0) then
		return
	end
	local handler = handlerFor(def, key)
	if not handler then
		return
	end

	local ctx = context(player, character, def, skill, key, index, aim)
	if type(handler) == "table" then
		local charge = { Index = index, Started = State.now(), Handler = handler, Context = ctx }
		st.Charging = charge
		State.busy(character, skill.MaxHold + 0.5, Config.BlockWalkSpeed)
		ctx.Token = st.Token
		task.spawn(handler.Press, ctx)
		task.delay(skill.MaxHold, function()
			if st.Charging == charge then
				release(character, nil, false)
			end
		end)
	else
		task.spawn(handler, ctx)
	end
end

local function useUlt(player, choice)
	local character = player.Character
	if not character or not ready(character) then
		return
	end
	if player:GetAttribute("UltMode") or (player:GetAttribute("Ult") or 0) < Config.Ult.Max then
		return
	end
	local def = Characters.get(player:GetAttribute("Character"))
	local handler = handlerFor(def, "Ult")
	if not handler then
		return
	end
	player:SetAttribute("Ult", 0)
	local ctx = context(player, character, def, def.Ult, "Ult", 0, nil)
	ctx.Choice = choice
	task.spawn(handler, ctx)
end

function Skills.start()
	Net.Skill.OnServerEvent:Connect(useSkill)
	Net.Ult.OnServerEvent:Connect(useUlt)
	State.onInterrupt(function(character)
		if State.get(character).Charging then
			release(character, nil, true)
		end
	end)
end

return Skills
