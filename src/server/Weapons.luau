local Weapons = {}

local PALE = Color3.fromRGB(196, 228, 255)
local STEEL = Color3.fromRGB(34, 38, 52)
local WHITE = Color3.new(1, 1, 1)

local function piece(model, arm, size, offset, color, material)
	local part = Instance.new("Part")
	part.Size = size
	part.Color = color
	part.Material = material
	part.Massless = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CollisionGroup = "Players"
	part.CFrame = arm.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = arm
	weld.Part1 = part
	weld.Parent = part
	part.Parent = model
	return part
end

local builders = {}

function builders.SpiritBlade(model, arm)
	local grip = CFrame.new(0, -1, 0)
	piece(model, arm, Vector3.new(0.24, 0.24, 1.1), grip * CFrame.new(0, 0, 0.1), STEEL, Enum.Material.Metal)
	piece(model, arm, Vector3.new(0.34, 0.34, 0.22), grip * CFrame.new(0, 0, 0.72), PALE, Enum.Material.Neon)
	piece(model, arm, Vector3.new(1.5, 0.16, 0.2), grip * CFrame.new(0, 0, -0.55), STEEL, Enum.Material.Metal)
	piece(model, arm, Vector3.new(0.36, 0.36, 0.36), grip * CFrame.new(0, 0, -0.55) * CFrame.Angles(0, 0, math.rad(45)), PALE, Enum.Material.Neon)
	for _, side in { -1, 1 } do
		piece(model, arm, Vector3.new(0.14, 0.14, 0.5), grip * CFrame.new(side * 0.72, 0, -0.74) * CFrame.Angles(0, math.rad(side * -24), 0), PALE, Enum.Material.Neon)
	end
	local blade = piece(model, arm, Vector3.new(0.34, 0.07, 4.4), grip * CFrame.new(0, 0, -2.9), PALE, Enum.Material.Neon)
	blade.Name = "Blade"
	blade.Transparency = 0.15
	piece(model, arm, Vector3.new(0.12, 0.1, 4.6), grip * CFrame.new(0, 0, -3), WHITE, Enum.Material.Neon)
	piece(model, arm, Vector3.new(0.24, 0.07, 0.5), grip * CFrame.new(0, 0, -5.2) * CFrame.Angles(0, math.rad(45), 0), PALE, Enum.Material.Neon)

	local base = Instance.new("Attachment")
	base.Name = "TrailBase"
	base.Position = Vector3.new(0, 0, 2)
	base.Parent = blade
	local tip = Instance.new("Attachment")
	tip.Name = "TrailTip"
	tip.Position = Vector3.new(0, 0, -2.6)
	tip.Parent = blade

	local light = Instance.new("PointLight")
	light.Color = PALE
	light.Brightness = 0.8
	light.Range = 7
	light.Parent = blade
end

function Weapons.equip(character, definition)
	local existing = character:FindFirstChild("Weapon")
	if existing then
		existing:Destroy()
	end
	local build = definition.Weapon and builders[definition.Weapon]
	local arm = character:FindFirstChild("Right Arm")
	if not build or not arm then
		return
	end
	local model = Instance.new("Model")
	model.Name = "Weapon"
	build(model, arm)
	model.Parent = character
end

return Weapons
