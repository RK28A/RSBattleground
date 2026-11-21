return function(ctx)
	local skill = ctx.Skill
	local character, root = ctx.Character, ctx.Root
	local Combat = ctx.Combat

	ctx.StartCooldown()
	ctx.Begin(skill.Duration)
	local look = (root.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local wall = workspace:Raycast(root.Position, look * (skill.DashDistance + 2.5), Combat.worldParams())
	local distance = skill.DashDistance
	if wall then
		distance = math.clamp(wall.Distance - 2.5, 0, skill.DashDistance)
	end
	if distance > 0.5 then
		Combat.push(character, look * (distance / skill.DashTime), skill.DashTime)
	end
	Combat.playAnim(character, "Judgment")
	ctx.Fx("Judgment", { Duration = skill.Duration })

	local elapsed = 0
	for _, hit in skill.Hits do
		if not ctx.Wait(hit.Time - elapsed) then
			return
		end
		elapsed = hit.Time
		local facing = (root.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
		local attackId = Combat.attackId()
		local victims = ctx.Hitbox.box(character, root.CFrame * CFrame.new(0, 0, -skill.Offset), skill.Size)
		for _, victim in victims do
			local params = { Damage = hit.Damage, Stun = hit.Stun, Knockback = facing * 4, AttackId = attackId }
			if hit.Lift then
				params.Knockback = Vector3.new(0, hit.Lift, 0)
				params.Ragdoll = hit.Ragdoll
				params.Heavy = true
			end
			Combat.damage(character, victim, params)
		end
		if not hit.Lift then
			Combat.push(character, facing * 12, 0.1)
		end
	end
end
