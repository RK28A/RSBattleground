import os

import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "art", "textures")
rng = np.random.default_rng(7)


def save(name, alpha, color=(255, 255, 255)):
    alpha = np.clip(alpha, 0, 1)
    h, w = alpha.shape
    data = np.zeros((h, w, 4), dtype=np.uint8)
    data[..., 0], data[..., 1], data[..., 2] = color
    data[..., 3] = (alpha * 255).astype(np.uint8)
    Image.fromarray(data, "RGBA").save(os.path.join(OUT, name + ".png"))


def grid(size):
    axis = np.linspace(-1, 1, size)
    return np.meshgrid(axis, axis)


def noise(size, octaves=5):
    total = np.zeros((size, size))
    amplitude = 1.0
    for octave in range(octaves):
        cells = 2 ** (octave + 2)
        small = rng.random((cells + 1, cells + 1))
        img = Image.fromarray((small * 255).astype(np.uint8)).resize((size, size), Image.BICUBIC)
        total += np.asarray(img) / 255 * amplitude
        amplitude *= 0.5
    total -= total.min()
    return total / total.max()


def glow():
    x, y = grid(256)
    r = np.sqrt(x * x + y * y)
    save("Glow", np.clip(1 - r, 0, 1) ** 2.4)


def streak():
    x, y = grid(256)
    core = np.exp(-(y / 0.045) ** 2) * np.clip(1 - np.abs(x), 0, 1) ** 1.5
    halo = np.exp(-(y / 0.16) ** 2) * np.clip(1 - np.abs(x), 0, 1) ** 3 * 0.45
    save("Streak", core + halo)


def star():
    x, y = grid(256)
    r = np.sqrt(x * x + y * y)
    arms = np.exp(-(x / 0.03) ** 2) * np.clip(1 - np.abs(y), 0, 1) ** 2 + np.exp(-(y / 0.03) ** 2) * np.clip(1 - np.abs(x), 0, 1) ** 2
    save("Star", arms + np.clip(1 - r / 0.35, 0, 1) ** 2)


def smoke():
    x, y = grid(256)
    r = np.sqrt(x * x + y * y)
    n = noise(256)
    edge = np.clip(1 - (r + (n - 0.5) * 0.5) / 0.85, 0, 1)
    save("Smoke", edge ** 1.3 * (0.45 + 0.55 * n))


def slash():
    w, h = 512, 128
    u = np.linspace(0, 1, w)[None, :]
    v = np.linspace(0, 1, h)[:, None]
    n = np.asarray(Image.fromarray((noise(256) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)) / 255
    stretch = np.asarray(Image.fromarray((rng.random((h, 24)) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)) / 255
    edge = v ** 2.2
    ends = np.sin(u * np.pi) ** 0.5
    body = edge * (0.55 + 0.45 * stretch) * ends
    lead = np.exp(-((1 - v) / 0.08) ** 2) * ends
    save("Slash", np.flipud(body * (0.7 + 0.3 * n) + lead))


def ring():
    w, h = 512, 64
    v = np.linspace(0, 1, h)[:, None]
    n = np.asarray(Image.fromarray((rng.random((h, 64)) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)) / 255
    save("Ring", np.flipud((v ** 2.5) * (0.6 + 0.4 * n) + np.exp(-((1 - v) / 0.1) ** 2)))


def trail():
    w, h = 256, 64
    u = np.linspace(0, 1, w)[None, :]
    v = np.linspace(-1, 1, h)[:, None]
    n = np.asarray(Image.fromarray((rng.random((h, 32)) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)) / 255
    save("Trail", (1 - u) ** 1.4 * np.exp(-(v / 0.6) ** 2) * (0.65 + 0.35 * n))


for make in (glow, streak, star, smoke, slash, ring, trail):
    make()
print(sorted(os.listdir(OUT)))
