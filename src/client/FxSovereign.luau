local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Anim = require(Shared:WaitForChild("Anim"))
local Fx = require(script.Parent:WaitForChild("Fx"))

local U = Fx.Util
local folder, random, WHITE = U.Folder, U.Random, U.White
local neon, tween, burst, flash, streaks, holder, sound = U.neon, U.tween, U.burst, U.flash, U.streaks, U.holder, U.sound

local PALE = Color3.fromRGB(190, 225, 255)
local SPIRIT = Color3.fromRGB(110, 175, 255)
local VIOLET = Color3.fromRGB(150, 70, 255)
local DEEP = Color3.fromRGB(48, 16, 96)
local BLACK = Color3.fromRGB(8, 6, 14)
local BODY = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local player = Players.LocalPlayer
local active = setmetatable({}, { __mode = "k" })
local hidden = setmetatable({}, { __mode = "k" })
local bigArrows = {}

local function isLocal(character)
	return character ~= nil and character == player.Character
end

local function track(character, name, cleanup)
	local set = active[character]
	if not set then
		set = {}
		active[character] = set
		character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				for key, fn in set do
					set[key] = nil
					task.spawn(fn)
				end
			end
		end)
	end
	if set[name] then
		task.spawn(set[name])
	end
	set[name] = cleanup
end

local function clear(character, name)
	local set = active[character]
	if set and set[name] then
		local fn = set[name]
		set[name] = nil
		task.spawn(fn)
	end
end

local function clearAll(character)
	local set = active[character]
	if not set then
		return
	end
	for key, fn in set do
		set[key] = nil
		task.spawn(fn)
	end
end

local function rootOf(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function screen(tint, brightness, saturation, inTime, outTime)
	local effect = Instance.new("ColorCorrectionEffect")
	effect.Parent = Lighting
	tween(effect, inTime, { TintColor = tint, Brightness = brightness, Saturation = saturation }, Enum.EasingStyle.Quad)
	task.delay(inTime, function()
		tween(effect, outTime, { TintColor = WHITE, Brightness = 0, Saturation = 0 }, Enum.EasingStyle.Quad)
	end)
	Debris:AddItem(effect, inTime + outTime + 0.1)
end

local function distort(strength, duration)
	local camera = workspace.CurrentCamera
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting
	local base = camera.FieldOfView
	tween(blur, duration * 0.4, { Size = strength }, Enum.EasingStyle.Quad)
	tween(camera, duration * 0.4, { FieldOfView = base - strength * 0.8 }, Enum.EasingStyle.Quad)
	task.delay(duration * 0.4, function()
		tween(blur, duration * 0.6, { Size = 0 }, Enum.EasingStyle.Quad)
		tween(camera, duration * 0.6, { FieldOfView = 70 }, Enum.EasingStyle.Quad)
	end)
	Debris:AddItem(blur, duration + 0.1)
end

local function eye(adornee, offset, size, life, color)
	color = color or VIOLET
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(size, size * 0.5)
	gui.LightInfluence = 0
	gui.Brightness = 2
	gui.MaxDistance = 220
	gui.StudsOffsetWorldSpace = offset
	gui.Adornee = adornee

	local outer = Instance.new("Frame")
	outer.AnchorPoint = Vector2.new(0.5, 0.5)
	outer.Position = UDim2.fromScale(0.5, 0.5)
	outer.Size = UDim2.fromScale(0.92, 0.88)
	outer.BackgroundColor3 = BLACK
	outer.BorderSizePixel = 0
	outer.Rotation = random:NextNumber(-22, 22)
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0.5, 0)
	round.Parent = outer
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = outer
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = outer

	local iris = Instance.new("Frame")
	iris.AnchorPoint = Vector2.new(0.5, 0.5)
	iris.Position = UDim2.fromScale(0.5, 0.5)
	iris.Size = UDim2.fromScale(0.42, 0.84)
	iris.BackgroundColor3 = color
	iris.BorderSizePixel = 0
	local irisRound = Instance.new("UICorner")
	irisRound.CornerRadius = UDim.new(0.5, 0)
	irisRound.Parent = iris
	iris.Parent = outer

	local pupil = Instance.new("Frame")
	pupil.AnchorPoint = Vector2.new(0.5, 0.5)
	pupil.Position = UDim2.fromScale(0.5, 0.5)
	pupil.Size = UDim2.fromScale(0.2, 0.8)
	pupil.BackgroundColor3 = BLACK
	pupil.BorderSizePixel = 0
	local pupilRound = Instance.new("UICorner")
	pupilRound.CornerRadius = UDim.new(0.5, 0)
	pupilRound.Parent = pupil
	pupil.Parent = iris

	outer.Parent = gui
	gui.Parent = folder
	TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 }):Play()
		Debris:AddItem(gui, 0.25)
	end
	if life then
		task.delay(life, close)
	end
	return close
end

local function eyes(adornee, count, radius, height, life, color)
	local closers = {}
	local start = random:NextNumber(0, math.pi * 2)
	for index = 1, count do
		local angle = start + (index / count) * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * radius, height + random:NextNumber(-1, 1.4), math.sin(angle) * radius)
		local size = random:NextNumber(1.5, 2.6)
		task.delay(random:NextNumber(0, 0.18), function()
			table.insert(closers, eye(adornee, offset, size, life, color))
		end)
	end
	return function()
		for _, close in closers do
			close()
		end
	end
