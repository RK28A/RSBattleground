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

local INK = Color3.fromRGB(10, 11, 14)
local PAPER = Color3.fromRGB(240, 238, 230)
local DANGER = Color3.fromRGB(232, 62, 52)
local HEAD = Enum.Font.Oswald
local BODY = Enum.Font.GothamMedium

local Hud = {}

local gui
local healthFill, healthGhost, healthText
local ultFill, ultLabel, ultKey, ultFrame, ultStroke
local phaseRow, evasionChip, rebirthChip
local phaseEyes = {}
local masteredShown = false
local slots = {}
local roster
local choice
local choiceLabels = {}
local definition = Characters.get(nil)

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
		Font = BODY,
		TextColor3 = PAPER,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in properties do
		base[key] = value
	end
	return make("TextLabel", base)
end

local function glyphEye(color)
	local iris = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.4, 0.8),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
		make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.22, 0.8),
			BackgroundColor3 = INK,
			BorderSizePixel = 0,
		}, { make("UICorner", { CornerRadius = UDim.new(0.5, 0) }) }),
	})
	return make("Frame", {
		Size = UDim2.fromOffset(24, 12),
		BackgroundColor3 = INK,
		BorderSizePixel = 0,
		Visible = false,
	}, { make("UICorner", { CornerRadius = UDim.new(0.5, 0) }), stroke(color, 1, 0), iris })
end

local function chip(text, order)
	return label({
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.25,
		Font = HEAD,
		TextSize = 13,
		Text = "  " .. text .. "  ",
		LayoutOrder = order,
		Visible = false,
	})
end

local function buildSlot(index)
	local cooldown = make("Frame", {
		Name = "Cooldown",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, { corner(4) })
	local timer = label({
		Name = "Timer",
		Size = UDim2.fromScale(1, 1),
		Font = HEAD,
		TextSize = 26,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
	})
	local name = label({
		Name = "Name",
		Position = UDim2.new(0, 8, 1, -30),
		Size = UDim2.new(1, -16, 0, 26),
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		Text = "",
		ZIndex = 2,
	})
	local key = label({
		Name = "Key",
		Position = UDim2.fromOffset(8, 6),
		Size = UDim2.fromOffset(20, 20),
		Font = HEAD,
		TextSize = 20,
		Text = tostring(index),
		ZIndex = 2,
	})
	local bar = make("Frame", {
		Name = "Accent",
		Size = UDim2.new(1, 0, 0, 3),
		BorderSizePixel = 0,
		ZIndex = 2,
	})
	local outline = stroke(PAPER, 1, 0.75)
	local frame = make("Frame", {
		Name = "Slot" .. index,
		Size = UDim2.fromOffset(108, 62),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = index,
	}, { corner(4), outline, bar, key, name, cooldown, timer })
	return { Frame = frame, Name = name, Key = key, Bar = bar, Cooldown = cooldown, Timer = timer, Outline = outline }
end

local function buildBottom()
	healthGhost = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = PAPER, BackgroundTransparency = 0.6, BorderSizePixel = 0 }, { corner(3) })
	healthFill = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = PAPER, BorderSizePixel = 0, ZIndex = 2 }, { corner(3) })
	healthText = label({
		Position = UDim2.new(1, 10, 0, 0),
		Size = UDim2.fromOffset(60, 16),
		Font = HEAD,
		TextSize = 20,
		Text = "100",
	})
	local health = make("Frame", {
		Name = "Health",
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, { corner(3), stroke(INK, 2, 0.2), healthGhost, healthFill, healthText })

	ultFill = make("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, { corner(2) })
	ultLabel = label({
		Position = UDim2.new(0, 0, 0, -16),
		Size = UDim2.fromOffset(300, 14),
		Font = HEAD,
		TextSize = 14,
		Text = "",
	})
	ultKey = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, -16),
		Size = UDim2.fromOffset(60, 14),
		Font = HEAD,
		TextSize = 14,
		Text = "G",
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTransparency = 0.5,
	})
	evasionChip = chip("FUTURE EVASION", 2)
	rebirthChip = chip("REBIRTH READY", 3)
	phaseEyes[1] = glyphEye(PAPER)
	phaseEyes[1].LayoutOrder = 1
	phaseEyes[2] = glyphEye(PAPER)
	phaseEyes[2].LayoutOrder = 4
	phaseRow = make("Frame", {
		Name = "Phase",
		Position = UDim2.new(0, 0, 0, -38),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),
		phaseEyes[1],
		evasionChip,
		rebirthChip,
		phaseEyes[2],
	})
	ultStroke = stroke(PAPER, 1, 1)
	ultFrame = make("Frame", {
		Name = "Ult",
		Position = UDim2.fromOffset(0, 6),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, { corner(2), ultStroke, ultFill, ultLabel, ultKey, phaseRow })
	local ult = ultFrame

	local row = make("Frame", {
		Name = "Skills",
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
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

	make("Frame", {
		Name = "Bottom",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -22),
		Size = UDim2.fromOffset(462, 110),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { ult, health, row })
end

local function buildChoice()
	local list = make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})
	choice = make("Frame", {
		Name = "UltChoice",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -150),
		Size = UDim2.fromOffset(620, 54),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	}, { list })
	for index = 1, 4 do
		local text = label({
			Size = UDim2.fromScale(1, 1),
			Font = HEAD,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = "",
		})
		make("Frame", {
			Size = UDim2.fromOffset(146, 54),
			BackgroundColor3 = INK,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			LayoutOrder = index,
			Parent = choice,
		}, { corner(4), stroke(PAPER, 1, 0.6), text })
		choiceLabels[index] = text
	end
