local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local FxBody = {}

local INK = Color3.fromRGB(6, 4, 12)
local WHITE = Color3.new(1, 1, 1)
local VEIN = Color3.fromRGB(110, 190, 255)
local VEIN_CORE = Color3.fromRGB(215, 240, 255)
local VIOLET = Color3.fromRGB(150, 70, 255)
local CRIMSON = Color3.fromRGB(255, 40, 90)

local TEX = {
	Core = "rbxasset://textures/particles/explosion01_core_main.dds",
	Wave = "rbxasset://textures/particles/explosion01_shockwave_main.dds",
	Implode = "rbxasset://textures/particles/explosion01_implosion_main.dds",
	Sparks = "rbxasset://textures/particles/fire_sparks_main.dds",
	Smoke = "rbxasset://textures/particles/explosion01_smoke_main.dds",
	Vortex = "rbxasset://textures/particles/forcefield_vortex_main.dds",
	Glow = "rbxasset://textures/particles/forcefield_glow_main.dds",
}
FxBody.Textures = TEX

local random = Random.new()
local folder
local veinSets = setmetatable({}, { __mode = "k" })
local faceSets = setmetatable({}, { __mode = "k" })

local function tween(instance, duration, goal, style, direction, repeats, reverses)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out, repeats or 0, reverses or false)
	local t = TweenService:Create(instance, info, goal)
	t:Play()
	return t
end

local function make(class, props, children)
	local instance = Instance.new(class)
	for key, value in props do
		instance[key] = value
	end
	for _, child in children or {} do
		child.Parent = instance
	end
	return instance
end

local function round(scale)
	return make("UICorner", { CornerRadius = UDim.new(scale or 0.5, 0) })
end

local function anchor(position, life)
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

local function emit(position, count, props)
	local part = anchor(position, (props.Life or 1) + 0.6)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.LightEmission = 1
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Speed = NumberRange.new(0)
	for key, value in props do
		if key ~= "Life" then
			emitter[key] = value
		end
	end
	emitter.Parent = attachment
	emitter:Emit(count)
	return emitter
end

local function seq(...)
	local points = { ... }
	local keys = {}
	for index = 1, #points, 2 do
		table.insert(keys, NumberSequenceKeypoint.new(points[index], points[index + 1]))
	end
	return NumberSequence.new(keys)
end

function FxBody.impact(position, color, size, duration)
	size = size or 3
	duration = duration or 0.25
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = size * 4
	light.Brightness = 6
	light.Parent = anchor(position, duration + 0.2)
	tween(light, duration, { Brightness = 0 })
	emit(position, 1, {
		Texture = TEX.Core,
		Color = ColorSequence.new(WHITE, color),
		Size = seq(0, size * 0.6, 0.25, size * 1.4, 1, size * 1.8),
		Transparency = seq(0, 0, 0.5, 0.35, 1, 1),
		Lifetime = NumberRange.new(duration * 0.9, duration),
		Life = duration,
	})
	emit(position, 1, {
		Texture = TEX.Wave,
		Color = ColorSequence.new(color),
		Size = seq(0, size * 0.4, 1, size * 3.2),
		Transparency = seq(0, 0.05, 0.6, 0.5, 1, 1),
		Lifetime = NumberRange.new(duration * 1.3),
		Life = duration * 1.3,
	})
	emit(position, math.floor(8 + size * 3), {
		Texture = TEX.Sparks,
		Color = ColorSequence.new(WHITE, color),
		Size = seq(0, size * 0.22, 1, 0),
		Lifetime = NumberRange.new(duration * 0.8, duration * 1.6),
		Speed = NumberRange.new(size * 8, size * 16),
		Drag = 6,
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Squash = seq(0, -1.5, 1, -0.5),
		Life = duration * 1.6,
	})
end

function FxBody.wave(position, color, from, to, duration, normal)
	local part = anchor(position, duration + 0.4)
	if normal then
		part.CFrame = CFrame.lookAt(position, position + normal)
	end
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Texture = TEX.Wave
	emitter.LightEmission = 1
	emitter.Color = ColorSequence.new(color)
	emitter.Size = seq(0, from, 1, to)
	emitter.Transparency = seq(0, 0, 0.7, 0.55, 1, 1)
	emitter.Lifetime = NumberRange.new(duration)
	emitter.Rotation = NumberRange.new(0, 360)
	if normal then
		emitter.EmissionDirection = Enum.NormalId.Front
		emitter.SpreadAngle = Vector2.zero
		emitter.Speed = NumberRange.new(0.01)
		emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
	else
		emitter.Speed = NumberRange.new(0)
	end
	emitter.Parent = attachment
	emitter:Emit(1)
