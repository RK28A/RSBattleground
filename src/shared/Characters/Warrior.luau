return {
	Name = "Timid Warrior",
	Tagline = "Two-handed axe, built to take hits",
	Accent = Color3.fromRGB(235, 70, 60),
	Dark = Color3.fromRGB(36, 14, 14),
	M1Set = "Heavy",
	M1Damage = 4.5,
	FinisherDamage = 7,
	Skills = {
		{ Name = "Lightning Strike", Cooldown = 8 },
		{ Name = "Wide Cleave", Cooldown = 11 },
		{ Name = "Stand Firm", Cooldown = 15 },
		{ Name = "Ground Breaker", Cooldown = 17 },
	},
	Ult = {
		Type = "Choice",
		Name = "Warrior's Resolve",
		Options = {
			{ Name = "Cliff Splitter" },
			{ Name = "Dragon Slayer" },
			{ Name = "Earthshatter" },
			{ Name = "Last Stand" },
		},
	},
}