end

local function anchorAt(position, life)
	return holder(position, life)
end

local function smoke(position, count, size, color, life)
	burst(position, count, {
		Texture = U.Smoke,
		LightEmission = 0,
		Color = ColorSequence.new(color or BLACK, DEEP),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size * 0.5), NumberSequenceKeypoint.new(1, size * 1.5) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new((life or 0.8) * 0.6, life or 0.8),
		Speed = NumberRange.new(3, 11),
		Drag = 3,
	})
end

local function ring(position, color, from, to, duration)
	local part = neon(Vector3.new(0.3, from, from), CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2), color, Enum.PartType.Cylinder)
	part.Material = Enum.Material.ForceField
	tween(part, duration, { Size = Vector3.new(0.12, to, to), Transparency = 1 })
	Debris:AddItem(part, duration + 0.05)
end

local function shards(position, count, color, reach, duration)
	for _ = 1, count do
		local direction = random:NextUnitVector()
		local size = Vector3.new(random:NextNumber(0.5, 1.5), random:NextNumber(0.7, 2.2), 0.06)
		local start = CFrame.lookAt(position + direction * 1.2, position + direction * 3) * CFrame.Angles(0, 0, random:NextNumber(0, 6.28))
		local shard = neon(size, start, color)
		shard.Material = Enum.Material.Glass
		shard.Transparency = 0.25
		shard.Reflectance = 0.4
		tween(shard, duration, {
			CFrame = (start + direction * reach * random:NextNumber(0.5, 1.2)) * CFrame.Angles(random:NextNumber(-3, 3), random:NextNumber(-3, 3), 0),
			Transparency = 1,
		}, Enum.EasingStyle.Quart)
		Debris:AddItem(shard, duration + 0.05)
	end
end

local function setVisible(character, visible, duration)
	local store = hidden[character]
	if not visible then
		if not store then
			store = {}
			hidden[character] = store
			for _, item in character:GetDescendants() do
				if (item:IsA("BasePart") or item:IsA("Decal")) and item.Transparency < 1 then
					store[item] = item.Transparency
				end
			end
		end
		for item in store do
			if item.Parent then
				tween(item, duration or 0.1, { Transparency = 1 }, Enum.EasingStyle.Quad)
			end
		end
	elseif store then
		hidden[character] = nil
		for item, original in store do
			if item.Parent then
				tween(item, duration or 0.3, { Transparency = original }, Enum.EasingStyle.Quad)
			end
		end
	end
end

local function ghost(character, color, transparency, life, offset)
	local parts = {}
	for _, name in BODY do
		local source = character:FindFirstChild(name)
		if source then
			local copy = neon(source.Size, offset and (source.CFrame + offset) or source.CFrame, color)
			copy.Transparency = transparency
			table.insert(parts, copy)
		end
	end
	local function fade(duration)
		for _, part in parts do
			tween(part, duration, { Transparency = 1 }, Enum.EasingStyle.Quad)
			Debris:AddItem(part, duration + 0.05)
		end
	end
	if life then
		task.delay(0, function()
			fade(life)
		end)
	end
	return fade, parts
end

local function follow(character, name, build)
	local parts, update = build()
	local connection = RunService.RenderStepped:Connect(update)
	update()
	track(character, name, function()
		connection:Disconnect()
		for _, part in parts do
			tween(part, 0.15, { Transparency = 1 }, Enum.EasingStyle.Quad)
			Debris:AddItem(part, 0.2)
		end
	end)
end

local function bow(character, big)
	local arm = character:FindFirstChild("Left Arm")
	if not arm then
		return
	end
	follow(character, "Bow", function()
		local parts, offsets = {}, {}
		local scale = big and 1.9 or 1
		local segments = big and 11 or 7
		local half = (segments - 1) / 2
		for index = 1, segments do
			local t = (index - 1 - half) / half
			local size = Vector3.new(0.16, 0.16, 0.72) * scale
			local part = neon(size, arm.CFrame, index % 2 == 0 and WHITE or PALE)
			part.Transparency = 1
			tween(part, 0.2, { Transparency = 0.05 }, Enum.EasingStyle.Quad)
			table.insert(parts, part)
			table.insert(offsets, CFrame.new(0, (-1.35 + 0.55 * t * t) * (big and 1.2 or 1), t * 2.1 * scale) * CFrame.Angles(math.rad(-34 * t), 0, 0))
		end
		local string = neon(Vector3.new(0.05, 0.05, 4.2 * scale), arm.CFrame, WHITE)
		string.Transparency = 0.4
		table.insert(parts, string)
		table.insert(offsets, CFrame.new(0, -0.8 * (big and 1.2 or 1), 0))
		return parts, function()
			if not arm.Parent then
				return
			end
			for index, part in parts do
				part.CFrame = arm.CFrame * offsets[index]
			end
		end
	end)
end

