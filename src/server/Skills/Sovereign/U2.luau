return function(ctx)
	local skill = ctx.Skill
	local character, root = ctx.Character, ctx.Root
	local Combat = ctx.Combat
	local FLAT = Vector3.new(1, 0, 1)

	ctx.StartCooldown()
	ctx.Begin(skill.Duration, 0)
	Combat.playAnim(character, "Auswahlen")
	ctx.Fx("Auswahlen", { Radius = skill.Radius, PullTime = skill.PullTime })

	local steps = 5
	local interval = skill.PullTime / steps
	for _ = 1, steps do
		if not ctx.Wait(interval) then
			return
		end
		for _, victim in ctx.Hitbox.sphere(character, root.Position, skill.Radius) do
			local victimRoot = victim:FindFirstChild("HumanoidRootPart")
			if victimRoot and not ctx.State.invulnerable(victim) then
				local offset = (root.Position - victimRoot.Position) * FLAT
				if offset.Magnitude > 4 then
					Combat.push(victim, offset.Unit * skill.PullSpeed, interval + 0.03)
				end
			end
		end
	end

	local attackId = Combat.attackId()
	ctx.Fx("AuswahlenBlast", { Radius = skill.Radius, Position = root.Position })
	for _, victim in ctx.Hitbox.sphere(character, root.Position, skill.Radius) do
		local victimRoot = victim:FindFirstChild("HumanoidRootPart")
		if victimRoot then
			local offset = (victimRoot.Position - root.Position) * FLAT
			local direction = offset.Magnitude > 0.1 and offset.Unit or root.CFrame.LookVector
			Combat.damage(character, victim, {
				Damage = skill.Damage,
				Knockback = Combat.knock(direction, skill.Knockback) + Vector3.new(0, 18, 0),
				KnockTime = 0.2,
				Ragdoll = skill.Ragdoll,
				GuardBreak = true,
				Heavy = true,
				AttackId = attackId,
			})
		end
	end
end