end

local function buildRoster()
	local open = make("TextButton", {
		Name = "RosterButton",
		Position = UDim2.fromOffset(18, 18),
		Size = UDim2.fromOffset(150, 34),
		BackgroundColor3 = INK,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = HEAD,
		TextSize = 18,
		TextColor3 = PAPER,
		Text = "CHARACTERS  M",
		Parent = gui,
	}, { corner(4), stroke(PAPER, 1, 0.75) })
	open.Activated:Connect(function()
		Hud.toggleRoster()
	end)

	roster = make("Frame", {
		Name = "Roster",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		Size = UDim2.fromOffset(#Characters.Order * 232 + 16, 300),
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

	for order, id in Characters.Order do
		local def = Characters.List[id]
		local band = make("Frame", {
			Size = UDim2.new(1, 0, 0, 120),
			BackgroundColor3 = def.Accent,
			BorderSizePixel = 0,
		}, {
			make("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new(def.Accent, def.Dark),
			}),
			label({
				Position = UDim2.fromOffset(14, 8),
				Size = UDim2.fromOffset(60, 60),
				Font = HEAD,
				TextSize = 64,
				TextTransparency = 0.25,
				Text = string.format("%02d", order),
			}),
		})
		local card = make("TextButton", {
			Name = id,
			Size = UDim2.fromOffset(216, 300),
			BackgroundColor3 = INK,
			BackgroundTransparency = 0.06,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			ClipsDescendants = true,
			Text = "",
			LayoutOrder = order,
			Parent = roster,
		}, {
			corner(6),
			stroke(def.Accent, 1, 0.5),
			band,
			label({
				Position = UDim2.fromOffset(14, 132),
				Size = UDim2.new(1, -28, 0, 30),
				Font = HEAD,
				TextSize = 26,
				Text = string.upper(def.Name),
			}),
			label({
				Position = UDim2.fromOffset(14, 164),
				Size = UDim2.new(1, -28, 0, 36),
				TextSize = 13,
				TextTransparency = 0.3,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = def.Tagline,
			}),
			label({
				Position = UDim2.new(0, 14, 1, -40),
				Size = UDim2.new(1, -28, 0, 26),
				Font = HEAD,
				TextSize = 18,
				TextColor3 = def.Accent,
				Text = "SELECT",
			}),
		})
		local outline = card:FindFirstChildOfClass("UIStroke")
		card.MouseEnter:Connect(function()
			TweenService:Create(outline, TweenInfo.new(0.12), { Transparency = 0, Thickness = 2 }):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(outline, TweenInfo.new(0.12), { Transparency = 0.5, Thickness = 1 }):Play()
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
		slot.Bar.BackgroundColor3 = definition.Accent
		slot.Key.TextColor3 = definition.Accent
		slot.Frame.BackgroundColor3 = definition.Dark
	end
	ultFill.BackgroundColor3 = definition.Accent
	ultLabel.Text = string.upper(definition.Ult.Name)
	ultLabel.TextColor3 = definition.Accent
	if definition.Ult.Options then
		for index, text in choiceLabels do
			local option = definition.Ult.Options[index]
			text.Text = option and (index .. "  " .. string.upper(option.Name)) or ""
		end
	end
	choice.Visible = false
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
	healthFill.BackgroundColor3 = ratio < 0.3 and DANGER or PAPER
	local ghost = healthGhost.Size.X.Scale
	healthGhost.Size = UDim2.fromScale(ghost > ratio and math.max(ratio, ghost - dt * 0.5) or ratio, 1)

	local now = workspace:GetServerTimeNow()
	local shadow = definition.Shadow or definition.Accent
	local wave = 0.5 + 0.5 * math.sin(os.clock() * 8)
	if player:GetAttribute("UltMode") then
		local starts = player:GetAttribute("UltStart") or now
		local ends = player:GetAttribute("UltEnd") or now
		local remaining = math.max(ends - now, 0)
		local phase = player:GetAttribute("UltPhase")
		local mastered = phase == "Mastered"
		ultFill.Size = UDim2.fromScale(math.clamp(remaining / math.max(ends - starts, 1), 0, 1), 1)
		ultFill.BackgroundColor3 = mastered and shadow:Lerp(PAPER, wave * 0.7) or shadow
		ultKey.Text = tostring(math.ceil(remaining)) .. "s"
		ultKey.TextTransparency = 0
		ultLabel.TextColor3 = mastered and PAPER:Lerp(shadow, wave * 0.5) or shadow
		if phase == "Rebirth" then
			ultLabel.Text = "THE FUTURE CANNOT BE ERASED"
		elseif mastered then
			ultLabel.Text = string.upper(definition.Ult.MasteredName or definition.Ult.Name)
		else
			ultLabel.Text = string.upper(definition.Ult.Name)
		end
		if mastered ~= masteredShown then
			masteredShown = mastered
			TweenService:Create(ultFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
				Size = UDim2.new(1, 0, 0, mastered and 9 or 6),
			}):Play()
			ultStroke.Color = shadow
			ultStroke.Transparency = mastered and 0 or 1
		end
		evasionChip.Visible = player:GetAttribute("UltEvasion") == true and phase ~= "Rebirth"
		evasionChip.TextColor3 = shadow:Lerp(PAPER, 0.5)
		rebirthChip.Visible = player:GetAttribute("UltRebirth") == true
		rebirthChip.TextTransparency = 0.35
		for _, glyph in phaseEyes do
			glyph.Visible = mastered
		end
		choice.Visible = false
	else
		local ult = math.clamp((player:GetAttribute("Ult") or 0) / Config.Ult.Max, 0, 1)
		ultFill.Size = UDim2.fromScale(ult, 1)
		local full = ult >= 1
		ultKey.Text = "G"
		ultKey.TextTransparency = full and 0 or 0.5
		ultFill.BackgroundColor3 = full and PAPER:Lerp(definition.Accent, wave) or definition.Accent
		ultLabel.Text = string.upper(definition.Ult.Name)
		ultLabel.TextColor3 = definition.Accent
		if masteredShown then
			masteredShown = false
			ultFrame.Size = UDim2.new(1, 0, 0, 6)
			ultStroke.Transparency = 1
		end
		evasionChip.Visible = false
		rebirthChip.Visible = false
		for _, glyph in phaseEyes do
			glyph.Visible = false
		end
		if not full then
			choice.Visible = false
		end
	end

	local skills = currentSkills()
	for index, slot in slots do
		local skill = skills[index]
		local remaining = (player:GetAttribute("CD" .. index) or 0) - now
		if skill and remaining > 0 then
			slot.Cooldown.Size = UDim2.fromScale(1, math.clamp(remaining / skill.Cooldown, 0, 1))
			slot.Timer.Text = remaining >= 1 and tostring(math.ceil(remaining)) or string.format("%.1f", remaining)
			slot.Outline.Transparency = 0.85
		else
			slot.Cooldown.Size = UDim2.fromScale(1, 0)
			slot.Timer.Text = ""
			slot.Outline.Transparency = 0.6
		end
	end
end

function Hud.toggleRoster()
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
	buildBottom()
	buildChoice()
	buildRoster()
	applyDefinition()
	player:GetAttributeChangedSignal("Character"):Connect(applyDefinition)
	player:GetAttributeChangedSignal("UltMode"):Connect(applyDefinition)
	RunService.RenderStepped:Connect(update)
end

return Hud