end

function FxBody.implode(position, color, radius, duration)
	emit(position, 3, {
		Texture = TEX.Implode,
		Color = ColorSequence.new(color),
		Size = seq(0, radius * 2.4, 1, radius * 0.2),
		Transparency = seq(0, 1, 0.3, 0.2, 1, 0.6),
		Lifetime = NumberRange.new(duration),
		RotSpeed = NumberRange.new(-120, 120),
		Life = duration,
	})
end

local FACES = {
	Torso = { Enum.NormalId.Front, Enum.NormalId.Back },
	["Right Arm"] = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Right },
	["Left Arm"] = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left },
	["Right Leg"] = { Enum.NormalId.Front, Enum.NormalId.Back },
	["Left Leg"] = { Enum.NormalId.Front, Enum.NormalId.Back },
	Head = { Enum.NormalId.Front },
}

local ROOTS = {
	Torso = { { 0.5, 0.02, 90 }, { 0.12, 0.08, 60 }, { 0.88, 0.08, 120 } },
	["Right Arm"] = { { 0.5, 0.02, 90 } },
	["Left Arm"] = { { 0.5, 0.02, 90 } },
	["Right Leg"] = { { 0.5, 0.02, 90 } },
	["Left Leg"] = { { 0.5, 0.02, 90 } },
	Head = { { 0.18, 1, -70 }, { 0.82, 1, -110 } },
}

local PPS = 64

local function faceSize(part, face)
	local size = part.Size
	if face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return size.Z * PPS, size.Y * PPS
	end
	return size.X * PPS, size.Y * PPS
end

local function growVeins(canvas, width, height, roots, seed, budget)
	local rng = Random.new(seed)
	local segments = {}
	local stack = {}
	local base = math.min(width, height)
	for _, root in roots do
		table.insert(stack, { X = root[1] * width, Y = root[2] * height, A = math.rad(root[3] + rng:NextNumber(-12, 12)), T = base * 0.055, Depth = 0 })
	end
	while #stack > 0 and #segments < budget do
		local node = table.remove(stack, 1)
		local step = base * rng:NextNumber(0.07, 0.12)
		local angle = node.A + rng:NextNumber(-0.45, 0.45)
		local x2 = node.X + math.cos(angle) * step
		local y2 = node.Y + math.sin(angle) * step
		if x2 < -4 or x2 > width + 4 or y2 < -4 or y2 > height + 4 or node.T < 1.1 then
			continue
		end
		table.insert(segments, { X1 = node.X, Y1 = node.Y, X2 = x2, Y2 = y2, T = node.T, Depth = node.Depth })
		table.insert(stack, { X = x2, Y = y2, A = angle, T = node.T * 0.94, Depth = node.Depth + 1 })
		if rng:NextNumber() < 0.24 then
			local side = rng:NextNumber() < 0.5 and -1 or 1
			table.insert(stack, { X = x2, Y = y2, A = angle + side * rng:NextNumber(0.5, 1.0), T = node.T * 0.62, Depth = node.Depth + 1 })
		end
	end
	local frames = {}
	for _, segment in segments do
		local dx, dy = segment.X2 - segment.X1, segment.Y2 - segment.Y1
		local length = math.sqrt(dx * dx + dy * dy) + segment.T
		local rotation = math.deg(math.atan2(dy, dx))
		local center = UDim2.fromOffset((segment.X1 + segment.X2) / 2, (segment.Y1 + segment.Y2) / 2)
		if segment.T > 2.4 then
			local glow = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = center,
				Size = UDim2.fromOffset(length + segment.T, segment.T * 3.2),
				Rotation = rotation,
				BackgroundColor3 = VEIN,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 1,
				Parent = canvas,
			}, { round() })
			table.insert(frames, { Frame = glow, Depth = segment.Depth, Target = 0.78 })
		end
		local line = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = center,
			Size = UDim2.fromOffset(length, math.max(segment.T, 1)),
			Rotation = rotation,
			BackgroundColor3 = segment.T > 3 and VEIN_CORE or VEIN,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = canvas,
		}, { round() })
		table.insert(frames, { Frame = line, Depth = segment.Depth, Target = 0.05 })
	end
	return frames
end