local function aura(character, dense)
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, -2.6, 0)
	attachment.Parent = torso

	local dark = Instance.new("ParticleEmitter")
	dark.Texture = U.Smoke
	dark.LightEmission = 0
	dark.Color = ColorSequence.new(BLACK, DEEP)
	dark.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.6), NumberSequenceKeypoint.new(1, 3.4) })
	dark.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, dense and 0.25 or 0.5), NumberSequenceKeypoint.new(1, 1) })
	dark.Lifetime = NumberRange.new(0.9, 1.5)
	dark.Rate = dense and 34 or 16
	dark.Speed = NumberRange.new(4, 8)
	dark.SpreadAngle = Vector2.new(24, 24)
	dark.Rotation = NumberRange.new(0, 360)
	dark.RotSpeed = NumberRange.new(-40, 40)
	dark.Acceleration = Vector3.new(0, 5, 0)
	dark.LockedToPart = false
	dark.Parent = attachment

	local glow = Instance.new("ParticleEmitter")
	glow.Texture = U.Spark
	glow.LightEmission = 1
	glow.Color = ColorSequence.new(VIOLET, DEEP)
	glow.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
	glow.Lifetime = NumberRange.new(0.5, 1)
	glow.Rate = dense and 26 or 10
	glow.Speed = NumberRange.new(5, 11)
	glow.SpreadAngle = Vector2.new(50, 50)
	glow.Parent = attachment

	local light = Instance.new("PointLight")
	light.Color = VIOLET
	light.Brightness = dense and 2.4 or 1.2
	light.Range = dense and 16 or 10
	light.Parent = torso

	track(character, "Aura", function()
		dark.Enabled = false
		glow.Enabled = false
		Debris:AddItem(attachment, 1.6)
		light:Destroy()
	end)
end

local function arrow(origin, direction, distance, speed, charged)
	local length = charged and 6.5 or 4
	local width = charged and 0.5 or 0.22
	local part = neon(Vector3.new(width, width, length), CFrame.lookAt(origin, origin + direction), WHITE)
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, width * 1.6, 0)
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -width * 1.6, 0)
	a1.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.22
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(WHITE, SPIRIT)
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.Parent = part

	local duration = math.max(distance / speed, 0.03)
	local goal = CFrame.lookAt(origin + direction * distance, origin + direction * (distance + 1))
	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = goal }):Play()
	task.delay(duration, function()
		part.Transparency = 1
		flash(goal.Position, PALE, charged and 4.5 or 2, 0.2)
		if charged then
			streaks(goal.Position, 10, PALE, 3, 9, 0.28)
		end
	end)
	Debris:AddItem(part, duration + 0.3)
end

function Fx.BowDraw(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	bow(character, data.Big)
	local color = data.Big and WHITE or PALE
	flash(root.Position + root.CFrame.LookVector * 2, color, data.Big and 3 or 1.6, 0.25)
	if data.Big then
		local position = root.Position - Vector3.new(0, 2.8, 0)
		ring(position, PALE, 2, 16, 0.6)
		local charge = Instance.new("Attachment")
		charge.Position = Vector3.new(0, 0, -2.5)
		charge.Parent = root
		local emitter = Instance.new("ParticleEmitter")
		emitter.Texture = U.Spark
		emitter.LightEmission = 1
		emitter.Color = ColorSequence.new(WHITE, SPIRIT)
		emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.9) })
		emitter.Lifetime = NumberRange.new(0.3, 0.5)
		emitter.Rate = 60
		emitter.Speed = NumberRange.new(-14, -8)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Parent = charge
		track(character, "BowCharge", function()
			emitter.Enabled = false
			Debris:AddItem(charge, 0.6)
		end)
	end
end

function Fx.BowCancel(data)
	clear(data.Character, "Bow")
	clear(data.Character, "BowCharge")
end

function Fx.Arrows(data)
	local character = data.Character
	clear(character, "Bow")
	clear(character, "BowCharge")
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, folder }
	for _, direction in data.Directions do
		local hit = workspace:Raycast(data.Origin, direction * data.Range, params)
		local distance = hit and hit.Distance or data.Range
		arrow(data.Origin, direction, distance, data.Speed, data.Charged)
	end
	flash(data.Origin, PALE, data.Charged and 3.4 or 2.2, 0.18)
	if isLocal(character) then
		Fx.shake(data.Charged and 1.2 or 0.6)
	end
	sound(Config.Sounds.Arrow, data.Origin, 0.7)
end

