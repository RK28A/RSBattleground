local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local Characters = require(ReplicatedStorage.Shared.Characters)
local State = require(script.Parent.State)
local Combat = require(script.Parent.Combat)
local Hitbox = require(script.Parent.Hitbox)
local Ragdoll = require(script.Parent.Ragdoll)
local Destruction = require(script.Parent.Destruction)

local Skills = {}

local function handlerFor(def, name)
	local folder = script:FindFirstChild(def.Id)
	local module = folder and folder:FindFirstChild(name)
	if module and module:IsA("ModuleScript") then
		return require(module)
	end
	return nil
end

local function context(player, character, def)
	return {
		Player = player,
		Character = character,
		Root = character:FindFirstChild("HumanoidRootPart"),
		Definition = def,
		State = State,
		Combat = Combat,
		Hitbox = Hitbox,
		Ragdoll = Ragdoll,
		Destruction = Destruction,
		Net = Net,
		Config = Config,
	}
end

local function ready(character)
	local st = State.get(character)
	return State.canAct(character) and not st.Blocking and State.now() >= st.AttackUntil
end

local function useSkill(player, index)
	if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > 4 then
		return
	end
	local character = player.Character
	if not character or not ready(character) then
		return
	end
	local def = Characters.get(player:GetAttribute("Character"))
	local mode = player:GetAttribute("UltMode") == true
	local list = mode and def.Ult.Skills or def.Skills
	local skill = list and list[index]
	if not skill then
		return
	end
	local st = State.get(character)
	local key = (mode and "U" or "S") .. index
	local now = State.now()
	if now < (st.Cooldowns[key] or 0) then
		return
	end
	local handler = handlerFor(def, key)
	if not handler then
		return
	end
	st.Cooldowns[key] = now + skill.Cooldown
	player:SetAttribute("CD" .. index, now + skill.Cooldown)
	task.spawn(handler, context(player, character, def))
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
	local ctx = context(player, character, def)
	ctx.Choice = choice
	task.spawn(handler, ctx)
end

function Skills.start()
	Net.Skill.OnServerEvent:Connect(useSkill)
	Net.Ult.OnServerEvent:Connect(useUlt)
end

return Skills
