return function(ctx)
	local skill = ctx.Skill
	local character, root, st = ctx.Character, ctx.Root, ctx.StateData
	local Combat, State = ctx.Combat, ctx.State
	local machine = st.Almighty
	if not machine or machine.FinisherUsed then
		return
	end

	local victim, nearest = nil, math.huge
	local zone = root.CFrame * CFrame.new(0, 0, -skill.Range / 2)
	for _, other in ctx.Hitbox.box(character, zone, Vector3.new(8, 8, skill.Range)) do
		local otherRoot = other:FindFirstChild("HumanoidRootPart")
		if otherRoot then
			local distance = (otherRoot.Position - root.Position).Magnitude
			if distance < nearest and distance <= skill.Range and Combat.lineOfSight(root.Position, otherRoot.Position) then
				victim, nearest = other, distance
			end
		end
	end

	ctx.Begin(0.35, 0)
	Combat.playAnim(character, "CounterStrike")
	if not victim then
		ctx.StartCooldown()
		return
	end
	local contact = Combat.damage(character, victim, {
		Damage = 0,
		Stun = 0.3,
		Unblockable = true,
		Uncounterable = true,
		Silent = true,
	})
	if contact ~= "Hit" then
		ctx.StartCooldown()
		return
	end

	machine.FinisherUsed = true
	ctx.StartCooldown(ctx.Definition.Ult.Duration)
	local victimRoot = victim:FindFirstChild("HumanoidRootPart")
	State.cinematic(character, skill.Duration)
	State.lock(victim, skill.Duration)
	ctx.Ragdoll.stop(victim)
	Combat.face(character, victimRoot.Position)
	Combat.face(victim, root.Position)
	victimRoot.AssemblyLinearVelocity = Vector3.zero
	victimRoot.Anchored = true
	task.delay(skill.Duration + 0.5, function()
		if victimRoot.Parent then
			victimRoot.Anchored = false
		end
	end)

	Combat.playAnim(character, "Finisher")
	Combat.playAnim(victim, "Frozen")
	ctx.Fx("FutureIsMine", { Target = victim, Duration = skill.Duration, ImpactAt = skill.ImpactAt })

	task.wait(skill.ImpactAt)
	if victimRoot.Parent then
		victimRoot.Anchored = false
	end
	if character.Parent and State.alive(victim) and victimRoot.Parent then
		local position = victimRoot.Position
		local look = (root.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
		Combat.stopAnim(victim, "Frozen")
		Combat.damage(character, victim, {
			Damage = skill.Damage,
			Knockback = Vector3.new(0, -70, 0) + look * 14,
			KnockTime = 0.2,
			Ragdoll = skill.Ragdoll,
			Direct = true,
			Heavy = true,
		})
		ctx.Fx("FinisherImpact", { Position = position, Radius = skill.BlastRadius })
		task.delay(0.1, function()
			ctx.Destruction.blast(position - Vector3.new(0, 3, 0), skill.BlastRadius, 45)
		end)
	end
	task.wait(math.max(skill.Duration - skill.ImpactAt, 0))
	if character.Parent then
		State.cinematic(character, 0)
	end
end