function Fx.BigArrow(data)
	local character = data.Character
	clear(character, "Bow")
	clear(character, "BowCharge")
	local direction = data.Direction
	local part = neon(Vector3.new(1.1, 1.1, 12), CFrame.lookAt(data.Origin, data.Origin + direction), WHITE)
	local halo = neon(Vector3.new(2.6, 2.6, 9), part.CFrame, SPIRIT)
	halo.Material = Enum.Material.ForceField
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 1.8, 0)
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -1.8, 0)
	a1.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.45
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(WHITE, SPIRIT)
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Parent = part

	flash(data.Origin, WHITE, 7, 0.3)
	ring(data.Origin, PALE, 2, 20, 0.4)
	if isLocal(character) then
		Fx.shake(2.4)
	end
	sound(Config.Sounds.BigArrow, data.Origin, 1)

	local travelled, lastRing = 0, 0
	local entry = { Done = false }
	bigArrows[data.Id] = entry
	local connection
	local function stop(position)
		if entry.Done then
			return
		end
		entry.Done = true
		bigArrows[data.Id] = nil
		connection:Disconnect()
		part.Transparency = 1
		halo:Destroy()
		Debris:AddItem(part, 0.6)
		flash(position, WHITE, 9, 0.35)
		ring(position, PALE, 3, 30, 0.45)
		streaks(position, 16, PALE, 4, 14, 0.35)
		local mine = rootOf(player.Character)
		if mine and (mine.Position - position).Magnitude < 60 then
			Fx.shake(2)
		end
	end
	entry.Stop = stop
	connection = RunService.Heartbeat:Connect(function(dt)
		travelled += data.Speed * dt
		local position = data.Origin + direction * math.min(travelled, data.Range)
		part.CFrame = CFrame.lookAt(position, position + direction)
		halo.CFrame = part.CFrame
		if travelled - lastRing > 16 then
			lastRing = travelled
			local wave = neon(Vector3.new(0.2, 3, 3), part.CFrame * CFrame.Angles(0, math.pi / 2, 0), PALE, Enum.PartType.Cylinder)
			wave.Material = Enum.Material.ForceField
			tween(wave, 0.35, { Size = Vector3.new(0.1, 13, 13), Transparency = 1 })
			Debris:AddItem(wave, 0.4)
		end
		if travelled >= data.Range + data.Speed * 0.25 then
			stop(position)
		end
	end)
end

function Fx.BigArrowEnd(data)
	local entry = bigArrows[data.Id]
	if entry then
		entry.Stop(data.Position)
	end
end

function Fx.Judgment(data)
	local character = data.Character
	local arm = character and character:FindFirstChild("Right Arm")
	if not arm then
		return
	end
	local created = {}
	for index, color in { BLACK, SPIRIT } do
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, -1, 0)
		a0.Parent = arm
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, index == 1 and -5.2 or -4.4, 0)
		a1.Parent = arm
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = index == 1 and 0.3 or 0.2
		trail.LightEmission = index == 1 and 0 or 1
		trail.FaceCamera = true
		trail.Color = ColorSequence.new(color, index == 1 and DEEP or WHITE)
		trail.Transparency = NumberSequence.new(index == 1 and 0.1 or 0.2, 1)
		trail.Parent = arm
		table.insert(created, a0)
		table.insert(created, a1)
		table.insert(created, trail)
	end
	local root = rootOf(character)
	if root then
		smoke(root.Position - Vector3.new(0, 2.5, 0), 8, 2, BLACK, 0.5)
	end
	task.delay(data.Duration, function()
		for _, instance in created do
			if instance:IsA("Trail") then
				instance.Enabled = false
			end
			Debris:AddItem(instance, 0.4)
		end
	end)
end

function Fx.BlutVene(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	flash(root.Position, SPIRIT, 3.4, 0.25)
	local glow = Instance.new("Highlight")
	glow.FillColor = SPIRIT
	glow.FillTransparency = 0.72
	glow.OutlineColor = SPIRIT
	glow.OutlineTransparency = 0
	glow.DepthMode = Enum.HighlightDepthMode.Occluded
	glow.Adornee = character
	glow.Parent = folder
	local pulse = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { FillTransparency = 0.45 })
	pulse:Play()

	local veins = {}
	for _, name in BODY do
		local limb = character:FindFirstChild(name)
		if limb then
			for _ = 1, 2 do
				local attachment = Instance.new("Attachment")
				attachment.Position = Vector3.new(random:NextNumber(-0.4, 0.4), limb.Size.Y / 2, limb.Size.Z / 2 + 0.03)
				attachment.Parent = limb
				local other = Instance.new("Attachment")
				other.Position = Vector3.new(random:NextNumber(-0.4, 0.4), -limb.Size.Y / 2, limb.Size.Z / 2 + 0.03)
				other.Parent = limb
				local beam = Instance.new("Beam")
				beam.Attachment0 = attachment
				beam.Attachment1 = other
				beam.Width0 = 0.09
				beam.Width1 = 0.05
				beam.FaceCamera = true
				beam.LightEmission = 1
				beam.Color = ColorSequence.new(SPIRIT, WHITE)
				beam.CurveSize0 = random:NextNumber(-0.5, 0.5)
				beam.CurveSize1 = random:NextNumber(-0.5, 0.5)
				beam.Segments = 6
				beam.Parent = limb
				table.insert(veins, attachment)
				table.insert(veins, other)
				table.insert(veins, beam)
			end
		end
	end

	track(character, "Blut", function()
		pulse:Cancel()
		tween(glow, 0.2, { FillTransparency = 1, OutlineTransparency = 1 }, Enum.EasingStyle.Quad)
		Debris:AddItem(glow, 0.25)
		for _, instance in veins do
			instance:Destroy()
		end
	end)
	task.delay(data.Duration + 0.1, function()
		clear(character, "Blut")
	end)
end

function Fx.BlutEnd(data)
	clear(data.Character, "Blut")
end

