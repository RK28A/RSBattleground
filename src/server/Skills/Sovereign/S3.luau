return function(ctx)
	local skill = ctx.Skill
	local character, root, st = ctx.Character, ctx.Root, ctx.StateData
	local Combat, State = ctx.Combat, ctx.State

	ctx.StartCooldown()
	ctx.Begin(skill.Window, ctx.Config.BlockWalkSpeed)
	Combat.playAnim(character, "BlutVene")
	ctx.Fx("BlutVene", { Duration = skill.Window })

	local counter
	counter = {
		Until = State.now() + skill.Window,
		Trigger = function(attacker)
			st.IFrameUntil = math.max(st.IFrameUntil, State.now() + 0.6)
			State.busy(character, 0.55, 0)
			Combat.stopAnim(character, "BlutVene")
			ctx.Fx("BlutCounter", { Target = attacker })
			local targetRoot = attacker:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				Combat.face(character, targetRoot.Position)
			end
			Combat.playAnim(character, "CounterStrike")
			task.wait(skill.StrikeDelay)
			if not State.alive(character) or not State.alive(attacker) or not targetRoot or not targetRoot.Parent then
				return
			end
			local offset = (targetRoot.Position - root.Position) * Vector3.new(1, 0, 1)
			if offset.Magnitude > skill.Reach then
				return
			end
			local direction = offset.Magnitude > 0.1 and offset.Unit or root.CFrame.LookVector
			Combat.damage(character, attacker, {
				Damage = skill.Damage,
				Knockback = Combat.knock(direction, skill.Knockback) + Vector3.new(0, 14, 0),
				KnockTime = 0.2,
				Ragdoll = skill.Ragdoll,
				IsCounter = true,
				GuardBreak = true,
				Heavy = true,
			})
		end,
	}
	st.Counter = counter

	task.delay(skill.Window, function()
		if st.Counter ~= counter then
			return
		end
		st.Counter = nil
		if character.Parent then
			Combat.stopAnim(character, "BlutVene")
			ctx.Fx("BlutEnd")
			State.lock(character, skill.Recovery)
		end
	end)
end
