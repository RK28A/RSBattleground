local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Net = require(Shared:WaitForChild("Net"))
local Characters = require(Shared:WaitForChild("Characters"))

local player = Players.LocalPlayer

local INK = Color3.fromRGB(10, 13, 22)
local SILVER = Color3.fromRGB(242, 244, 248)
local DANGER = Color3.fromRGB(232, 62, 52)
local SERIF = Enum.Font.Garamond
local DIGIT = Enum.Font.Michroma

local Hud = {}

local gui
local definition = Characters.get(nil)
local diamond, diamondCore, diamondStroke
local wingLeft, wingRight, fillLeft, fillRight
local ultName, ultKey
local healthFill, healthGhost, healthText
local evasionChip, rebirthChip
local phaseEyes = {}
local slots = {}
local roster
local choice
local choiceLabels = {}
local lastPhase = ""

local function make(class, properties, children)
	local instance = Instance.new(class)
	for key, value in properties do
		instance[key] = value
	end
	for _, child in children or {} do
		child.Parent = instance
	end
	return instance
end

local function corner(radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function round()
	return make("UICorner", { CornerRadius = UDim.new(0.5, 0) })
end

local function stroke(color, thickness, transparency)
	return make("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function label(properties)
	local base = {
		BackgroundTransparency = 1,
		Font = SERIF,
		TextColor3 = SILVER,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in properties do
		base[key] = value
	end
	return make("TextLabel", base)
end

local function taper(rotation)
	return make("UIGradient", {
		Rotation = rotation,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})
end

local function glyphEye()
	local iris = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.4, 0.8),
		BackgroundColor3 = SILVER,
		BorderSizePixel = 0,
	}, {
		round(),
		make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.24, 0.8),
			BackgroundColor3 = INK,
			BorderSizePixel = 0,
		}, { round() }),
	})
	return make("Frame", {
		Size = UDim2.fromOffset(24, 12),
		BackgroundColor3 = INK,
		BorderSizePixel = 0,
		Visible = false,
	}, { round(), stroke(SILVER, 1, 0), iris })
end

local function chip(text, order)
	return label({
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 15,
		Text = text,
		LayoutOrder = order,
		Visible = false,
	})
end

local function buildTop()
	fillLeft = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
	})
	wingLeft = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.5, -20, 0, 11),
		Size = UDim2.fromOffset(250, 4),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, { taper(180), fillLeft })

	fillRight = make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
	})
	wingRight = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.5, 20, 0, 11),
		Size = UDim2.fromOffset(250, 4),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, { taper(0), fillRight })

	diamondCore = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
	})
	diamondStroke = stroke(SILVER, 1.5, 0.2)
	diamond = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 11),
		Size = UDim2.fromOffset(18, 18),
		Rotation = 45,
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, { diamondStroke, diamondCore })

	ultName = label({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 26),
		Size = UDim2.fromOffset(360, 18),
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = "",
	})
	ultKey = label({
		Position = UDim2.new(0.5, 280, 0, 4),
		Size = UDim2.fromOffset(60, 14),
		Font = DIGIT,
		TextSize = 11,
		Text = "G",
	})

	healthGhost = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = SILVER, BackgroundTransparency = 0.65, BorderSizePixel = 0 })
	healthFill = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = SILVER, BorderSizePixel = 0, ZIndex = 2 })
	healthText = label({
		Position = UDim2.new(1, 10, 0.5, -8),
		Size = UDim2.fromOffset(50, 16),
		Font = DIGIT,
		TextSize = 12,
		Text = "100",
	})
	local health = make("Frame", {
		Name = "Health",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 50),
		Size = UDim2.fromOffset(300, 5),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, { healthGhost, healthFill, healthText })

	evasionChip = chip("Future evasion", 2)
	rebirthChip = chip("Rebirth ready", 3)
	phaseEyes[1] = glyphEye()
	phaseEyes[1].LayoutOrder = 1
	phaseEyes[2] = glyphEye()
	phaseEyes[2].LayoutOrder = 4
	local phaseRow = make("Frame", {
		Name = "Phase",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 64),
		Size = UDim2.fromOffset(420, 18),
		BackgroundTransparency = 1,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 12),
		}),
		phaseEyes[1],
		evasionChip,
		rebirthChip,
		phaseEyes[2],
	})

	make("Frame", {
		Name = "Top",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.fromOffset(700, 90),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { wingLeft, wingRight, diamond, ultName, ultKey, health, phaseRow })
end

local function buildSlot(index)
	local fill = make("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 })
	local track = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, { fill })
	local badgeStroke = stroke(SILVER, 1, 0.3)
	local badge = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(18, 17),
		Size = UDim2.fromOffset(15, 15),
		Rotation = 45,
		BackgroundColor3 = INK,
		BorderSizePixel = 0,
	}, { badgeStroke })
	local key = label({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(18, 17),
		Size = UDim2.fromOffset(20, 20),
		Font = DIGIT,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = tostring(index),
		ZIndex = 2,
	})
	local name = label({
		Position = UDim2.new(0, 10, 1, -36),
		Size = UDim2.new(1, -18, 0, 30),
		TextSize = 15,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		Text = "",
	})
	local timer = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -9, 0, 8),
		Size = UDim2.fromOffset(60, 18),
		Font = DIGIT,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
	})
	local frame = make("Frame", {
		Name = "Move" .. index,
		Size = UDim2.fromOffset(118, 64),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		LayoutOrder = index,
	}, { corner(2), track, badge, key, name, timer })
	return { Frame = frame, Name = name, Key = key, Fill = fill, Timer = timer, BadgeStroke = badgeStroke }
