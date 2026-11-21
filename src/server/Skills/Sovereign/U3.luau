return function(ctx)
	local skill = ctx.Skill
	local character, root, st = ctx.Character, ctx.Root, ctx.StateData
	local Combat, State = ctx.Combat, ctx.State

	local target, best = nil, -math.huge
	for _, other in Combat.characters() do
		local otherRoot = other:FindFirstChild("HumanoidRootPart")
		if other ~= character and otherRoot and State.alive(other) then
			local offset = otherRoot.Position - root.Position
			if offset.Magnitude <= skill.Range then
				local score = offset.Magnitude > 0.1 and offset.Unit:Dot(ctx.Aim) or 1
				score -= offset.Magnitude / (skill.Range * 4)
				if score > best then
					target, best = other, score
				end
			end
		end
	end
	if not target then
		return
	end

	ctx.StartCooldown()
	local record = { CFrame = root.CFrame, Damage = 0, Done = false }
	local disconnect = Combat.onDamaged(function(victim, _, amount)
		if victim == target and not record.Done then
			record.Damage += amount
		end
	end)

	local function close(silent)
		if record.Done then
			return false
		end
		record.Done = true
		disconnect()
		st.Reactivate[ctx.Key] = nil
		if not silent and character.Parent then
			ctx.Fx("DestinyEnd")
		end
		return true
	end

	if st.UltCleanup then
		table.insert(st.UltCleanup, function()
			close(false)
		end)
	end

	ctx.Fx("DestinyMark", { Target = target, Position = root.Position, Duration = skill.Duration })

	st.Reactivate[ctx.Key] = function()
		if not close(true) then
			return
		end
		local from = root.Position
		local saved = record.CFrame.Position
		local spot = Combat.standable(saved) or Combat.safeSpot({}, nil, saved)
		if spot then
			character:PivotTo(CFrame.new(spot) * record.CFrame.Rotation)
			root.AssemblyLinearVelocity = Vector3.zero
		end
		local bonus = math.min(record.Damage * skill.Ratio, skill.Cap)
		ctx.Fx("DestinyReturn", { Target = target, From = from, To = spot or from, Bonus = bonus })
		if bonus > 0 and State.alive(target) then
			Combat.damage(character, target, { Damage = bonus, Stun = 0.35, Direct = true, Heavy = true })
		end
	end

	task.delay(skill.Duration, function()
		close(false)
	end)
end
