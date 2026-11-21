local Skill = {}
local nextId = 0

function Skill.Press(ctx)
	ctx.Combat.playAnim(ctx.Character, "BigBowDraw")
	ctx.Fx("BowDraw", { Charge = ctx.Skill.MaxHold, Big = true })
end

function Skill.Cancel(ctx)
	ctx.Combat.stopAnim(ctx.Character, "BigBowDraw")
	ctx.Fx("BowCancel")
end

function Skill.Release(ctx, held)
	local skill = ctx.Skill
	local character, root = ctx.Character, ctx.Root
	local Combat = ctx.Combat
	if not ctx.Valid() then
		Skill.Cancel(ctx)
		return
	end
	ctx.Begin(math.max(skill.MinCharge - held, 0) + skill.Recovery, 0)
	if held < skill.MinCharge and not ctx.Wait(skill.MinCharge - held) then
		Skill.Cancel(ctx)
		return
	end

	local aim = ctx.Aim
	Combat.face(character, root.Position + aim * 10)
	Combat.playAnim(character, "BowRelease")
	local origin = root.Position + aim * 3 + Vector3.new(0, 0.6, 0)
	nextId += 1
	local id = nextId
	ctx.Fx("BigArrow", { Id = id, Origin = origin, Direction = aim, Speed = skill.Speed, Range = skill.Range })

	local attackId = Combat.attackId()
	local flat = aim * Vector3.new(1, 0, 1)
	local direction = flat.Magnitude > 0.1 and flat.Unit or root.CFrame.LookVector
	ctx.Projectile.fire({
		Owner = character,
		Origin = root.Position + Vector3.new(0, 0.6, 0),
		Direction = aim,
		Speed = skill.Speed,
		Range = skill.Range,
		Radius = skill.Radius,
		Pierce = true,
		OnHit = function(victim)
			Combat.damage(character, victim, {
				Damage = skill.Damage,
				Knockback = Combat.knock(direction, skill.Knockback) + Vector3.new(0, 12, 0),
				KnockTime = 0.2,
				Ragdoll = skill.Ragdoll,
				GuardBreak = true,
				Heavy = true,
				AttackId = attackId,
			})
		end,
		OnWorld = function(result)
			if ctx.Destruction.is(result.Instance) then
				ctx.Destruction.blast(result.Position, skill.BlastRadius, 45)
				return true
			end
			return false
		end,
		OnEnd = function(position)
			ctx.Net.Fx:FireAllClients("BigArrowEnd", { Id = id, Position = position })
		end,
	})
end

return Skill
