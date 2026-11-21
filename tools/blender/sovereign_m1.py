import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
import r6

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def slash_one(nodes):
    k = lambda joint, t, a=None, o=None: r6.key(nodes, joint, t, a, o)
    k("Torso", 0.00, (0, 0, 0), (0, 0, 0))
    k("Torso", 0.07, (6, -38, -4), (0, -0.12, 0.1))
    k("Torso", 0.10, (5, -42, -5), (0, -0.16, 0.12))
    k("Torso", 0.15, (-12, 34, 5), (0, -0.2, -0.3))
    k("Torso", 0.21, (-14, 46, 6), (0, -0.22, -0.36))
    k("Torso", 0.32, (-8, 30, 3), (0, -0.14, -0.24))
    k("Torso", 0.46, (0, 0, 0), (0, 0, 0))

    k("Head", 0.00, (0, 0, 0))
    k("Head", 0.08, (-2, 30, 2))
    k("Head", 0.16, (8, -22, -3))
    k("Head", 0.24, (6, -32, -3))
    k("Head", 0.36, (3, -18, -1))
    k("Head", 0.46, (0, 0, 0))

    k("RA", 0.00, (0, 0, 6))
    k("RA", 0.06, (120, 0, 30))
    k("RA", 0.11, (168, -10, 42))
    k("RA", 0.14, (96, 0, -8))
    k("RA", 0.17, (40, 10, -46))
    k("RA", 0.23, (18, 14, -58))
    k("RA", 0.34, (22, 8, -34))
    k("RA", 0.46, (0, 0, 6))

    k("Weapon", 0.00, (0, 0, 0))
    k("Weapon", 0.08, (-28, 0, 0))
    k("Weapon", 0.12, (-46, 0, 10))
    k("Weapon", 0.15, (10, 0, 0))
    k("Weapon", 0.19, (38, 0, -8))
    k("Weapon", 0.27, (22, 0, -4))
    k("Weapon", 0.38, (6, 0, 0))
    k("Weapon", 0.46, (0, 0, 0))

    k("LA", 0.00, (0, 0, -6))
    k("LA", 0.08, (34, 0, -30))
    k("LA", 0.12, (40, 0, -34))
    k("LA", 0.17, (-34, 0, -26))
    k("LA", 0.25, (-48, 0, -32))
    k("LA", 0.37, (-20, 0, -16))
    k("LA", 0.46, (0, 0, -6))

    k("RL", 0.00, (0, 0, 0))
    k("RL", 0.09, (-16, 0, 4))
    k("RL", 0.16, (-26, 0, 2))
    k("RL", 0.24, (-24, 0, 2))
    k("RL", 0.36, (-12, 0, 0))
    k("RL", 0.46, (0, 0, 0))

    k("LL", 0.00, (0, 0, 0))
    k("LL", 0.09, (10, 0, -4))
    k("LL", 0.15, (26, 0, -4))
    k("LL", 0.22, (30, 0, -4))
    k("LL", 0.34, (18, 0, -2))
    k("LL", 0.46, (0, 0, 0))
    return 0.46


def main():
    nodes = r6.build_rig()
    length = slash_one(nodes)
    r6.fix_quaternion_flips(nodes)
    r6.smooth_location(nodes)
    data = r6.bake(nodes, length)
    r6.write_luau(os.path.join(ROOT, "src", "shared", "Anim", "Baked.luau"), {
        "Blade1": {"length": length, "data": data, "options": {"FadeIn": "0.03", "FadeOut": "0.12"}},
    })
    if "--render" in sys.argv:
        r6.setup_preview()
        prefix = os.path.join(ROOT, "art", "preview", "blade1")
        times = [0.0, 0.07, 0.11, 0.135, 0.16, 0.21, 0.30, 0.40]
        paths = r6.render_frames(times, prefix)
        sheet = os.path.join(ROOT, "art", "preview", "blade1_sheet.png")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-pattern_type", "glob", "-i", prefix + "_*.png", "-filter_complex", "tile=4x2", sheet], check=True)
        for path in paths:
            os.remove(path)
        print("sheet", sheet)
    print("frames", {joint: len(frames) for joint, frames in data.items()})


main()
