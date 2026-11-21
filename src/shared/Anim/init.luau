local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Clips = require(script:WaitForChild("Clips"))

local JOINTS = {
	Torso = { "HumanoidRootPart", "RootJoint" },
	Head = { "Torso", "Neck" },
	RA = { "Torso", "Right Shoulder" },
	LA = { "Torso", "Left Shoulder" },
	RL = { "Torso", "Right Hip" },
	LL = { "Torso", "Left Hip" },
}

local IDENTITY = CFrame.identity

local Anim = {}
local rigs = {}

for _, clip in Clips do
	clip.Joints = {}
	for _, key in clip.Keys do
		for joint in key.Pose do
			clip.Joints[joint] = true
		end
	end
end

local function getRig(character)
	local rig = rigs[character]
	if rig then
		return rig
	end
	local motors = {}
	for joint, path in JOINTS do
		local part = character:FindFirstChild(path[1])
		local motor = part and part:FindFirstChild(path[2])
		if motor and motor:IsA("Motor6D") then
			motors[joint] = motor
		end
	end
	if not motors.Torso then
		return nil
	end
	rig = { Motors = motors, Tracks = {}, Last = {}, Dirty = false }
	rigs[character] = rig
	return rig
end

local function sample(clip, time)
	local keys = clip.Keys
	local count = #keys
	if time <= keys[1].t then
		return keys[1].Pose, keys[1].Pose, 0
	end
	if time >= keys[count].t then
		return keys[count].Pose, keys[count].Pose, 0
	end
	for i = 1, count - 1 do
		local a, b = keys[i], keys[i + 1]
		if time >= a.t and time <= b.t then
			local alpha = (time - a.t) / math.max(b.t - a.t, 1e-4)
			alpha = TweenService:GetValue(alpha, b.Ease or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			return a.Pose, b.Pose, alpha
		end
	end
	return keys[count].Pose, keys[count].Pose, 0
end

function Anim.play(character, name, speed)
	local clip = Clips[name]
	if not clip or not character then
		return
	end
	local rig = getRig(character)
	if not rig then
		return
	end
	for _, track in rig.Tracks do
		track.Stopping = true
	end
	table.insert(rig.Tracks, {
		Name = name,
		Clip = clip,
		Time = 0,
		Weight = 0,
		Speed = speed or 1,
		Stopping = false,
		FrozenUntil = 0,
	})
end

function Anim.stop(character, name)
	local rig = rigs[character]
	if not rig then
		return
	end
	for _, track in rig.Tracks do
		if not name or track.Name == name then
			track.Stopping = true
		end
	end
end

function Anim.freeze(character, duration)
	local rig = rigs[character]
	if not rig then
		return
	end
	local untilTime = os.clock() + duration
	for _, track in rig.Tracks do
		track.FrozenUntil = untilTime
	end
end

function Anim.isPlaying(character, name)
	local rig = rigs[character]
	if not rig then
		return false
	end
	for _, track in rig.Tracks do
		if track.Name == name and not track.Stopping then
			return true
		end
	end
	return false
end

local function step(dt)
	local now = os.clock()
	for character, rig in rigs do
		if not character.Parent then
			rigs[character] = nil
			continue
		end
		local tracks = rig.Tracks
		if #tracks == 0 and not rig.Dirty then
			continue
		end
		rig.Dirty = #tracks > 0

		for i = #tracks, 1, -1 do
			local track = tracks[i]
			local clip = track.Clip
			if now >= track.FrozenUntil then
				track.Time += dt * track.Speed
				if track.Time >= clip.Length then
					if clip.Hold then
						track.Time = clip.Length
					else
						track.Stopping = true
					end
				end
				if track.Stopping then
					track.Weight -= dt / (clip.FadeOut or 0.12)
					if track.Weight <= 0 then
						table.remove(tracks, i)
					end
				else
					track.Weight = math.min(1, track.Weight + dt / (clip.FadeIn or 0.05))
				end
			end
		end

		for joint, motor in rig.Motors do
			local result = motor.Transform
			if rig.Last[joint] == result then
				result = IDENTITY
			end
			local rotation = motor.C0.Rotation
			local inverse = rotation:Inverse()
			for _, track in tracks do
				if track.Clip.Joints[joint] then
					local a, b, alpha = sample(track.Clip, math.min(track.Time, track.Clip.Length))
					local pose = (a[joint] or IDENTITY):Lerp(b[joint] or IDENTITY, alpha)
					result = result:Lerp(inverse * pose * rotation, math.clamp(track.Weight, 0, 1))
				end
			end
			motor.Transform = result
			rig.Last[joint] = if rig.Dirty then result else nil
		end
	end
end

if RunService:IsClient() then
	RunService.Stepped:Connect(function(_, dt)
		step(dt)
	end)
end

return Anim
