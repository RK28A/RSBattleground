import math
import os
import sys

import bpy
import bmesh
from mathutils import Vector

sys.path.insert(0, os.path.dirname(__file__))
import r6

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EXPORT = os.path.join(ROOT, "art", "export")


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def mesh_object(name, verts, faces, color, emission=0.0, uvs=None):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([r6.to_blender(v) for v in verts], [], faces)
    mesh.update()
    if uvs:
        layer = mesh.uv_layers.new(name="UVMap")
        for poly in mesh.polygons:
            for loop_index in poly.loop_indices:
                layer.data[loop_index].uv = uvs[mesh.loops[loop_index].vertex_index]
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.data.materials.append(r6.material(name + "Mat", color, emission))
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    return obj


def loft(name, sections, color, emission=0.0, cap=True):
    verts, faces = [], []
    count = len(sections[0])
    for section in sections:
        verts.extend(section)
    for s in range(len(sections) - 1):
        for i in range(count):
            a = s * count + i
            b = s * count + (i + 1) % count
            c = (s + 1) * count + (i + 1) % count
            d = (s + 1) * count + i
            faces.append((a, b, c, d))
    if cap:
        faces.append(tuple(range(count)))
        faces.append(tuple(reversed(range((len(sections) - 1) * count, len(sections) * count))))
    return mesh_object(name, verts, faces, color, emission)


def diamond(z, width, thick, y=0.0):
    return [(width / 2, y, z), (0, y + thick / 2, z), (-width / 2, y, z), (0, y - thick / 2, z)]


def ring_section(z, rx, ry, sides=10):
    return [(math.cos(i / sides * math.tau) * rx, math.sin(i / sides * math.tau) * ry, z) for i in range(sides)]


def sword():
    reset()
    steel = (0.07, 0.08, 0.12, 1)
    silver = (0.8, 0.83, 0.9, 1)
    pale = (0.72, 0.87, 1.0, 1)
    blade_sections = [
        diamond(-0.7, 0.34, 0.11),
        diamond(-1.0, 0.56, 0.13),
        diamond(-1.5, 0.44, 0.12),
        diamond(-3.6, 0.40, 0.10),
        diamond(-5.0, 0.36, 0.08),
        diamond(-5.6, 0.22, 0.06),
        diamond(-6.3, 0.01, 0.01),
    ]
    loft("Blade", blade_sections, silver)
    fuller = [diamond(z, w, t) for z, w, t in [(-1.05, 0.02, 0.15), (-1.3, 0.12, 0.16), (-3.6, 0.1, 0.13), (-5.2, 0.05, 0.1), (-5.7, 0.005, 0.07)]]
    loft("Core", fuller, pale, 6)
    grip_sections = [ring_section(z, r, r * 0.82, 12) for z, r in [(0.8, 0.12), (0.5, 0.15), (0.1, 0.13), (-0.3, 0.15), (-0.6, 0.18)]]
    loft("Grip", grip_sections, steel)
    for index, z in enumerate((0.55, 0.2, -0.15)):
        loft("Wrap%d" % index, [ring_section(z + 0.03, 0.165, 0.14, 12), ring_section(z - 0.03, 0.165, 0.14, 12)], silver)
    guard_verts, guard_faces = [], []
    steps = 16
    for i in range(steps + 1):
        t = i / steps * 2 - 1
        x = t * 1.25
        rise = 0.42 * (abs(t) ** 2.4) - 0.1 * (1 - abs(t))
        half = 0.16 * (1 - 0.8 * abs(t)) + 0.035
        thick = 0.12 * (1 - 0.55 * abs(t)) + 0.02
        z = -0.72 - rise
        guard_verts += [(x, thick, z - half), (x, thick, z + half), (x, -thick, z + half), (x, -thick, z - half)]
    for i in range(steps):
        for k in range(4):
            a2 = i * 4 + k
            b2 = i * 4 + (k + 1) % 4
            guard_faces.append((a2, b2, b2 + 4, a2 + 4))
    guard_faces.append((0, 1, 2, 3))
    guard_faces.append((steps * 4 + 3, steps * 4 + 2, steps * 4 + 1, steps * 4))
    mesh_object("Guard", guard_verts, guard_faces, silver)
    gem_verts = [(0, 0, -0.5), (0.15, 0, -0.72), (0, 0.19, -0.72), (-0.15, 0, -0.72), (0, -0.19, -0.72), (0, 0, -0.94)]
    mesh_object("Gem", gem_verts, [(0, 1, 2), (0, 2, 3), (0, 3, 4), (0, 4, 1), (5, 2, 1), (5, 3, 2), (5, 4, 3), (5, 1, 4)], pale, 6)
    torus_verts, torus_faces = [], []
    major, minor, seg, sides = 0.2, 0.055, 14, 6
    for i in range(seg):
        u = i / seg * math.tau
        for k in range(sides):
            v = k / sides * math.tau
            radius = major + minor * math.cos(v)
            torus_verts.append((math.cos(u) * radius, minor * math.sin(v), 1.02 + math.sin(u) * radius))
    for i in range(seg):
        for k in range(sides):
            a2 = i * sides + k
            b2 = i * sides + (k + 1) % sides
            c2 = ((i + 1) % seg) * sides + (k + 1) % sides
            d2 = ((i + 1) % seg) * sides + k
            torus_faces.append((a2, b2, c2, d2))
    mesh_object("Pommel", torus_verts, torus_faces, silver)


