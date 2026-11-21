local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Characters = require(Shared:WaitForChild("Characters"))
local Anim = require(Shared:WaitForChild("Anim"))

local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local WHITE = Color3.new(1, 1, 1)

local player = Players.LocalPlayer
local random = Random.new()

local folder = Instance.new("Folder")
folder.Name = "Fx"
folder.Parent = workspace

local Fx = {}
local shake = 0

RunService:BindToRenderStep("FxShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if shake < 0.02 then
		shake = 0
		return
	end
	local camera = workspace.CurrentCamera
	local amount = math.rad(shake)
	camera.CFrame *= CFrame.Angles(
		random:NextNumber(-amount, amount),
		random:NextNumber(-amount, amount),
		random:NextNumber(-amount, amount) * 0.5
	)
	shake *= math.exp(-dt * 13)
end)

function Fx.shake(amount)
	shake = math.max(shake, amount)
end

local function accentOf(character)
	local owner = character and Players:GetPlayerFromCharacter(character)
	if owner then
		return Characters.get(owner:GetAttribute("Character")).Accent
	end
	return WHITE
end

local function involves(...)
	local mine = player.Character
	for _, character in { ... } do
		if character == mine then
			return true
		end
	end
	return false
end

local function holder(position, life)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.CFrame = CFrame.new(position)
	part.Parent = folder
	Debris:AddItem(part, life)
	return part
end

local function neon(size, cframe, color, shape)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Shape = shape or Enum.PartType.Block
	part.Color = color
	part.Size = size
	part.CFrame = cframe
	part.Parent = folder
	return part
end

local function tween(instance, duration, goal, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	TweenService:Create(instance, info, goal):Play()
end

local function sound(id, position, volume)
	if not id or id == "" then
		return
	end
	local part = holder(position, 3)
	local instance = Instance.new("Sound")
	instance.SoundId = id
	instance.Volume = volume or 0.8
	instance.RollOffMaxDistance = 120
	instance.PlaybackSpeed = random:NextNumber(0.94, 1.06)
	instance.Parent = part
	instance:Play()
end

local function burst(position, count, properties)
	local part = holder(position, 1.5)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Texture = SPARK
	emitter.LightEmission = 1
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Rotation = NumberRange.new(0, 360)
	for key, value in properties do
		emitter[key] = value
	end
	emitter.Parent = attachment
	emitter:Emit(count)
end

local function flash(position, color, size, duration)
	local core = neon(Vector3.one * size * 0.35, CFrame.new(position), WHITE, Enum.PartType.Ball)
	tween(core, duration * 0.6, { Size = Vector3.one * size * 0.9, Transparency = 1 })
	Debris:AddItem(core, duration)
	local shell = neon(Vector3.one * size * 0.5, CFrame.new(position), color, Enum.PartType.Ball)
	shell.Material = Enum.Material.ForceField
	tween(shell, duration, { Size = Vector3.one * size * 2.2, Transparency = 1 })
	Debris:AddItem(shell, duration + 0.05)
end

local function streaks(position, count, color, length, reach, duration, bias)
	for _ = 1, count do
		local direction = random:NextUnitVector()
		if bias then
			direction = (direction + bias * 1.4).Unit
		end
		local size = Vector3.new(0.14, 0.14, length * random:NextNumber(0.6, 1.3))
		local start = CFrame.lookAt(position + direction * 0.8, position + direction * 2)
		local streak = neon(size, start, random:NextNumber() < 0.35 and WHITE or color)
		tween(streak, duration, {
			CFrame = start + direction * reach * random:NextNumber(0.6, 1.2),
			Size = Vector3.new(0.02, 0.02, size.Z * 0.3),
			Transparency = 1,
		}, Enum.EasingStyle.Quart)
		Debris:AddItem(streak, duration + 0.05)
	end
end

local function highlight(character, color, duration)
	local instance = Instance.new("Highlight")
	instance.FillColor = color
	instance.FillTransparency = 0.15
	instance.OutlineColor = WHITE
	instance.OutlineTransparency = 0.3
	instance.DepthMode = Enum.HighlightDepthMode.Occluded
	instance.Adornee = character
	instance.Parent = folder
	tween(instance, duration, { FillTransparency = 1, OutlineTransparency = 1 }, Enum.EasingStyle.Quad)
	Debris:AddItem(instance, duration + 0.05)
end

function Fx.Hit(data)
	local position = data.Position
	if not position then
		return
	end
	local color = accentOf(data.Attacker)
	local heavy = data.Heavy
	local bias
	local attackerRoot = data.Attacker and data.Attacker:FindFirstChild("HumanoidRootPart")
	if attackerRoot then
		local offset = position - attackerRoot.Position
		if offset.Magnitude > 0.1 then
			bias = offset.Unit
		end
	end

	flash(position, color, heavy and 5 or 2.6, heavy and 0.3 or 0.18)
	streaks(position, heavy and 14 or 7, color, heavy and 3.4 or 2, heavy and 11 or 6, heavy and 0.32 or 0.2, bias)
	burst(position, heavy and 26 or 12, {
		Color = ColorSequence.new(WHITE, color),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, heavy and 1.1 or 0.7), NumberSequenceKeypoint.new(1, 0) }),
		Lifetime = NumberRange.new(0.15, heavy and 0.45 or 0.28),
		Speed = NumberRange.new(heavy and 30 or 18, heavy and 60 or 34),
		Drag = 5,
	})
	if heavy then
		local ring = neon(Vector3.new(0.3, 2, 2), CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2), color, Enum.PartType.Cylinder)
		ring.Material = Enum.Material.ForceField
		tween(ring, 0.35, { Size = Vector3.new(0.1, 22, 22), Transparency = 1 })
		Debris:AddItem(ring, 0.4)
	end
	if data.Victim then
		highlight(data.Victim, heavy and color or WHITE, heavy and 0.3 or 0.16)
		Anim.freeze(data.Victim, heavy and 0.12 or 0.06)
	end
	if data.Attacker then
		Anim.freeze(data.Attacker, heavy and 0.1 or 0.05)
	end
	if involves(data.Attacker, data.Victim) then
		Fx.shake(heavy and 2.2 or 0.8)
	end
	sound(heavy and Config.Sounds.HeavyHit or Config.Sounds.Hit, position)