end

local function buildBottom()
	local row = make("Frame", {
		Name = "Moves",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(520, 64),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}),
	})
	for index = 1, 4 do
		local slot = buildSlot(index)
		slot.Frame.Parent = row
		slots[index] = slot
	end
end

local function buildChoice()
	choice = make("Frame", {
		Name = "UltChoice",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -102),
		Size = UDim2.fromOffset(640, 46),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	})
	for index = 1, 4 do
		local text = label({
			Size = UDim2.fromScale(1, 1),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = "",
		})
		make("Frame", {
			Size = UDim2.fromOffset(150, 46),
			BackgroundColor3 = INK,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			LayoutOrder = index,
			Parent = choice,
		}, { corner(2), text })
		choiceLabels[index] = text
	end
end

local function buildRoster()
	roster = make("Frame", {
		Name = "Roster",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.48),
		Size = UDim2.fromOffset(#Characters.Order * 236 + 16, 280),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		}),
	})
	if #Characters.Order < 2 then
		return
	end

	local open = make("TextButton", {
		Name = "RosterButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(150, 30),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = SERIF,
		TextSize = 17,
		TextColor3 = SILVER,
		Text = "Change fighter",
		Parent = gui,
	}, { corner(2) })
	open.Activated:Connect(function()
		Hud.toggleRoster()
	end)

	for order, id in Characters.Order do
		local def = Characters.List[id]
		local outline = stroke(def.Accent, 1, 0.6)
		local card = make("TextButton", {
			Name = id,
			Size = UDim2.fromOffset(220, 280),
			BackgroundColor3 = INK,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			ClipsDescendants = true,
			Text = "",
			LayoutOrder = order,
			Parent = roster,
		}, {
			corner(2),
			outline,
			make("Frame", {
				Size = UDim2.new(1, 0, 0, 130),
				BackgroundColor3 = def.Accent,
				BorderSizePixel = 0,
			}, { make("UIGradient", { Rotation = 90, Color = ColorSequence.new(def.Accent, def.Dark) }) }),
			label({
				Position = UDim2.fromOffset(16, 144),
				Size = UDim2.new(1, -32, 0, 30),
				TextSize = 26,
				Text = def.Name,
			}),
			label({
				Position = UDim2.fromOffset(16, 178),
				Size = UDim2.new(1, -32, 0, 40),
				TextSize = 15,
				TextTransparency = 0.35,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = def.Tagline,
			}),
			label({
				Position = UDim2.new(0, 16, 1, -38),
				Size = UDim2.new(1, -32, 0, 24),
				TextSize = 17,
				TextColor3 = def.Accent,
				Text = "Play as " .. def.Name,
			}),
		})
		card.MouseEnter:Connect(function()
			TweenService:Create(outline, TweenInfo.new(0.12), { Transparency = 0 }):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(outline, TweenInfo.new(0.12), { Transparency = 0.6 }):Play()
		end)
		card.Activated:Connect(function()
			Net.SelectCharacter:FireServer(id)
			roster.Visible = false
		end)
	end
end

local function currentSkills()
	if player:GetAttribute("UltMode") and definition.Ult.Skills then
		return definition.Ult.Skills
	end
	return definition.Skills
end

local function applyDefinition()
	definition = Characters.get(player:GetAttribute("Character"))
	local skills = currentSkills()
	for index, slot in slots do
		local skill = skills[index]
		slot.Name.Text = skill and skill.Name or ""
	end
	if definition.Ult.Options then
		for index, text in choiceLabels do
			local option = definition.Ult.Options[index]
			text.Text = option and (index .. "   " .. option.Name) or ""
		end
	end
	choice.Visible = false
end

local function setUlt(ratio, color)
	fillLeft.Size = UDim2.fromScale(ratio, 1)
	fillRight.Size = UDim2.fromScale(ratio, 1)
	fillLeft.BackgroundColor3 = color
	fillRight.BackgroundColor3 = color
	diamondCore.BackgroundColor3 = color
	diamondStroke.Color = color
end

local function pulseDiamond()
	diamond.Size = UDim2.fromOffset(30, 30)
	TweenService:Create(diamond, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(18, 18),
	}):Play()
end

