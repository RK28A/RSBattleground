local Logic = require("../src/shared/Logic/Almighty")

local config = {
	Duration = 45,
	Startup = 2,
	EvasionStart = 3,
	MasteredStart = 33,
	EvasionChance = 1 / 3,
	EvasionCooldown = 0.5,
	CounterChance = 1 / 7,
	CounterCooldown = 1.5,
}

local passed, failed = 0, 0

local function check(name, condition)
	if condition then
		passed += 1
	else
		failed += 1
		print("FAIL " .. name)
	end
end

local function fixed(value)
	return function()
		return value
	end
end

do
	local m = Logic.new(config)
	check("starts normal", m.State == "Normal")
	check("activate", Logic.activate(m, 100))
	check("no double activate", not Logic.activate(m, 101))
	check("startup at 0", Logic.update(m, 100) == "AlmightyStartup")
	check("startup at 1.99", Logic.update(m, 101.99) == "AlmightyStartup")
	check("almighty at 2", Logic.update(m, 102) == "Almighty")
	check("no evasion at 2.9", not Logic.evasionActive(m, 102.9))
	check("evasion at 3", Logic.evasionActive(m, 103))
	check("almighty at 32.9", Logic.update(m, 132.9) == "Almighty")
	check("mastered at 33", Logic.update(m, 133) == "AlmightyMastered")
	check("evasion in mastered", Logic.evasionActive(m, 140))
	check("mastered at 44.9", Logic.update(m, 144.9) == "AlmightyMastered")
	check("normal at 45", Logic.update(m, 145) == "Normal")
	check("no evasion after", not Logic.evasionActive(m, 146))
	check("reactivate after end", Logic.activate(m, 200))
end

do
	local m = Logic.new(config)
	Logic.activate(m, 0)
	check("no passive in startup", Logic.resolve(m, 1, 1, fixed(0)) == "None")
	check("no passive before 3s", Logic.resolve(m, 2.5, 2, fixed(0)) == "None")
	check("evade at 3s", Logic.resolve(m, 3, 3, fixed(0)) == "Evade")
	local again, fresh = Logic.resolve(m, 3.1, 3, fixed(0.99))
	check("same attack keeps outcome", again == "Evade" and not fresh)
	check("internal cooldown blocks", Logic.resolve(m, 3.2, 4, fixed(0)) == "None")
	check("evade after cooldown", Logic.resolve(m, 3.6, 5, fixed(0)) == "Evade")
	check("no counter before mastered", Logic.resolve(m, 20, 6, fixed(0.1)) == "Evade")
	check("high roll fails", Logic.resolve(m, 21, 7, fixed(0.9)) == "None")
	local failedAgain = Logic.resolve(m, 21.1, 7, fixed(0))
	check("failed roll is not rerolled on same attack", failedAgain == "None")
end

do
	local m = Logic.new(config)
	Logic.activate(m, 0)
	check("counter first in mastered", Logic.resolve(m, 34, 1, fixed(0.1)) == "Counter")
	check("counter cooldown falls to evade", Logic.resolve(m, 34.6, 2, fixed(0.1)) == "Evade")
	check("counter back after 1.5s", Logic.resolve(m, 35.6, 3, fixed(0.1)) == "Counter")
	local rolls = { 0.5, 0.2 }
	local index = 0
	local outcome = Logic.resolve(m, 38, 4, function()
		index += 1
		return rolls[index]
	end)
	check("counter fails then evade rolls", outcome == "Evade" and index == 2)
	local counted = 0
	Logic.resolve(m, 40, 5, function()
		counted += 1
		return 0.99
	end)
	check("both fail uses two rolls", counted == 2)
end

do
	local m = Logic.new(config)
	Logic.activate(m, 0)
	check("no resurrection before mastered", not Logic.canResurrect(m, 20))
	check("begin refused before mastered", not Logic.beginResurrection(m, 20))
	check("resurrection in mastered", Logic.canResurrect(m, 34))
	check("begin", Logic.beginResurrection(m, 34))
	check("cinematic state", m.State == "ResurrectionCinematic")
	check("cinematic survives timeout", Logic.update(m, 60) == "ResurrectionCinematic")
	check("no passive in cinematic", Logic.resolve(m, 35, 9, fixed(0)) == "None")
	check("no second resurrection", not Logic.beginResurrection(m, 35))
	Logic.finish(m)
	check("normal after finish", m.State == "Normal")
	check("no resurrection in normal", not Logic.canResurrect(m, 36))
	Logic.activate(m, 100)
	check("resurrection again on new ult", Logic.canResurrect(m, 134))
end

do
	local m = Logic.new(config)
	Logic.activate(m, 0)
	check("no resurrection after expiry", not Logic.canResurrect(m, 46))
	Logic.activate(m, 50)
	Logic.kill(m)
	check("dead", m.State == "Dead")
	check("dead stays dead", Logic.update(m, 60) == "Dead")
	Logic.finish(m)
	check("finish keeps dead", m.State == "Dead")
	check("not active when dead", not Logic.active(m))
end

do
	local seed = 12345
	local function rng()
		seed = (seed * 1103515245 + 12345) % 2147483648
		return seed / 2147483648
	end
	local trials = 210000
	local evades, counters = 0, 0
	local base = { Duration = 1e9, Startup = 0, EvasionStart = 0, MasteredStart = 1e9, EvasionChance = 1 / 3, EvasionCooldown = 0, CounterChance = 1 / 7, CounterCooldown = 0 }
	local m = Logic.new(base)
	Logic.activate(m, 0)
	for i = 1, trials do
		if Logic.resolve(m, i, i, rng) == "Evade" then
			evades += 1
		end
	end
	local evadeRate = evades / trials
	check("evasion rate ~1/3 (" .. evadeRate .. ")", math.abs(evadeRate - 1 / 3) < 0.01)

	base.MasteredStart = 0
	local m2 = Logic.new(base)
	Logic.activate(m2, 0)
	evades = 0
	for i = 1, trials do
		local outcome = Logic.resolve(m2, i, i, rng)
		if outcome == "Counter" then
			counters += 1
		elseif outcome == "Evade" then
			evades += 1
		end
	end
	local counterRate = counters / trials
	local evadeAfter = evades / trials
	check("counter rate ~1/7 (" .. counterRate .. ")", math.abs(counterRate - 1 / 7) < 0.01)
	check("evade after failed counter ~2/7 (" .. evadeAfter .. ")", math.abs(evadeAfter - (6 / 7) * (1 / 3)) < 0.01)
end

print(string.format("%d passed, %d failed", passed, failed))
if failed > 0 then
	error("tests failed")
end