end

function Fx.Block(data)
	local position = data.Position
	if not position then
		return
	end
	local color = Color3.fromRGB(170, 215, 255)
	flash(position, color, 2, 0.15)
	streaks(position, 6, color, 1.6, 5, 0.18)
	burst(position, 10, {
		Color = ColorSequence.new(WHITE, color),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) }),
		Lifetime = NumberRange.new(0.1, 0.22),
		Speed = NumberRange.new(20, 40),
		Drag = 6,
	})
	if data.Attacker then
		Anim.freeze(data.Attacker, 0.05)
	end
	if involves(data.Attacker, data.Victim) then
		Fx.shake(0.5)
	end
	sound(Config.Sounds.Block, position)
end

function Fx.Swing(data)
	local character = data.Character
	local arm = character and character:FindFirstChild("Right Arm")
	if not arm then
		return
	end
	local color = accentOf(character)
	local reach = data.Heavy and 4.6 or 3.8
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, -1, 0)
	a0.Parent = arm
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -reach, 0)
	a1.Parent = arm
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = data.Heavy and 0.22 or 0.16
	trail.MinLength = 0
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(WHITE, color)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.6, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.WidthScale = NumberSequence.new(1, 0.2)
	trail.Parent = arm
	task.delay(0.24, function()
		trail.Enabled = false
	end)
	for _, instance in { a0, a1, trail } do
		Debris:AddItem(instance, 0.6)
	end
	sound(Config.Sounds.Swing, arm.Position, 0.5)
end

function Fx.Dash(data)
	local character = data.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torso = character and character:FindFirstChild("Torso")
	if not root or not torso then
		return
	end
	burst(root.Position - Vector3.new(0, 2.6, 0), 10, {
		Texture = SMOKE,
		LightEmission = 0.2,
		Color = ColorSequence.new(Color3.fromRGB(215, 215, 220)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 3.4) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new(0.3, 0.55),
		Speed = NumberRange.new(4, 10),
		SpreadAngle = Vector2.new(180, 30),
		Drag = 3,
	})
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 1, 0)
	a0.Parent = torso
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -1, 0)
	a1.Parent = torso
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.18
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(WHITE, accentOf(character))
	trail.Transparency = NumberSequence.new(0.55, 1)
	trail.Parent = torso
	task.delay(Config.Dash.Duration, function()
		trail.Enabled = false
	end)
	for _, instance in { a0, a1, trail } do
		Debris:AddItem(instance, 0.6)
	end
	sound(Config.Sounds.Dash, root.Position, 0.5)
end

function Fx.Shatter(data)
	local position = data.Position
	if not position then
		return
	end
	local radius = data.Radius or 6
	burst(position, 22, {
		Texture = SMOKE,
		LightEmission = 0,
		Color = ColorSequence.new(Color3.fromRGB(150, 145, 138)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, radius * 0.3), NumberSequenceKeypoint.new(1, radius * 0.9) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new(0.6, 1.3),
		Speed = NumberRange.new(6, 20),
		Drag = 2.5,
	})
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local distance = (root.Position - position).Magnitude
		if distance < radius * 6 then
			Fx.shake(2.4 * (1 - distance / (radius * 6)))
		end
	end
	sound(Config.Sounds.Shatter, position)
end

return Fx