local function update(dt)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local ratio = 0
	if humanoid then
		ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
		healthText.Text = tostring(math.ceil(humanoid.Health))
	end
	healthFill.Size = UDim2.fromScale(ratio, 1)
	healthFill.BackgroundColor3 = ratio < 0.3 and DANGER or SILVER
	local ghost = healthGhost.Size.X.Scale
	healthGhost.Size = UDim2.fromScale(ghost > ratio and math.max(ratio, ghost - dt * 0.5) or ratio, 1)

	local now = workspace:GetServerTimeNow()
	local accent = definition.Accent
	local shadow = definition.Shadow or accent
	local wave = 0.5 + 0.5 * math.sin(os.clock() * 7)
	local phase = ""

	if player:GetAttribute("UltMode") then
		phase = player:GetAttribute("UltPhase") or ""
		local starts = player:GetAttribute("UltStart") or now
		local ends = player:GetAttribute("UltEnd") or now
		local remaining = math.max(ends - now, 0)
		local mastered = phase == "Mastered"
		local core = mastered and 0.5 + wave * 0.3 or 0.6
		setUlt(math.clamp(remaining / math.max(ends - starts, 1), 0, 1), mastered and shadow:Lerp(SILVER, wave * 0.75) or shadow)
		diamondCore.Size = UDim2.fromScale(core, core)
		ultKey.Text = tostring(math.ceil(remaining))
		ultKey.TextTransparency = 0
		ultName.TextTransparency = 0
		ultName.TextColor3 = mastered and SILVER or shadow:Lerp(SILVER, 0.45)
		if phase == "Rebirth" then
			ultName.Text = "The future cannot be erased"
		elseif mastered then
			ultName.Text = definition.Ult.MasteredName or definition.Ult.Name
		else
			ultName.Text = definition.Ult.Name
		end
		local thick = mastered and 7 or 4
		wingLeft.Size = UDim2.fromOffset(250, thick)
		wingRight.Size = UDim2.fromOffset(250, thick)
		evasionChip.Visible = player:GetAttribute("UltEvasion") == true and phase ~= "Rebirth"
		evasionChip.TextColor3 = shadow:Lerp(SILVER, 0.6)
		rebirthChip.Visible = player:GetAttribute("UltRebirth") == true
		rebirthChip.TextTransparency = 0.3
		for _, glyph in phaseEyes do
			glyph.Visible = mastered
		end
		choice.Visible = false
	else
		local ult = math.clamp((player:GetAttribute("Ult") or 0) / Config.Ult.Max, 0, 1)
		local full = ult >= 1
		local core = full and 0.45 + wave * 0.25 or ult * 0.5
		setUlt(ult, full and accent:Lerp(SILVER, wave) or accent)
		diamondCore.Size = UDim2.fromScale(core, core)
		ultKey.Text = "G"
		ultKey.TextTransparency = full and 0 or 0.6
		ultName.Text = definition.Ult.Name
		ultName.TextColor3 = SILVER
		ultName.TextTransparency = full and 0 or 0.45
		wingLeft.Size = UDim2.fromOffset(250, 4)
		wingRight.Size = UDim2.fromOffset(250, 4)
		evasionChip.Visible = false
		rebirthChip.Visible = false
		for _, glyph in phaseEyes do
			glyph.Visible = false
		end
		if not full then
			choice.Visible = false
		end
	end
	if phase ~= lastPhase then
		lastPhase = phase
		if phase == "Startup" or phase == "Mastered" or phase == "Rebirth" then
			pulseDiamond()
		end
	end

	local skills = currentSkills()
	local tint = player:GetAttribute("UltMode") and shadow or accent
	for index, slot in slots do
		local skill = skills[index]
		local remaining = (player:GetAttribute("CD" .. index) or 0) - now
		slot.BadgeStroke.Color = tint
		slot.Fill.BackgroundColor3 = tint
		if skill and remaining > 0 then
			slot.Fill.Size = UDim2.fromScale(1 - math.clamp(remaining / skill.Cooldown, 0, 1), 1)
			slot.Timer.Text = remaining >= 1 and tostring(math.ceil(remaining)) or string.format("%.1f", remaining)
			slot.Name.TextTransparency = 0.55
			slot.Key.TextTransparency = 0.55
			slot.Frame.BackgroundTransparency = 0.5
		else
			slot.Fill.Size = UDim2.fromScale(1, 1)
			slot.Timer.Text = ""
			slot.Name.TextTransparency = 0
			slot.Key.TextTransparency = 0
			slot.Frame.BackgroundTransparency = 0.3
		end
	end
end

function Hud.toggleRoster()
	if #Characters.Order < 2 then
		return
	end
	roster.Visible = not roster.Visible
end

function Hud.requestUlt()
	if (player:GetAttribute("Ult") or 0) < Config.Ult.Max or player:GetAttribute("UltMode") then
		return
	end
	if definition.Ult.Type == "Choice" then
		choice.Visible = not choice.Visible
	else
		Net.Ult:FireServer()
	end
end

function Hud.pickUlt(index)
	if not choice.Visible then
		return false
	end
	choice.Visible = false
	Net.Ult:FireServer(index)
	return true
end

function Hud.start()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	gui = make("ScreenGui", {
		Name = "Hud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})
	buildTop()
	buildBottom()
	buildChoice()
	buildRoster()
	applyDefinition()
	player:GetAttributeChangedSignal("Character"):Connect(applyDefinition)
	player:GetAttributeChangedSignal("UltMode"):Connect(applyDefinition)
	RunService.RenderStepped:Connect(update)
end

return Hud
