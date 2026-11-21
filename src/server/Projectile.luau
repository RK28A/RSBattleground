local Hitbox = require(script.Parent.Hitbox)

local Projectile = {}

function Projectile.fire(options)
	task.spawn(function()
		local direction = options.Direction.Unit
		local position = options.Origin
		local travelled = 0
		local ignore = { options.Owner }
		local struck = {}
		local worldHits = 0
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.CollisionGroup = "Players"
		params.FilterDescendantsInstances = ignore

		local function finish(at)
			if options.OnEnd then
				options.OnEnd(at)
			end
		end

		while travelled < options.Range do
			local dt = task.wait()
			local step = math.min(options.Speed * dt, options.Range - travelled)
			local advanced = false
			for _ = 1, 8 do
				local result = workspace:Spherecast(position, options.Radius, direction * step, params)
				if not result then
					advanced = true
					break
				end
				local character = Hitbox.ownerOf(result.Instance)
				if character then
					if not struck[character] then
						struck[character] = true
						options.OnHit(character, result.Position)
					end
					if not options.Pierce then
						finish(result.Position)
						return
					end
					table.insert(ignore, character)
					params.FilterDescendantsInstances = ignore
				else
					worldHits += 1
					local through = options.OnWorld and worldHits <= 14 and options.OnWorld(result)
					if not through then
						finish(result.Position)
						return
					end
					if result.Instance.Parent then
						table.insert(ignore, result.Instance)
						params.FilterDescendantsInstances = ignore
					end
				end
			end
			if not advanced then
				finish(position)
				return
			end
			position += direction * step
			travelled += step
		end
		finish(position)
	end)
end

return Projectile
