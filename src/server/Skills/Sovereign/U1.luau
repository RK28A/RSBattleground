return function(ctx)
	local skill = ctx.Skill
	local character, root, st = ctx.Character, ctx.Root, ctx.StateData
	local Combat, State = ctx.Combat, ctx.State

	ctx.StartCooldown()
	ctx.Fx("FutureSight", { Duration = skill.Window })

	local counter
	counter = {
		Until = State.now() + skill.Window,
		Almighty = true,
		Trigger = function(attacker)
			st.IFrameUntil = math.max(st.IFrameUntil, State.now() + 0.5)
			ctx.Fx("FutureSightHit", { Target = attacker })
			local targetRoot = attacker:FindFirstChild("HumanoidRootPart")
			if not targetRoot or (targetRoot.Position - root.Position).Magnitude > skill.Reach then
				return
			end
			local position = targetRoot.Position
			local spot = Combat.safeSpot(Combat.around(targetRoot, 3), position, nil)
			if spot then
				character:PivotTo(CFrame.lookAt(spot, Vector3.new(position.X, spot.Y, position.Z)))
			end
			State.busy(character, 0.4, 0)
			Combat.playAnim(character, "CounterStrike")
			task.wait(0.14)
			if not State.alive(character) or not State.alive(attacker) or not targetRoot.Parent then
				return
			end
			local offset = (targetRoot.Position - root.Position) * Vector3.new(1, 0, 1)
			if offset.Magnitude > 10 then
				return
			end
			local direction = offset.Magnitude > 0.1 and offset.Unit or root.CFrame.LookVector
			Combat.damage(character, attacker, {
				Damage = skill.Damage,
				Stun = skill.Stun,
				Knockback = direction * 8,
				IsCounter = true,
			})
		end,
	}
	st.Counter = counter

	task.delay(skill.Window, function()
		if st.Counter == counter then
			st.Counter = nil
		end
		if character.Parent then
			ctx.Fx("FutureSightEnd")
		end
	end)
end