function Fx.BlutCounter(data)
	local character = data.Character
	clear(character, "Blut")
	local root = rootOf(character)
	if not root then
		return
	end
	flash(root.Position, WHITE, 6, 0.3)
	ring(root.Position - Vector3.new(0, 2.6, 0), SPIRIT, 2, 22, 0.4)
	streaks(root.Position, 14, SPIRIT, 3, 10, 0.3)
	if U.involves(character, data.Target) then
		Fx.shake(2)
		screen(SPIRIT, 0.12, -0.2, 0.06, 0.3)
	end
	sound(Config.Sounds.Counter, root.Position)
end

function Fx.AlmightyStart(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	aura(character, false)
	local ground = root.Position - Vector3.new(0, 2.8, 0)
	local part = anchorAt(ground, data.Duration + 2)
	part.Size = Vector3.new(11, 0.2, 11)
	local rising = Instance.new("ParticleEmitter")
	rising.Texture = U.Smoke
	rising.LightEmission = 0
	rising.Color = ColorSequence.new(BLACK, DEEP)
	rising.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.6) })
	rising.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	rising.Lifetime = NumberRange.new(0.8, 1.4)
	rising.Rate = 70
	rising.Speed = NumberRange.new(8, 16)
	rising.SpreadAngle = Vector2.new(6, 6)
	rising.EmissionDirection = Enum.NormalId.Top
	rising.Parent = part
	task.delay(data.Duration, function()
		rising.Enabled = false
	end)

	ring(ground, VIOLET, 2, 26, 0.7)
	eyes(root, 6, 4.5, 2.5, data.Duration + 0.6)
	task.delay(data.Duration * 0.8, function()
		if root.Parent then
			flash(root.Position, VIOLET, 9, 0.45)
			ring(root.Position - Vector3.new(0, 2.8, 0), VIOLET, 3, 40, 0.6)
			streaks(root.Position, 18, VIOLET, 4, 14, 0.4)
			local head = character:FindFirstChild("Head")
			if head then
				flash(head.Position + root.CFrame.LookVector * 0.6, WHITE, 1.4, 0.5)
			end
		end
	end)
	if isLocal(character) then
		distort(10, data.Duration)
		screen(Color3.fromRGB(190, 150, 255), -0.06, -0.5, data.Duration * 0.7, 0.6)
		Fx.shake(1.2)
	end
	sound(Config.Sounds.AlmightyStart, root.Position, 1)
end

