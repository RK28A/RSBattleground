local Hitbox = {}

local function ownerOf(part)
	local current = part.Parent
	while current and current ~= workspace do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return current
		end
		current = current.Parent
	end
	return nil
end

Hitbox.ownerOf = ownerOf

local function collect(attacker, parts)
	local seen = {}
	local victims = {}
	for _, part in parts do
		local character = ownerOf(part)
		if character and character ~= attacker and not seen[character] then
			seen[character] = true
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(victims, character)
			end
		end
	end
	return victims
end

local function paramsFor(attacker)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { attacker }
	return params
end

function Hitbox.box(attacker, cframe, size)
	return collect(attacker, workspace:GetPartBoundsInBox(cframe, size, paramsFor(attacker)))
end

function Hitbox.sphere(attacker, position, radius)
	return collect(attacker, workspace:GetPartBoundsInRadius(position, radius, paramsFor(attacker)))
end

return Hitbox