function FxBody.veins(character, duration)
	FxBody.clearVeins(character)
	local set = { Guis = {}, Tweens = {} }
	veinSets[character] = set
	local seed = 1
	for name, faces in FACES do
		local part = character:FindFirstChild(name)
		if not part then
			continue
		end
		for _, face in faces do
			seed += 17
			local width, height = faceSize(part, face)
			local gui = make("SurfaceGui", {
				Name = "Veins",
				Face = face,
				SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
				PixelsPerStud = PPS,
				LightInfluence = 0,
				Brightness = 2.4,
				ClipsDescendants = true,
				ZOffset = 1,
				Adornee = part,
				Parent = part,
			})
			local budget = name == "Torso" and 90 or name == "Head" and 18 or 46
			local frames = growVeins(gui, width, height, ROOTS[name], seed, budget)
			for _, entry in frames do
				local delay = entry.Depth * 0.022
				task.delay(delay, function()
					if entry.Frame.Parent then
						tween(entry.Frame, 0.12, { BackgroundTransparency = entry.Target })
					end
				end)
				task.delay(delay + 0.2, function()
					if entry.Frame.Parent then
						table.insert(set.Tweens, tween(entry.Frame, 0.32, { BackgroundTransparency = math.min(entry.Target + 0.35, 0.95) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true))
					end
				end)
			end
			table.insert(set.Guis, gui)
		end
	end
	if duration then
		task.delay(duration, function()
			if veinSets[character] == set then
				FxBody.clearVeins(character)
			end
		end)
	end
end

function FxBody.clearVeins(character)
	local set = veinSets[character]
	if not set then
		return
	end
	veinSets[character] = nil
	for _, t in set.Tweens do
		t:Cancel()
	end
	for _, gui in set.Guis do
		for _, frame in gui:GetChildren() do
			if frame:IsA("Frame") then
				tween(frame, 0.18, { BackgroundTransparency = 1 })
			end
		end
		Debris:AddItem(gui, 0.25)
	end
end

local function pupilCluster(parent, count, color, size)
	for index = 1, count do
		local angle = (index - 1) / count * math.pi * 2 + math.pi / 2
		local radius = count > 1 and 0.2 or 0
		local x = 0.5 + math.cos(angle) * radius
		local y = 0.5 + math.sin(angle) * radius * 0.9
		make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, y),
			Size = UDim2.fromScale(size, size),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundColor3 = INK,
			BorderSizePixel = 0,
			ZIndex = 6,
			Parent = parent,
		}, {
			round(),
			make("UIStroke", { Color = color, Thickness = 1, Transparency = 0.1 }),
			make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.35, 0.35),
				Size = UDim2.fromScale(0.28, 0.28),
				BackgroundColor3 = WHITE,
				BorderSizePixel = 0,
				ZIndex = 7,
			}, { round() }),
		})
	end
end

local function buildEye(parent, props)
	local tilt = props.Tilt or 0
	local color = props.Color or VIOLET
	local holder = make("Frame", {
		Name = "Eye",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		Size = props.Size,
		Rotation = tilt,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = parent,
	})
	make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.35, 1.9),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = holder,
	}, { round() })
	local lid = make("Frame", {
		Name = "Lid",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, props.Open and 1 or 0),
		BackgroundColor3 = INK,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = holder,
	}, {
		round(),
		make("UIStroke", { Color = color, Thickness = props.Stroke or 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})
	local iris = make("Frame", {
		Name = "Iris",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.95, 0.95),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = lid,
	}, {
		round(),
		make("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(INK, 0.55)),
				ColorSequenceKeypoint.new(0.5, color:Lerp(WHITE, 0.35)),
				ColorSequenceKeypoint.new(1, color:Lerp(INK, 0.55)),
			}),
		}),
		make("UIStroke", { Color = WHITE, Thickness = 1, Transparency = 0.35 }),
	})
	make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.72, 0.72),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = iris,
	}, { round(), make("UIStroke", { Color = INK, Thickness = 1, Transparency = 0.2 }) })
	pupilCluster(iris, props.Pupils or 3, color, props.PupilSize or 0.26)
	return holder, lid, iris
end
FxBody.buildEye = buildEye

