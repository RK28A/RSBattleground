local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)

local TAG = "Destructible"
local settings = Config.Destruction

local Destruction = {}

local function distanceToBox(cframe, size, point)
	local localPoint = cframe:PointToObjectSpace(point)
	local half = size / 2
	local clamped = Vector3.new(
		math.clamp(localPoint.X, -half.X, half.X),
		math.clamp(localPoint.Y, -half.Y, half.Y),
		math.clamp(localPoint.Z, -half.Z, half.Z)
	)
	return (localPoint - clamped).Magnitude
end

local function split(box)
	local size = box.Size
	local axis, longest = Vector3.xAxis, size.X
	if size.Y > longest then
		axis, longest = Vector3.yAxis, size.Y
	end
	if size.Z > longest then
		axis, longest = Vector3.zAxis, size.Z
	end
	local half = size - axis * (longest / 2)
	local offset = axis * (longest / 4)
	return { CFrame = box.CFrame * CFrame.new(offset), Size = half }, { CFrame = box.CFrame * CFrame.new(-offset), Size = half }
end

local function shatter(part, position, radius, force, budget)
	local stack = { { CFrame = part.CFrame, Size = part.Size } }
	local keep, loose = {}, {}
	while #stack > 0 do
		local box = table.remove(stack)
		local longest = math.max(box.Size.X, box.Size.Y, box.Size.Z)
		if distanceToBox(box.CFrame, box.Size, position) > radius then
			table.insert(keep, box)
		elseif longest <= settings.Voxel * 1.01 then
			if #loose < budget then
				table.insert(loose, box)
			end
		elseif #loose + #stack >= budget then
			table.insert(keep, box)
		else
			local a, b = split(box)
			table.insert(stack, a)
			table.insert(stack, b)
		end
	end
	if #loose == 0 then
		return 0
	end

	for _, box in keep do
		local piece = part:Clone()
		piece.Size = box.Size
		piece.CFrame = box.CFrame
		piece.Parent = part.Parent
	end
	for _, box in loose do
		local piece = part:Clone()
		CollectionService:RemoveTag(piece, TAG)
		piece.Size = box.Size
		piece.CFrame = box.CFrame
		piece.Anchored = false
		piece.CollisionGroup = "Debris"
		piece.Parent = part.Parent
		local away = box.CFrame.Position - position
		local direction = away.Magnitude > 0.1 and away.Unit or Vector3.yAxis
		piece.AssemblyLinearVelocity = direction * force + Vector3.new(0, force * 0.5, 0)
		piece.AssemblyAngularVelocity = Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
		piece:SetNetworkOwner(nil)
		Debris:AddItem(piece, settings.DebrisLife)
	end
	part:Destroy()
	return #loose
end

function Destruction.blast(position, radius, force)
	local budget = settings.MaxPieces
	local broke = false
	for _, part in workspace:GetPartBoundsInRadius(position, radius) do
		if budget <= 0 then
			break
		end
		if part:IsA("Part") and part.Shape == Enum.PartType.Block and part.Anchored and CollectionService:HasTag(part, TAG) then
			local used = shatter(part, position, radius, force or 40, budget)
			budget -= used
			broke = broke or used > 0
		end
	end
	if broke then
		Net.Fx:FireAllClients("Shatter", { Position = position, Radius = radius })
	end
	return broke
end

function Destruction.is(part)
	return part:IsA("BasePart") and CollectionService:HasTag(part, TAG)
end

function Destruction.tag(part)
	CollectionService:AddTag(part, TAG)
end

return Destruction
