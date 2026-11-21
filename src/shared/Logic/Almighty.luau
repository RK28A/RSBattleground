local Logic = {}

Logic.States = {
	Normal = "Normal",
	AlmightyStartup = "AlmightyStartup",
	Almighty = "Almighty",
	AlmightyMastered = "AlmightyMastered",
	ResurrectionCinematic = "ResurrectionCinematic",
	Dead = "Dead",
}

local S = Logic.States

function Logic.new(config)
	return {
		Config = config,
		State = S.Normal,
		StartedAt = nil,
		ResurrectionUsed = false,
		FinisherUsed = false,
		EvadeReadyAt = 0,
		CounterReadyAt = 0,
		Outcomes = {},
	}
end

function Logic.activate(machine, now)
	if machine.State ~= S.Normal then
		return false
	end
	machine.State = S.AlmightyStartup
	machine.StartedAt = now
	machine.ResurrectionUsed = false
	machine.FinisherUsed = false
	machine.EvadeReadyAt = 0
	machine.CounterReadyAt = 0
	machine.Outcomes = {}
	return true
end

function Logic.elapsed(machine, now)
	if not machine.StartedAt then
		return 0
	end
	return now - machine.StartedAt
end

function Logic.update(machine, now)
	local state = machine.State
	if state == S.Normal or state == S.Dead or state == S.ResurrectionCinematic then
		return state
	end
	local config = machine.Config
	local elapsed = Logic.elapsed(machine, now)
	if elapsed >= config.Duration then
		machine.State = S.Normal
		machine.StartedAt = nil
	elseif elapsed >= config.MasteredStart then
		machine.State = S.AlmightyMastered
	elseif elapsed >= config.Startup then
		machine.State = S.Almighty
	else
		machine.State = S.AlmightyStartup
	end
	return machine.State
end

function Logic.evasionActive(machine, now)
	local state = Logic.update(machine, now)
	if state ~= S.Almighty and state ~= S.AlmightyMastered then
		return false
	end
	return Logic.elapsed(machine, now) >= machine.Config.EvasionStart
end

function Logic.resolve(machine, now, attackId, roll)
	local cached = machine.Outcomes[attackId]
	if cached then
		return cached, false
	end
	local config = machine.Config
	local state = Logic.update(machine, now)
	local outcome = "None"
	if state == S.AlmightyMastered and now >= machine.CounterReadyAt and roll() < config.CounterChance then
		outcome = "Counter"
		machine.CounterReadyAt = now + config.CounterCooldown
	elseif Logic.evasionActive(machine, now) and now >= machine.EvadeReadyAt and roll() < config.EvasionChance then
		outcome = "Evade"
		machine.EvadeReadyAt = now + config.EvasionCooldown
	end
	machine.Outcomes[attackId] = outcome
	return outcome, true
end

function Logic.canResurrect(machine, now)
	return Logic.update(machine, now) == S.AlmightyMastered and not machine.ResurrectionUsed
end

function Logic.beginResurrection(machine, now)
	if not Logic.canResurrect(machine, now) then
		return false
	end
	machine.State = S.ResurrectionCinematic
	machine.ResurrectionUsed = true
	return true
end

function Logic.finish(machine)
	if machine.State == S.Dead then
		return
	end
	machine.State = S.Normal
	machine.StartedAt = nil
end

function Logic.kill(machine)
	machine.State = S.Dead
	machine.StartedAt = nil
end

function Logic.active(machine)
	local state = machine.State
	return state == S.AlmightyStartup or state == S.Almighty or state == S.AlmightyMastered or state == S.ResurrectionCinematic
end

return Logic