def crescent(name, radius=5.0, width=1.6, arc=150, segments=28):
    verts, faces, uvs = [], [], []
    for i in range(segments + 1):
        t = i / segments
        angle = math.radians(-arc / 2 + arc * t)
        profile = math.sin(t * math.pi) ** 0.6
        lead = 0.25 * math.sin(t * math.pi)
        outer = radius + lead
        inner = radius - width * profile
        verts.append((math.sin(angle) * outer, 0, -math.cos(angle) * outer))
        verts.append((math.sin(angle) * inner, 0, -math.cos(angle) * inner))
        uvs.append((t, 1))
        uvs.append((t, 0))
    for i in range(segments):
        a = i * 2
        faces.append((a, a + 2, a + 3, a + 1))
    return mesh_object(name, verts, faces, (0.8, 0.9, 1, 1), 3, uvs)


def ring(name, inner=0.72, segments=40):
    verts, faces, uvs = [], [], []
    for i in range(segments + 1):
        t = i / segments
        angle = t * math.tau
        verts.append((math.cos(angle), 0, math.sin(angle)))
        verts.append((math.cos(angle) * inner, 0, math.sin(angle) * inner))
        uvs.append((t, 1))
        uvs.append((t, 0))
    for i in range(segments):
        a = i * 2
        faces.append((a, a + 2, a + 3, a + 1))
    return mesh_object(name, verts, faces, (0.8, 0.9, 1, 1), 3, uvs)


def export(name):
    path = os.path.join(EXPORT, name + ".fbx")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.fbx(filepath=path, use_selection=True, apply_scale_options="FBX_SCALE_ALL", axis_forward="-Z", axis_up="Y", mesh_smooth_type="FACE")
    return path


def stats():
    return {obj.name: len(obj.data.polygons) for obj in bpy.data.objects if obj.type == "MESH"}


if __name__ == "__main__":
    sword()
    print("sword", stats(), export("SpiritBlade"))
    if "--render" in sys.argv:
        r6.setup_preview(target=(0, 0, -2.6), distance=9.5, azimuth=75, elevation=28)
        bpy.context.scene.render.resolution_x = 640
        bpy.context.scene.render.resolution_y = 420
        bpy.context.scene.cycles.samples = 24
        for obj in bpy.data.objects:
            if obj.name == "Plane":
                obj.location.z = -1.2
        bpy.context.scene.render.filepath = os.path.join(ROOT, "art", "preview", "sword.png")
        bpy.ops.render.render(write_still=True)
    reset()
    crescent("Slash")
    print("slash", stats(), export("Slash"))
    reset()
    ring("Ring")
    print("ring", stats(), export("Ring"))
