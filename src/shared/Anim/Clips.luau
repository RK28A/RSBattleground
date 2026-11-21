local function r(x, y, z)
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

local Quint = Enum.EasingStyle.Quint
local Back = Enum.EasingStyle.Back
local Sine = Enum.EasingStyle.Sine

local Clips = {}

Clips.Blade1 = {
	Length = 0.34,
	Keys = {
		{ t = 0, Pose = { Torso = r(4, -32, 0), Head = r(0, 20, 0), RA = r(160, 0, 35), LA = r(-15, 0, -12), RL = r(-10, 0, 0), LL = r(12, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-10, 38, 0), Head = r(4, -24, 0), RA = r(35, 0, -45), LA = r(-30, 0, -20), RL = r(-22, 0, 0), LL = r(20, 0, 0) } },
		{ t = 0.34, Ease = Sine, Pose = { Torso = r(-5, 22, 0), Head = r(2, -14, 0), RA = r(25, 0, -30), LA = r(-18, 0, -12), RL = r(-10, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.Blade2 = {
	Length = 0.34,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, 40, 0), Head = r(0, -26, 0), RA = r(90, 0, -70), LA = r(-20, 0, -18), RL = r(-16, 0, 0), LL = r(14, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-6, -42, 0), Head = r(0, 28, 0), RA = r(90, 0, 60), LA = r(-25, 0, -25), RL = r(14, 0, 0), LL = r(-18, 0, 0) } },
		{ t = 0.34, Ease = Sine, Pose = { Torso = r(-3, -24, 0), Head = r(0, 16, 0), RA = r(70, 0, 45), LA = r(-15, 0, -14), RL = r(8, 0, 0), LL = r(-8, 0, 0) } },
	},
}

Clips.Blade3 = {
	Length = 0.34,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, -44, 0), Head = r(0, 28, 0), RA = r(90, 0, 70), LA = r(-10, 0, -20), RL = r(14, 0, 0), LL = r(-16, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-8, 46, 0), Head = r(0, -30, 0), RA = r(88, 0, -62), LA = r(-35, 0, -22), RL = r(-20, 0, 0), LL = r(18, 0, 0) } },
		{ t = 0.34, Ease = Sine, Pose = { Torso = r(-4, 26, 0), Head = r(0, -16, 0), RA = r(70, 0, -40), LA = r(-20, 0, -14), RL = r(-10, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.Blade4 = {
	Length = 0.42,
	Keys = {
		{ t = 0, Pose = { Torso = r(16, -10, 0), Head = r(-10, 6, 0), RA = r(188, 0, 12), LA = r(40, 0, -20), RL = r(-12, 0, 0), LL = r(20, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-28, 12, 0), Head = r(16, -8, 0), RA = r(30, 0, -8), LA = r(-40, 0, -24), RL = r(-34, 0, 0), LL = r(30, 0, 0) } },
		{ t = 0.42, Ease = Sine, Pose = { Torso = r(-16, 8, 0), Head = r(10, -5, 0), RA = r(22, 0, -6), LA = r(-24, 0, -16), RL = r(-18, 0, 0), LL = r(16, 0, 0) } },
	},
}

Clips.Heavy1 = {
	Length = 0.36,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, -52, 0), Head = r(0, 34, 0), RA = r(84, 0, -18), LA = r(84, 0, 22), RL = r(14, 0, 0), LL = r(-18, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-10, 54, 0), Head = r(0, -34, 0), RA = r(78, 0, -24), LA = r(78, 0, 16), RL = r(-22, 0, 0), LL = r(20, 0, 0) } },
		{ t = 0.36, Ease = Sine, Pose = { Torso = r(-5, 30, 0), Head = r(0, -18, 0), RA = r(60, 0, -18), LA = r(60, 0, 12), RL = r(-10, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.Heavy2 = {
	Length = 0.36,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, 52, 0), Head = r(0, -34, 0), RA = r(84, 0, -22), LA = r(84, 0, 18), RL = r(-18, 0, 0), LL = r(14, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-10, -54, 0), Head = r(0, 34, 0), RA = r(78, 0, -16), LA = r(78, 0, 24), RL = r(20, 0, 0), LL = r(-22, 0, 0) } },
		{ t = 0.36, Ease = Sine, Pose = { Torso = r(-5, -30, 0), Head = r(0, 18, 0), RA = r(60, 0, -12), LA = r(60, 0, 18), RL = r(10, 0, 0), LL = r(-10, 0, 0) } },
	},
}