function FxBody.floatingEye(adornee, offset, size, life, color)
	local gui = make("BillboardGui", {
		Size = UDim2.fromScale(size, size * 0.62),
		LightInfluence = 0,
		Brightness = 2.2,
		MaxDistance = 260,
		StudsOffsetWorldSpace = offset,
		Adornee = adornee,
		AlwaysOnTop = false,
		Parent = folder,
	})
	local pupils = random:NextNumber() < 0.6 and 3 or (random:NextNumber() < 0.5 and 1 or 4)
	local holder, lid, iris = buildEye(gui, {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.78, 0.44),
		Tilt = random:NextNumber(-18, 18),
		Color = color or VIOLET,
		Pupils = pupils,
		PupilSize = pupils == 1 and 0.4 or 0.26,
		Stroke = 2,
	})
	tween(lid, 0.22, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back)
	local look = tween(iris, random:NextNumber(0.6, 1.2), { Position = UDim2.fromScale(random:NextNumber(0.35, 0.65), random:NextNumber(0.42, 0.58)) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		look:Cancel()
		tween(lid, 0.16, { Size = UDim2.fromScale(1, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		for _, child in holder:GetChildren() do
			if child:IsA("Frame") and child ~= lid then
				tween(child, 0.16, { BackgroundTransparency = 1 })
			end
		end
		Debris:AddItem(gui, 0.22)
	end
	if life then
		task.delay(life, close)
	end
	return close
end

function FxBody.faceEyes(character, mastered)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local set = faceSets[character]
	if set then
		if set.Mastered == mastered then
			return
		end
		FxBody.clearFace(character, true)
	end
	set = { Mastered = mastered, Decals = {} }
	faceSets[character] = set
	for _, decal in head:GetChildren() do
		if decal:IsA("Decal") and decal.Face == Enum.NormalId.Front then
			set.Decals[decal] = decal.Transparency
			decal.Transparency = 1
		end
	end
	local plate = make("Part", {
		Name = "AlmightyFace",
		Size = Vector3.new(1.2, 0.7, 0.05),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Massless = true,
		CastShadow = false,
		CFrame = head.CFrame * CFrame.new(0, 0.05, -0.62),
	})
	make("WeldConstraint", { Part0 = head, Part1 = plate, Parent = plate })
	plate.Parent = character
	local gui = make("SurfaceGui", {
		Face = Enum.NormalId.Front,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		PixelsPerStud = 200,
		LightInfluence = 0,
		Brightness = mastered and 3 or 2,
		Adornee = plate,
		Parent = plate,
	})
	set.Gui = plate
	local color = mastered and CRIMSON:Lerp(VIOLET, 0.35) or VIOLET
	local lids = {}
	for side = -1, 1, 2 do
		local x = 0.5 + side * 0.24
		local _, lid = buildEye(gui, {
			Position = UDim2.fromScale(x, 0.42),
			Size = UDim2.fromScale(0.3, 0.26),
			Tilt = side * 12,
			Color = color,
			Pupils = mastered and 4 or 3,
			PupilSize = mastered and 0.24 or 0.28,
			Stroke = 2,
		})
		table.insert(lids, lid)
		make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x - side * 0.01, 0.16),
			Size = UDim2.fromScale(0.3, 0.05),
			Rotation = side * -16,
			BackgroundColor3 = INK,
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = gui,
		}, { round() })
		for streak = 1, mastered and 3 or 2 do
			local offsetX = x + side * (streak - 2) * 0.045
			make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(offsetX, 0.56),
				Size = UDim2.fromScale(0.018, 0.26 + streak * 0.07),
				Rotation = side * (4 + streak * 6),
				BackgroundColor3 = INK,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				ZIndex = 2,
				Parent = gui,
			}, {
				round(),
				make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1) }),
			})
		end
	end
	for _, lid in lids do
		lid.Size = UDim2.fromScale(1, 0)
		tween(lid, 0.35, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back)
	end
	set.Lids = lids
	set.Blink = task.spawn(function()
		while faceSets[character] == set do
			task.wait(random:NextNumber(2.2, 4.5))
			if faceSets[character] ~= set then
				break
			end
			for _, lid in lids do
				tween(lid, 0.06, { Size = UDim2.fromScale(1, 0.05) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
			task.wait(0.08)
			for _, lid in lids do
				tween(lid, 0.1, { Size = UDim2.fromScale(1, 1) })
			end
		end
	end)
end

function FxBody.clearFace(character, instant)
	local set = faceSets[character]
	if not set then
		return
	end
	faceSets[character] = nil
	for decal, transparency in set.Decals do
		if decal.Parent then
			decal.Transparency = transparency
		end
	end
	if set.Gui then
		if instant then
			set.Gui:Destroy()
		else
			for _, lid in set.Lids or {} do
				tween(lid, 0.15, { Size = UDim2.fromScale(1, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
			Debris:AddItem(set.Gui, 0.2)
		end
	end
end

local function wrap(Fx, name, after, before)
	local original = Fx[name]
	Fx[name] = function(data)
		if before then
			before(data)
		end
		if original then
			original(data)
		end
		if after then
			after(data)
		end
	end
end

local function rootOf(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

function FxBody.install(Fx)
	folder = Fx.Util.Folder
	Fx.EyeBuilder = FxBody.floatingEye
	Fx.FlashOverride = function(position, color, size, duration)
		FxBody.impact(position, color, size, duration)
	end

	wrap(Fx, "BlutVene", function(data)
		local character = data.Character
		if not character then
			return
		end
		FxBody.veins(character, data.Duration + 0.15)
		local root = rootOf(character)
		if root then
			FxBody.wave(root.Position - Vector3.new(0, 2.8, 0), VEIN, 2, 14, 0.5, Vector3.yAxis)
			emit(root.Position, 14, {
				Texture = TEX.Glow,
				Color = ColorSequence.new(VEIN),
				Size = seq(0, 0.4, 1, 0),
				Lifetime = NumberRange.new(0.3, 0.6),
				Speed = NumberRange.new(6, 12),
				Life = 0.6,
			})
		end
	end)
	wrap(Fx, "BlutEnd", function(data)
		if data.Character then
			FxBody.clearVeins(data.Character)
		end
	end)
	wrap(Fx, "BlutCounter", function(data)
		local character = data.Character
		if not character then
			return
		end
		FxBody.clearVeins(character)
		local target = rootOf(data.Target)
		if target then
			task.delay(0.16, function()
				if target.Parent then
					FxBody.impact(target.Position, VEIN, 6, 0.35)
					FxBody.wave(target.Position, WHITE, 1, 22, 0.4)
				end
			end)
		end
	end)

	wrap(Fx, "AlmightyStart", function(data)
		if data.Character then
			task.delay((data.Duration or 2) * 0.8, function()
				if data.Character.Parent then
					FxBody.faceEyes(data.Character, false)
				end
			end)
			local root = rootOf(data.Character)
			if root then
				FxBody.implode(root.Position, VIOLET, 14, data.Duration or 2)
			end
		end
	end)
	wrap(Fx, "Mastered", function(data)
		if data.Character then
			FxBody.faceEyes(data.Character, true)
			local root = rootOf(data.Character)
			if root then
				FxBody.wave(root.Position, CRIMSON:Lerp(VIOLET, 0.4), 4, 60, 0.8)
			end
		end
	end)
	wrap(Fx, "AlmightyEnd", nil, function(data)
		if data.Character then
			FxBody.clearFace(data.Character)
			FxBody.clearVeins(data.Character)
		end
	end)
	wrap(Fx, "ResDeath", nil, function(data)
		if data.Character then
			FxBody.clearFace(data.Character, true)
		end
	end)
	wrap(Fx, "ResAppear", function(data)
		if data.Character then
			task.delay(0.2, function()
				if data.Character.Parent then
					FxBody.faceEyes(data.Character, true)
				end
			end)
		end
	end)
	wrap(Fx, "Auswahlen", function(data)
		local root = rootOf(data.Character)
		if root then
			FxBody.implode(root.Position, WHITE, data.Radius, data.PullTime + 0.1)
		end
	end)
	wrap(Fx, "AuswahlenBlast", function(data)
		FxBody.impact(data.Position, WHITE, data.Radius * 0.5, 0.45)
		FxBody.wave(data.Position - Vector3.new(0, 2.6, 0), VIOLET, 3, data.Radius * 2.6, 0.6, Vector3.yAxis)
	end)
	wrap(Fx, "FinisherImpact", function(data)
		FxBody.impact(data.Position, VIOLET, 9, 0.6)
		FxBody.wave(data.Position - Vector3.new(0, 2.6, 0), WHITE, 4, 70, 0.8, Vector3.yAxis)
	end)
	wrap(Fx, "Shatter", function(data)
		if data.Position then
			emit(data.Position, 10, {
				Texture = TEX.Smoke,
				LightEmission = 0,
				Color = ColorSequence.new(Color3.fromRGB(150, 145, 140)),
				Size = seq(0, 2, 1, (data.Radius or 6) * 1.2),
				Transparency = seq(0, 0.3, 1, 1),
				Lifetime = NumberRange.new(0.8, 1.4),
				Speed = NumberRange.new(4, 14),
				Drag = 2,
				Life = 1.4,
			})
		end
	end)
end

return FxBody
