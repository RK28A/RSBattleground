return {
	Name = "Blood Sovereign",
	Tagline = "Mid-range blade and light",
	Accent = Color3.fromRGB(96, 170, 255),
	Dark = Color3.fromRGB(14, 20, 38),
	M1Set = "Blade",
	M1Damage = 4,
	FinisherDamage = 6,
	Skills = {
		{ Name = "Holy Arrows", Cooldown = 9 },
		{ Name = "Sovereign Rush", Cooldown = 12 },
		{ Name = "Blood Guard", Cooldown = 14 },
		{ Name = "Great Bow", Cooldown = 18 },
	},
	Ult = {
		Type = "Mode",
		Name = "The Almighty",
		Duration = 25,
		Skills = {
			{ Name = "Foreseen", Cooldown = 6 },
			{ Name = "Black Tide", Cooldown = 7 },
			{ Name = "Altar of Theft", Cooldown = 10 },
			{ Name = "Rewritten Future", Cooldown = 25 },
		},
	},
}
