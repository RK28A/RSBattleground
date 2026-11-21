local Skill = {}

function Skill.Press(ctx)
	ctx.Combat.playAnim(ctx.Character, "BowDraw")
	ctx.Fx("BowDraw", { Charge = ctx.Skill.ChargeTime, Big = false })
end

function Skill.Cancel(ctx)
	ctx.Combat.stopAnim(ctx.Character, "BowDraw")
	ctx.Fx("BowCancel")
end

function Skill.Release(ctx, held)
	local skill = ctx.Skill
	local character, root = ctx.Character, ctx.Root
	if not ctx.Valid() then
		Skill.Cancel(ctx)
		return
	end
	ctx.Begin(skill.Recovery)
	ctx.Combat.face(character, root.Position + ctx.Aim * 10)
	ctx.Combat.playAnim(character, "BowRelease")

	local charged = held >= skill.ChargeTime
	local aim = ctx.Aim
	local origin = root.Position + aim * 2.5 + Vector3.new(0, 0.6, 0)
	local directions = {}
	if charged then
		directions[1] = aim
	else
		for index = 1, skill.Arrows do
			local angle = -skill.Spread / 2 + skill.Spread * (index - 1) / (skill.Arrows - 1)
			directions[index] = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(angle)):VectorToWorldSpace(aim)
		end
	end

	local range = charged and skill.ChargedRange or skill.Range
	ctx.Fx("Arrows", {
		Origin = origin,
		Directions = directions,
		Speed = skill.Speed,
		Range = range,
		Charged = charged,
	})

	local attackId = ctx.Combat.attackId()
	for _, direction in directions do
		ctx.Projectile.fire({
			Owner = character,
			Origin = root.Position + Vector3.new(0, 0.6, 0),
			Direction = direction,
			Speed = skill.Speed,
			Range = range,
			Radius = charged and skill.ChargedRadius or skill.Radius,
			OnHit = function(victim)
				local params = { Damage = skill.Damage, Stun = skill.Stun, AttackId = attackId }
				if charged then
					params.Damage = skill.ChargedDamage
					params.Stun = skill.ChargedStun
					params.Knockback = ctx.Combat.knock(direction * Vector3.new(1, 0, 1), skill.ChargedKnockback)
					params.Heavy = true
				end
				ctx.Combat.damage(character, victim, params)
			end,
		})
	end
end

return Skill