function Fx.Mastered(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	aura(character, true)
	local close = eyes(root, 9, 5.4, 4.2, nil)
	local orbit = eyes(root, 4, 2.8, 1.4, nil, Color3.fromRGB(220, 170, 255))
	track(character, "MasteredEyes", function()
		close()
		orbit()
	end)
	flash(root.Position, VIOLET, 12, 0.5)
	ring(root.Position - Vector3.new(0, 2.8, 0), VIOLET, 4, 54, 0.7)
	local mine = rootOf(player.Character)
	if mine and (mine.Position - root.Position).Magnitude < 90 then
		screen(VIOLET, 0.25, -0.3, 0.08, 0.6)
		Fx.shake(isLocal(character) and 2.2 or 1)
	end
	sound(Config.Sounds.Mastered, root.Position, 1)
end

function Fx.AlmightyEnd(data)
	local character = data.Character
	if not character then
		return
	end
	clearAll(character)
	setVisible(character, true, 0.2)
	local root = rootOf(character)
	if root then
		smoke(root.Position, 10, 2.4, BLACK, 0.7)
	end
end

function Fx.Evade(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	local duration = data.Duration or 0.45
	Anim.play(character, "EvadeLean")
	ghost(character, VIOLET, 0.35, duration)
	eyes(root, 4, 3.2, 1.6, duration)
	smoke(root.Position, 6, 2, BLACK, 0.5)
	local store = {}
	for _, item in character:GetDescendants() do
		if (item:IsA("BasePart") or item:IsA("Decal")) and item.Transparency < 0.6 and not hidden[character] then
			store[item] = item.Transparency
			tween(item, 0.08, { Transparency = 0.72 }, Enum.EasingStyle.Quad)
		end
	end
	task.delay(duration * 0.7, function()
		for item, original in store do
			if item.Parent and not hidden[character] then
				tween(item, duration * 0.3, { Transparency = original }, Enum.EasingStyle.Quad)
			end
		end
	end)
	if isLocal(character) then
		screen(Color3.fromRGB(200, 170, 255), 0.05, -0.35, 0.05, 0.35)
	end
	sound(Config.Sounds.Evade, root.Position, 0.7)
end

function Fx.FateReversal(data)
	local character, target = data.Character, data.Target
	local root, targetRoot = rootOf(character), rootOf(target)
	if not root then
		return
	end
	smoke(root.Position, 10, 2.6, BLACK, 0.7)
	ghost(character, BLACK, 0.3, 0.4)
	if targetRoot then
		eyes(targetRoot, 5, 3.4, 2, data.Duration)
		flash(targetRoot.Position, VIOLET, 5, 0.3)
		flash(targetRoot.Position, BLACK, 3, 0.4)
		task.delay(0.08, function()
			if root.Parent then
				smoke(root.Position, 10, 2.6, BLACK, 0.7)
			end
		end)
	end
	if U.involves(character, target) then
		screen(VIOLET, -0.08, -0.5, 0.06, 0.5)
		Fx.shake(1.4)
	end
	sound(Config.Sounds.Counter, root.Position)
end

function Fx.ResDeath(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	clear(character, "Aura")
	clear(character, "MasteredEyes")
	flash(data.Position, WHITE, 7, 0.3)
	streaks(data.Position, 16, VIOLET, 4, 12, 0.35)

	local pieces = {}
	local focus
	for _, name in BODY do
		local source = character:FindFirstChild(name)
		if source then
			local piece = Instance.new("Part")
			piece.Size = source.Size
			piece.CFrame = source.CFrame
			piece.Color = source.Color
			piece.Material = Enum.Material.SmoothPlastic
			piece.CanQuery = false
			piece.CanTouch = false
			piece.CollisionGroup = "Debris"
			piece.Parent = folder
			local away = (source.Position - data.Position)
			away = away.Magnitude > 0.05 and away.Unit or random:NextUnitVector()
			piece.AssemblyLinearVelocity = away * random:NextNumber(10, 20) + Vector3.new(0, random:NextNumber(12, 22), 0)
			piece.AssemblyAngularVelocity = random:NextUnitVector() * 12
			table.insert(pieces, piece)
			if name == "Torso" then
				focus = piece
			end
		end
	end
	setVisible(character, false, 0.05)

	local camera = workspace.CurrentCamera
	if isLocal(character) and focus then
		camera.CameraSubject = focus
		screen(Color3.fromRGB(255, 200, 200), -0.1, -0.7, 0.1, data.Death)
		Fx.shake(2.4)
	end

	task.delay(data.Death, function()
		for _, piece in pieces do
			smoke(piece.Position, 5, 2.2, BLACK, 0.8)
			eye(piece, Vector3.new(random:NextNumber(-1.5, 1.5), random:NextNumber(1, 2.6), random:NextNumber(-1.5, 1.5)), random:NextNumber(1.4, 2.2), data.Rewrite * 0.9)
			tween(piece, data.Rewrite * 0.8, { Transparency = 1, Size = piece.Size * 0.4 }, Enum.EasingStyle.Quad)
			Debris:AddItem(piece, data.Rewrite + 0.1)
		end
		if isLocal(character) then
			distort(14, data.Rewrite)
			screen(VIOLET, -0.05, -0.6, data.Rewrite * 0.5, data.Rewrite * 0.5)
		end
	end)
	track(character, "ResCamera", function()
		if isLocal(character) then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				camera.CameraSubject = humanoid
			end
		end
		for _, piece in pieces do
			piece:Destroy()
		end
	end)
	sound(Config.Sounds.Rebirth, data.Position, 1)
end

function Fx.ResAppear(data)
	local character = data.Character
	clear(character, "ResCamera")
	smoke(data.Position, 26, 4.2, BLACK, 1.1)
	smoke(data.Position + Vector3.new(0, 2, 0), 14, 3, DEEP, 0.9)
	local root = rootOf(character)
	if root then
		eyes(root, 6, 3.6, 2, data.Duration + 1.4)
	end
	task.delay(0.15, function()
		setVisible(character, true, data.Duration * 0.6)
	end)
	flash(data.Position, VIOLET, 6, 0.4)
	if isLocal(character) then
		screen(VIOLET, 0.1, -0.2, 0.08, 0.5)
	end
end

function Fx.ResPush(data)
	local character, killer = data.Character, data.Killer
	local killerRoot = rootOf(killer)
	task.delay(0.55, function()
		if killerRoot and killerRoot.Parent then
			flash(killerRoot.Position, WHITE, 3, 0.2)
			streaks(killerRoot.Position, 8, VIOLET, 2.4, 7, 0.25)
			if U.involves(character, killer) then
				Fx.shake(1.6)
			end
		end
	end)
end

function Fx.FutureSight(data)
	local character = data.Character
	local head = character and character:FindFirstChild("Head")
	if not head then
		return
	end
	local close = eyes(head, 3, 2.2, 1.6, nil, Color3.fromRGB(200, 160, 255))
	flash(head.Position, VIOLET, 2.4, 0.25)
	track(character, "Sight", close)
	task.delay(data.Duration + 0.1, function()
		clear(character, "Sight")
	end)
end

function Fx.FutureSightEnd(data)
	clear(data.Character, "Sight")
end

function Fx.FutureSightHit(data)
	local character = data.Character
	clear(character, "Sight")
	local root = rootOf(character)
	if not root then
		return
	end
	ghost(character, VIOLET, 0.3, 0.45)
	smoke(root.Position, 8, 2.4, BLACK, 0.6)
	local targetRoot = rootOf(data.Target)
	if targetRoot then
		eyes(targetRoot, 3, 3, 2, 0.6)
	end
	if U.involves(character, data.Target) then
		screen(VIOLET, 0.06, -0.3, 0.05, 0.35)
	end
end

function Fx.Auswahlen(data)
	local character = data.Character
	local root = rootOf(character)
	if not root then
		return
	end
	local ground = root.Position - Vector3.new(0, 2.8, 0)
	local pillar = neon(Vector3.new(120, 1.2, 1.2), CFrame.new(root.Position + Vector3.new(0, 56, 0)) * CFrame.Angles(0, 0, math.pi / 2), WHITE, Enum.PartType.Cylinder)
	pillar.Transparency = 0.2
	tween(pillar, data.PullTime, { Size = Vector3.new(120, 6, 6) }, Enum.EasingStyle.Quad)
	task.delay(data.PullTime, function()
		tween(pillar, 0.35, { Size = Vector3.new(120, 16, 16), Transparency = 1 })
		Debris:AddItem(pillar, 0.4)
	end)

	local edge = neon(Vector3.new(0.3, data.Radius * 2, data.Radius * 2), CFrame.new(ground) * CFrame.Angles(0, 0, math.pi / 2), VIOLET, Enum.PartType.Cylinder)
	edge.Material = Enum.Material.ForceField
	edge.Transparency = 0.3
	tween(edge, data.PullTime, { Size = Vector3.new(0.3, 3, 3) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	Debris:AddItem(edge, data.PullTime + 0.05)

	for index = 1, 10 do
		local angle = index / 10 * math.pi * 2 + random:NextNumber(-0.2, 0.2)
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local length = data.Radius * random:NextNumber(0.5, 0.95)
		local crack = neon(Vector3.new(0.5, 0.1, 0.4), CFrame.lookAt(ground + direction * 2, ground + direction * 4), index % 2 == 0 and BLACK or WHITE)
		tween(crack, data.PullTime, {
			Size = Vector3.new(random:NextNumber(0.3, 0.8), 0.1, length),
			CFrame = CFrame.lookAt(ground + direction * (2 + length / 2), ground + direction * (4 + length)),
		}, Enum.EasingStyle.Quart)
		task.delay(data.PullTime + 0.3, function()
			tween(crack, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad)
			Debris:AddItem(crack, 0.55)
		end)
	end

	local inward = anchorAt(ground + Vector3.new(0, 1.5, 0), data.PullTime + 1)
	inward.Size = Vector3.new(data.Radius * 2, 3, data.Radius * 2)
	for _, color in { BLACK, WHITE } do
		local emitter = Instance.new("ParticleEmitter")
		emitter.Texture = color == BLACK and U.Smoke or U.Spark
		emitter.LightEmission = color == BLACK and 0 or 1
		emitter.Color = ColorSequence.new(color)
		emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, color == BLACK and 1.6 or 0.6), NumberSequenceKeypoint.new(1, 0) })
		emitter.Lifetime = NumberRange.new(0.3, 0.5)
		emitter.Rate = 90
		emitter.Speed = NumberRange.new(data.Radius * 1.6, data.Radius * 2.2)
		emitter.Shape = Enum.ParticleEmitterShape.Cylinder
		emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward
		emitter.Parent = inward
		task.delay(data.PullTime, function()
			emitter.Enabled = false
		end)
	end
	if isLocal(character) then
		Fx.shake(0.8)
	end
end

function Fx.AuswahlenBlast(data)
	local position = data.Position
	local ground = position - Vector3.new(0, 2.8, 0)
	flash(position, WHITE, data.Radius * 0.9, 0.45)
	flash(position, BLACK, data.Radius * 0.5, 0.55)
	ring(ground, WHITE, 3, data.Radius * 2.4, 0.5)
	ring(ground + Vector3.new(0, 0.4, 0), VIOLET, 2, data.Radius * 1.8, 0.65)
	streaks(position, 22, WHITE, 5, data.Radius, 0.45)
	smoke(ground, 20, 4, BLACK, 1)
	local mine = rootOf(player.Character)
	if mine and (mine.Position - position).Magnitude < data.Radius * 3 then
		Fx.shake(2.6)
		screen(WHITE, 0.3, -0.2, 0.05, 0.4)
	end
	sound(Config.Sounds.Explosion, position, 1)
end

function Fx.DestinyMark(data)
	local character, target = data.Character, data.Target
	local targetRoot = rootOf(target)
	local closeEyes = targetRoot and eyes(targetRoot, 5, 3.2, 2.4, nil) or function() end
	local fade = ghost(character, VIOLET, 0.55, nil)
	local marker = neon(Vector3.new(0.2, 5, 5), CFrame.new(data.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.pi / 2), VIOLET, Enum.PartType.Cylinder)
	marker.Material = Enum.Material.ForceField
	if targetRoot then
		flash(targetRoot.Position, VIOLET, 3, 0.3)
	end
	track(character, "Destiny", function()
		closeEyes()
		fade(0.3)
		tween(marker, 0.3, { Transparency = 1 }, Enum.EasingStyle.Quad)
		Debris:AddItem(marker, 0.35)
	end)
	task.delay(data.Duration + 0.2, function()
		clear(character, "Destiny")
	end)
end

function Fx.DestinyEnd(data)
	clear(data.Character, "Destiny")
end

function Fx.DestinyReturn(data)
	local character = data.Character
	clear(character, "Destiny")
	shards(data.From, 14, PALE, 9, 0.5)
	shards(data.To, 18, PALE, 11, 0.55)
	flash(data.To, VIOLET, 6, 0.35)
	smoke(data.From, 8, 2.4, BLACK, 0.6)
	local targetRoot = rootOf(data.Target)
	if targetRoot and data.Bonus and data.Bonus > 0 then
		flash(targetRoot.Position, VIOLET, 5, 0.3)
		shards(targetRoot.Position, 10, VIOLET, 7, 0.4)
	end
	if U.involves(character, data.Target) then
		screen(VIOLET, 0.18, -0.4, 0.05, 0.45)
		Fx.shake(1.6)
	end
end

function Fx.FutureIsMine(data)
	local character, target = data.Character, data.Target
	local root, targetRoot = rootOf(character), rootOf(target)
	if not root or not targetRoot then
		return
	end
	local center = targetRoot.Position
	local involved = U.involves(character, target)
	local camera = workspace.CurrentCamera

	if involved then
		local middle = (root.Position + center) / 2
		local side = (center - root.Position):Cross(Vector3.yAxis)
		side = side.Magnitude > 0.1 and side.Unit or Vector3.xAxis
		camera.CameraType = Enum.CameraType.Scriptable
		local from = CFrame.lookAt(middle + side * 13 + Vector3.new(0, 3, 0), middle + Vector3.new(0, 0.5, 0))
		local to = CFrame.lookAt(middle + side * 8 + Vector3.new(0, 5, 0), center)
		camera.CFrame = from
		TweenService:Create(camera, TweenInfo.new(data.ImpactAt, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { CFrame = to, FieldOfView = 52 }):Play()
		task.delay(data.Duration, function()
			camera.CameraType = Enum.CameraType.Custom
			tween(camera, 0.3, { FieldOfView = 70 }, Enum.EasingStyle.Quad)
		end)
		screen(Color3.fromRGB(200, 180, 255), -0.08, -0.6, 0.3, data.Duration - 0.3)
	end

	eyes(targetRoot, 7, 5, 3, data.ImpactAt)
	local glass = {}
	for index = 1, 14 do
		local angle = index / 14 * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * 4.2, random:NextNumber(-2, 3), math.sin(angle) * 4.2)
		local shard = neon(Vector3.new(random:NextNumber(0.8, 1.6), random:NextNumber(1.2, 2.6), 0.06), CFrame.lookAt(center + offset, center) * CFrame.Angles(0, 0, random:NextNumber(0, 6.28)), PALE)
		shard.Material = Enum.Material.Glass
		shard.Transparency = 1
		shard.Reflectance = 0.5
		tween(shard, 0.4, { Transparency = 0.3 }, Enum.EasingStyle.Quad)
		table.insert(glass, shard)
	end

	local futures = {}
	local tints = { VIOLET, SPIRIT, WHITE, Color3.fromRGB(255, 120, 200) }
	for index, tint in tints do
		task.delay(0.25 + index * 0.16, function()
			if not root.Parent then
				return
			end
			local angle = index / #tints * math.pi * 2
			local position = center + Vector3.new(math.cos(angle) * 6.5, 0, math.sin(angle) * 6.5)
			local fade, parts = ghost(character, tint, 0.45, nil, position - root.Position)
			table.insert(futures, { Fade = fade, Parts = parts, Position = position })
			flash(position, tint, 2.4, 0.25)
		end)
	end

	task.delay(data.ImpactAt * 0.75, function()
		for index, future in futures do
			if index > 1 then
				future.Fade(0.2)
				shards(future.Position, 9, PALE, 6, 0.4)
			end
		end
		if involved then
			Fx.shake(1.2)
		end
	end)

	task.delay(data.ImpactAt, function()
		for _, future in futures do
			future.Fade(0.15)
		end
		for _, shard in glass do
			local away = (shard.Position - center)
			away = away.Magnitude > 0.1 and away.Unit or Vector3.yAxis
			tween(shard, 0.4, { CFrame = shard.CFrame + away * 14, Transparency = 1 }, Enum.EasingStyle.Quart)
			Debris:AddItem(shard, 0.45)
		end
	end)
	task.delay(data.Duration + 1, function()
		for _, shard in glass do
			shard:Destroy()
		end
	end)
end

function Fx.FinisherImpact(data)
	local position = data.Position
	local ground = position - Vector3.new(0, 2.8, 0)
	local beam = neon(Vector3.new(160, 9, 9), CFrame.new(position + Vector3.new(0, 78, 0)) * CFrame.Angles(0, 0, math.pi / 2), WHITE, Enum.PartType.Cylinder)
	tween(beam, 0.5, { Size = Vector3.new(160, 0.4, 0.4), Transparency = 1 })
	Debris:AddItem(beam, 0.55)
	local core = neon(Vector3.new(160, 4, 4), beam.CFrame, VIOLET, Enum.PartType.Cylinder)
	tween(core, 0.7, { Size = Vector3.new(160, 14, 14), Transparency = 1 })
	Debris:AddItem(core, 0.75)
	flash(position, WHITE, 16, 0.5)
	flash(position, VIOLET, 10, 0.7)
	ring(ground, WHITE, 4, 60, 0.6)
	ring(ground + Vector3.new(0, 0.5, 0), VIOLET, 3, 42, 0.8)
	streaks(position, 28, VIOLET, 6, 22, 0.5)
	shards(position, 20, PALE, 16, 0.6)
	smoke(ground, 26, 5, BLACK, 1.3)
	local mine = rootOf(player.Character)
	if mine and (mine.Position - position).Magnitude < 90 then
		Fx.shake(3.4)
		screen(WHITE, 0.4, -0.3, 0.04, 0.5)
	end
	sound(Config.Sounds.Explosion, position, 1)
end

return true
