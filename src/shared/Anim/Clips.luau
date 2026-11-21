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

return Clips
