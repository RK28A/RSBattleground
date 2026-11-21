return {
	Name = "Pride of the Sun",
	Tagline = "Slow, brutal, stronger every second",
	Accent = Color3.fromRGB(255, 176, 46),
	Dark = Color3.fromRGB(40, 24, 8),
	M1Set = "Blade",
	M1Damage = 5,
	FinisherDamage = 8,
	Skills = {
		{ Name = "Heavy Swing", Cooldown = 9 },
		{ Name = "Pride Flare", Cooldown = 11 },
		{ Name = "Who Decided That?", Cooldown = 15 },
		{ Name = "Cruel Sun", Cooldown = 20 },
	},
	Ult = {
		Type = "Mode",
		Name = "The One",
		Duration = 15,
		Skills = {
			{ Name = "Divine Sword", Cooldown = 4 },
			{ Name = "Divine Spear", Cooldown = 5 },
			{ Name = "Noon Grasp", Cooldown = 7 },
			{ Name = "Final Sun", Cooldown = 15 },
		},
	},
}