Clips.Heavy3 = {
	Length = 0.36,
	Keys = {
		{ t = 0, Pose = { Torso = r(-22, -58, 0), Head = r(10, 36, 0), RA = r(34, 0, -16), LA = r(34, 0, 20), RL = r(-20, 0, 0), LL = r(16, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(10, 56, 0), Head = r(-6, -34, 0), RA = r(132, 0, -20), LA = r(132, 0, 16), RL = r(12, 0, 0), LL = r(-16, 0, 0) } },
		{ t = 0.36, Ease = Sine, Pose = { Torso = r(4, 30, 0), Head = r(-2, -18, 0), RA = r(100, 0, -16), LA = r(100, 0, 12), RL = r(6, 0, 0), LL = r(-8, 0, 0) } },
	},
}

Clips.Heavy4 = {
	Length = 0.44,
	Keys = {
		{ t = 0, Pose = { Torso = r(20, 0, 0), Head = r(-12, 0, 0), RA = r(176, 0, -14), LA = r(176, 0, 14), RL = r(-10, 0, 0), LL = r(22, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-32, 0, 0), Head = r(18, 0, 0), RA = r(40, 0, -16), LA = r(40, 0, 16), RL = r(-36, 0, 0), LL = r(32, 0, 0) } },
		{ t = 0.44, Ease = Sine, Pose = { Torso = r(-18, 0, 0), Head = r(10, 0, 0), RA = r(30, 0, -14), LA = r(30, 0, 14), RL = r(-18, 0, 0), LL = r(16, 0, 0) } },
	},
}

Clips.Uppercut = {
	Length = 0.4,
	Keys = {
		{ t = 0, Pose = { Torso = r(-26, -24, 0), Head = r(14, 14, 0), RA = r(6, 0, 14), LA = r(-20, 0, -14), RL = r(-30, 0, 0), LL = r(24, 0, 0) } },
		{ t = 0.13, Ease = Back, Pose = { Torso = r(16, 26, 0), Head = r(-14, -16, 0), RA = r(172, 0, -10), LA = r(-40, 0, -20), RL = r(6, 0, 0), LL = r(-10, 0, 0) } },
		{ t = 0.4, Ease = Sine, Pose = { Torso = r(8, 14, 0), Head = r(-6, -8, 0), RA = r(140, 0, -6), LA = r(-24, 0, -14), RL = r(0, 0, 0), LL = r(0, 0, 0) } },
	},
}

Clips.Downslam = {
	Length = 0.42,
	Keys = {
		{ t = 0, Pose = { Torso = r(24, 0, 0), Head = r(-14, 0, 0), RA = r(182, 0, -10), LA = r(182, 0, 10), RL = r(30, 0, 0), LL = r(30, 0, 0) } },
		{ t = 0.13, Ease = Quint, Pose = { Torso = r(-44, 0, 0), Head = r(24, 0, 0), RA = r(24, 0, -12), LA = r(24, 0, 12), RL = r(-40, 0, 0), LL = r(-30, 0, 0) } },
		{ t = 0.42, Ease = Sine, Pose = { Torso = r(-24, 0, 0), Head = r(12, 0, 0), RA = r(16, 0, -10), LA = r(16, 0, 10), RL = r(-20, 0, 0), LL = r(-14, 0, 0) } },
	},
}

Clips.Block = {
	Length = 0.1,
	Hold = true,
	FadeIn = 0.07,
	FadeOut = 0.1,
	Keys = {
		{ t = 0, Pose = { Torso = r(-6, 0, 0), Head = r(8, 0, 0), RA = r(104, 0, -48), LA = r(104, 0, 48) } },
		{ t = 0.1, Pose = { Torso = r(-6, 0, 0), Head = r(8, 0, 0), RA = r(104, 0, -48), LA = r(104, 0, 48) } },
	},
}

Clips.DashFront = {
	Length = 0.24,
	Keys = {
		{ t = 0, Pose = { Torso = r(-34, 0, 0), Head = r(24, 0, 0), RA = r(-50, 0, 16), LA = r(-50, 0, -16), RL = r(-30, 0, 0), LL = r(36, 0, 0) } },
		{ t = 0.24, Ease = Sine, Pose = { Torso = r(-22, 0, 0), Head = r(16, 0, 0), RA = r(-34, 0, 12), LA = r(-34, 0, -12), RL = r(20, 0, 0), LL = r(-24, 0, 0) } },
	},
}

Clips.DashBack = {
	Length = 0.24,
	Keys = {
		{ t = 0, Pose = { Torso = r(22, 0, 0), Head = r(-10, 0, 0), RA = r(54, 0, 14), LA = r(54, 0, -14), RL = r(34, 0, 0), LL = r(-14, 0, 0) } },
		{ t = 0.24, Ease = Sine, Pose = { Torso = r(12, 0, 0), Head = r(-6, 0, 0), RA = r(34, 0, 10), LA = r(34, 0, -10), RL = r(14, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.DashLeft = {
	Length = 0.24,
	Keys = {
		{ t = 0, Pose = { Torso = r(-8, 0, 26), Head = r(0, 0, -14), RA = r(0, 0, 44), LA = r(0, 0, 10), RL = r(0, 0, 30), LL = r(0, 0, -6) } },
		{ t = 0.24, Ease = Sine, Pose = { Torso = r(-4, 0, 14), Head = r(0, 0, -8), RA = r(0, 0, 24), LA = r(0, 0, 4), RL = r(0, 0, 14), LL = r(0, 0, -4) } },
	},
}

Clips.DashRight = {
	Length = 0.24,
	Keys = {
		{ t = 0, Pose = { Torso = r(-8, 0, -26), Head = r(0, 0, 14), RA = r(0, 0, -10), LA = r(0, 0, -44), RL = r(0, 0, 6), LL = r(0, 0, -30) } },
		{ t = 0.24, Ease = Sine, Pose = { Torso = r(-4, 0, -14), Head = r(0, 0, 8), RA = r(0, 0, -4), LA = r(0, 0, -24), RL = r(0, 0, 4), LL = r(0, 0, -14) } },
	},
}

Clips.Hurt1 = {
	Length = 0.3,
	FadeIn = 0.02,
	Keys = {
		{ t = 0, Pose = { Torso = r(18, 14, 0), Head = r(14, -8, 0), RA = r(-20, 0, 26), LA = r(-10, 0, -22) } },
		{ t = 0.3, Ease = Sine, Pose = { Torso = r(6, 5, 0), Head = r(4, -2, 0), RA = r(-6, 0, 8), LA = r(-4, 0, -8) } },
	},
}

Clips.Hurt2 = {
	Length = 0.3,
	FadeIn = 0.02,
	Keys = {
		{ t = 0, Pose = { Torso = r(16, -16, 0), Head = r(12, 10, 0), RA = r(-10, 0, 22), LA = r(-22, 0, -26) } },
		{ t = 0.3, Ease = Sine, Pose = { Torso = r(5, -6, 0), Head = r(4, 3, 0), RA = r(-4, 0, 8), LA = r(-6, 0, -8) } },
	},
}

Clips.BowDraw = {
	Length = 0.2,
	Hold = true,
	FadeIn = 0.12,
	FadeOut = 0.1,
	Keys = {
		{ t = 0, Pose = { Torso = r(0, -62, 0), Head = r(0, 58, 0), LA = r(90, 0, -62), RA = r(96, 0, -30), RL = r(0, 0, 8), LL = r(0, 0, -8) } },
		{ t = 0.2, Pose = { Torso = r(2, -66, 0), Head = r(0, 62, 0), LA = r(90, 0, -66), RA = r(100, 0, 24), RL = r(0, 0, 10), LL = r(0, 0, -10) } },
	},
}

Clips.BigBowDraw = {
	Length = 0.5,
	Hold = true,
	FadeIn = 0.15,
	FadeOut = 0.1,
	Keys = {
		{ t = 0, Pose = { Torso = r(0, -60, 0), Head = r(0, 56, 0), LA = r(96, 0, -60), RA = r(96, 0, -30), RL = r(0, 0, 10), LL = r(0, 0, -10) } },
		{ t = 0.5, Ease = Sine, Pose = { Torso = r(10, -70, 0), Head = r(-6, 66, 0), LA = r(104, 0, -70), RA = r(108, 0, 40), RL = r(-8, 0, 14), LL = r(10, 0, -14) } },
	},
}

Clips.BowRelease = {
	Length = 0.34,
	FadeIn = 0.02,
	Keys = {
		{ t = 0, Pose = { Torso = r(6, -68, 0), Head = r(-2, 64, 0), LA = r(92, 0, -68), RA = r(100, 0, 30) } },
		{ t = 0.08, Ease = Quint, Pose = { Torso = r(10, -74, 0), Head = r(-4, 70, 0), LA = r(98, 0, -74), RA = r(70, 0, 84) } },
		{ t = 0.34, Ease = Sine, Pose = { Torso = r(2, -40, 0), Head = r(0, 36, 0), LA = r(60, 0, -40), RA = r(30, 0, 40) } },
	},
}

Clips.Judgment = {
	Length = 1,
	FadeIn = 0.04,
	Keys = {
		{ t = 0, Pose = { Torso = r(-18, -40, 0), Head = r(10, 26, 0), RA = r(100, 0, 74), LA = r(-30, 0, -20), RL = r(-30, 0, 0), LL = r(34, 0, 0) } },
		{ t = 0.24, Ease = Quint, Pose = { Torso = r(-10, 46, 0), Head = r(4, -30, 0), RA = r(86, 0, -64), LA = r(-36, 0, -22), RL = r(-20, 0, 0), LL = r(18, 0, 0) } },
		{ t = 0.34, Ease = Sine, Pose = { Torso = r(-8, 50, 0), Head = r(4, -32, 0), RA = r(96, 0, -72), LA = r(-30, 0, -20), RL = r(-14, 0, 0), LL = r(12, 0, 0) } },
		{ t = 0.46, Ease = Quint, Pose = { Torso = r(-8, -46, 0), Head = r(2, 30, 0), RA = r(92, 0, 66), LA = r(-20, 0, -26), RL = r(16, 0, 0), LL = r(-20, 0, 0) } },
		{ t = 0.6, Ease = Sine, Pose = { Torso = r(-30, -26, 0), Head = r(18, 16, 0), RA = r(4, 0, 18), LA = r(-24, 0, -16), RL = r(-34, 0, 0), LL = r(26, 0, 0) } },
		{ t = 0.72, Ease = Back, Pose = { Torso = r(18, 28, 0), Head = r(-16, -18, 0), RA = r(176, 0, -8), LA = r(-44, 0, -22), RL = r(8, 0, 0), LL = r(-12, 0, 0) } },
		{ t = 1, Ease = Sine, Pose = { Torso = r(8, 14, 0), Head = r(-6, -8, 0), RA = r(140, 0, -4), LA = r(-22, 0, -14), RL = r(0, 0, 0), LL = r(0, 0, 0) } },
	},
}

Clips.BlutVene = {
	Length = 0.15,
	Hold = true,
	FadeIn = 0.08,
	FadeOut = 0.12,
	Keys = {
		{ t = 0, Pose = { Torso = r(-8, 0, 0), Head = r(10, 0, 0), RA = r(62, 0, -56), LA = r(62, 0, 56), RL = r(-6, 0, 8), LL = r(6, 0, -8) } },
		{ t = 0.15, Pose = { Torso = r(-10, 0, 0), Head = r(12, 0, 0), RA = r(66, 0, -58), LA = r(66, 0, 58), RL = r(-6, 0, 8), LL = r(6, 0, -8) } },
	},
}

Clips.CounterStrike = {
	Length = 0.42,
	FadeIn = 0.03,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, -34, 0), Head = r(0, 22, 0), RA = r(40, 0, 26), LA = r(30, 0, -20), RL = r(12, 0, 0), LL = r(-14, 0, 0) } },
		{ t = 0.14, Ease = Quint, Pose = { Torso = r(-10, 32, 0), Head = r(4, -22, 0), RA = r(94, 0, -12), LA = r(-30, 0, -24), RL = r(-24, 0, 0), LL = r(22, 0, 0) } },
		{ t = 0.42, Ease = Sine, Pose = { Torso = r(-4, 16, 0), Head = r(2, -10, 0), RA = r(60, 0, -8), LA = r(-16, 0, -14), RL = r(-10, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.AlmightyStart = {
	Length = 2,
	FadeIn = 0.2,
	FadeOut = 0.25,
	Keys = {
		{ t = 0, Pose = { Torso = r(-6, 0, 0), Head = r(24, 0, 0), RA = r(0, 0, 6), LA = r(0, 0, -6) } },
		{ t = 0.7, Ease = Sine, Pose = { Torso = r(4, 0, 0), Head = r(10, 0, 0), RA = r(-10, 0, 46), LA = r(-10, 0, -46) } },
		{ t = 1.6, Ease = Sine, Pose = { Torso = r(12, 0, 0), Head = r(-22, 0, 0), RA = r(-14, 0, 104), LA = r(-14, 0, -104), RL = r(0, 0, 8), LL = r(0, 0, -8) } },
		{ t = 1.82, Ease = Quint, Pose = { Torso = r(-8, 0, 0), Head = r(6, 0, 0), RA = r(10, 0, 22), LA = r(10, 0, -22), RL = r(0, 0, 6), LL = r(0, 0, -6) } },
		{ t = 2, Ease = Sine, Pose = { Torso = r(-2, 0, 0), Head = r(0, 0, 0), RA = r(0, 0, 10), LA = r(0, 0, -10) } },
	},
}

Clips.EvadeLean = {
	Length = 0.45,
	FadeIn = 0.03,
	Keys = {
		{ t = 0, Pose = { Torso = r(12, 16, 16), Head = r(-6, -10, -10), RA = r(-16, 0, 26), LA = r(-10, 0, -8) } },
		{ t = 0.2, Ease = Sine, Pose = { Torso = r(16, 20, 20), Head = r(-8, -12, -12), RA = r(-20, 0, 30), LA = r(-12, 0, -10) } },
		{ t = 0.45, Ease = Sine, Pose = { Torso = r(2, 2, 2), Head = r(0, 0, 0), RA = r(0, 0, 6), LA = r(0, 0, -6) } },
	},
}

Clips.FateCounter = {
	Length = 0.8,
	FadeIn = 0.03,
	Keys = {
		{ t = 0, Pose = { Torso = r(-6, 26, 0), Head = r(4, -18, 0), LA = r(102, 0, 52), RA = r(10, 0, 20), RL = r(-12, 0, 0), LL = r(10, 0, 0) } },
		{ t = 0.36, Ease = Sine, Pose = { Torso = r(-8, 34, 0), Head = r(4, -24, 0), LA = r(106, 0, 56), RA = r(30, 0, 34), RL = r(-14, 0, 0), LL = r(12, 0, 0) } },
		{ t = 0.5, Ease = Quint, Pose = { Torso = r(-14, -36, 0), Head = r(8, 24, 0), LA = r(-30, 0, -26), RA = r(96, 0, 30), RL = r(18, 0, 0), LL = r(-24, 0, 0) } },
		{ t = 0.8, Ease = Sine, Pose = { Torso = r(-6, -18, 0), Head = r(2, 12, 0), LA = r(-14, 0, -14), RA = r(60, 0, 20), RL = r(8, 0, 0), LL = r(-10, 0, 0) } },
	},
}

Clips.Auswahlen = {
	Length = 1.1,
	FadeIn = 0.06,
	Keys = {
		{ t = 0, Pose = { Torso = r(-16, 0, 0), Head = r(16, 0, 0), RA = r(50, 0, -50), LA = r(50, 0, 50), RL = r(-16, 0, 6), LL = r(14, 0, -6) } },
		{ t = 0.5, Ease = Sine, Pose = { Torso = r(6, 0, 0), Head = r(-14, 0, 0), RA = r(178, 0, 6), LA = r(20, 0, -30), RL = r(0, 0, 8), LL = r(0, 0, -8) } },
		{ t = 0.62, Ease = Quint, Pose = { Torso = r(-12, 0, 0), Head = r(8, 0, 0), RA = r(20, 0, 80), LA = r(20, 0, -80), RL = r(-10, 0, 10), LL = r(-10, 0, -10) } },
		{ t = 1.1, Ease = Sine, Pose = { Torso = r(-4, 0, 0), Head = r(2, 0, 0), RA = r(6, 0, 30), LA = r(6, 0, -30) } },
	},
}

Clips.Finisher = {
	Length = 3,
	FadeIn = 0.08,
	FadeOut = 0.2,
	Keys = {
		{ t = 0, Pose = { Torso = r(-4, 24, 0), Head = r(2, -18, 0), RA = r(92, 0, 20), LA = r(-10, 0, -14), RL = r(-10, 0, 0), LL = r(8, 0, 0) } },
		{ t = 1.1, Ease = Sine, Pose = { Torso = r(-2, 28, 0), Head = r(0, -20, 0), RA = r(94, 0, 24), LA = r(-12, 0, -16), RL = r(-10, 0, 0), LL = r(8, 0, 0) } },
		{ t = 1.9, Ease = Sine, Pose = { Torso = r(8, 10, 0), Head = r(-10, -8, 0), RA = r(164, 0, 10), LA = r(-18, 0, -30), RL = r(-4, 0, 4), LL = r(4, 0, -4) } },
		{ t = 2.3, Ease = Sine, Pose = { Torso = r(16, -10, 0), Head = r(-12, 8, 0), RA = r(186, 0, 6), LA = r(-24, 0, -34), RL = r(-8, 0, 4), LL = r(12, 0, -4) } },
		{ t = 2.55, Ease = Quint, Pose = { Torso = r(-30, 14, 0), Head = r(18, -8, 0), RA = r(28, 0, -6), LA = r(-40, 0, -26), RL = r(-34, 0, 0), LL = r(28, 0, 0) } },
		{ t = 3, Ease = Sine, Pose = { Torso = r(-12, 6, 0), Head = r(6, -4, 0), RA = r(16, 0, 4), LA = r(-16, 0, -14), RL = r(-12, 0, 0), LL = r(10, 0, 0) } },
	},
}

Clips.Frozen = {
	Length = 0.3,
	Hold = true,
	FadeIn = 0.1,
	FadeOut = 0.1,
	Keys = {
		{ t = 0, Pose = { Torso = r(8, 0, 0), Head = r(-18, 0, 0), RA = r(-8, 0, 30), LA = r(-8, 0, -30), RL = r(0, 0, 6), LL = r(0, 0, -6) } },
		{ t = 0.3, Pose = { Torso = r(10, 0, 0), Head = r(-22, 0, 0), RA = r(-10, 0, 34), LA = r(-10, 0, -34), RL = r(0, 0, 6), LL = r(0, 0, -6) } },
	},
}

Clips.ResPush = {
	Length = 1.5,
	FadeIn = 0.1,
	FadeOut = 0.25,
	Keys = {
		{ t = 0, Pose = { Torso = r(0, 0, 0), Head = r(6, 0, 0), RA = r(0, 0, 8), LA = r(0, 0, -8) } },
		{ t = 0.38, Ease = Sine, Pose = { Torso = r(-2, 8, 0), Head = r(4, -6, 0), RA = r(84, 0, -4), LA = r(-4, 0, -10) } },
		{ t = 0.5, Ease = Sine, Pose = { Torso = r(2, -10, 0), Head = r(2, 8, 0), RA = r(80, 0, 6), LA = r(-6, 0, -12) } },
		{ t = 0.62, Ease = Quint, Pose = { Torso = r(-14, 24, 0), Head = r(8, -16, 0), RA = r(96, 0, -10), LA = r(-26, 0, -18), RL = r(-20, 0, 0), LL = r(18, 0, 0) } },
		{ t = 1.1, Ease = Sine, Pose = { Torso = r(-6, 12, 0), Head = r(4, -8, 0), RA = r(50, 0, -4), LA = r(-12, 0, -12), RL = r(-8, 0, 0), LL = r(8, 0, 0) } },
		{ t = 1.5, Ease = Sine, Pose = { Torso = r(0, 0, 0), Head = r(0, 0, 0), RA = r(0, 0, 8), LA = r(0, 0, -8) } },
	},
}

Clips.Panic = {
	Length = 1.25,
	FadeIn = 0.05,
	FadeOut = 0.1,
	Keys = {
		{ t = 0, Pose = { Torso = r(6, 0, 0), Head = r(-8, 0, 0), RA = r(40, 0, 30), LA = r(40, 0, -30) } },
		{ t = 0.18, Ease = Back, Pose = { Torso = r(18, 0, 0), Head = r(-16, 0, 0), RA = r(124, 0, 52), LA = r(124, 0, -52), RL = r(0, 0, 8), LL = r(0, 0, -8) } },
		{ t = 0.55, Ease = Sine, Pose = { Torso = r(20, 4, 0), Head = r(-18, -4, 0), RA = r(130, 0, 56), LA = r(118, 0, -48), RL = r(0, 0, 8), LL = r(0, 0, -8) } },
		{ t = 0.68, Ease = Sine, Pose = { Torso = r(24, -6, 0), Head = r(-18, 4, 0), RA = r(110, 0, 70), LA = r(140, 0, -40), RL = r(34, 0, 0), LL = r(-16, 0, 0) } },
		{ t = 0.81, Ease = Sine, Pose = { Torso = r(26, 6, 0), Head = r(-20, -4, 0), RA = r(140, 0, 40), LA = r(110, 0, -70), RL = r(-16, 0, 0), LL = r(36, 0, 0) } },
		{ t = 0.94, Ease = Sine, Pose = { Torso = r(30, -6, 0), Head = r(-20, 4, 0), RA = r(110, 0, 76), LA = r(150, 0, -44), RL = r(38, 0, 0), LL = r(-18, 0, 0) } },
		{ t = 1.08, Ease = Sine, Pose = { Torso = r(36, 4, 0), Head = r(-24, 0, 0), RA = r(150, 0, 60), LA = r(120, 0, -80), RL = r(-10, 0, 0), LL = r(44, 0, 0) } },
		{ t = 1.25, Ease = Sine, Pose = { Torso = r(46, 0, 0), Head = r(-28, 0, 0), RA = r(160, 0, 70), LA = r(160, 0, -70), RL = r(50, 0, 0), LL = r(40, 0, 0) } },
	},
}

return Clips
