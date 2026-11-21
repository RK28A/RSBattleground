import math
import bpy
from mathutils import Quaternion, Vector, Matrix, Euler

FPS = 60

JOINTS = {
    "Torso": {"parent": None, "pivot": (0, 0, 0), "center": (0, 0, 0), "size": (2, 2, 1)},
    "Head": {"parent": "Torso", "pivot": (0, 1, 0), "center": (0, 0.5, 0), "size": (1.2, 1.2, 1.2)},
    "RA": {"parent": "Torso", "pivot": (1, 0.5, 0), "center": (0.5, -0.5, 0), "size": (1, 2, 1)},
    "LA": {"parent": "Torso", "pivot": (-1, 0.5, 0), "center": (-0.5, -0.5, 0), "size": (1, 2, 1)},
    "RL": {"parent": "Torso", "pivot": (1, -1, 0), "center": (-0.5, -1, 0), "size": (1, 2, 1)},
    "LL": {"parent": "Torso", "pivot": (-1, -1, 0), "center": (0.5, -1, 0), "size": (1, 2, 1)},
    "Weapon": {"parent": "RA", "pivot": (0.5, -1.5, 0), "center": None, "size": None},
}

COLORS = {
    "Torso": (0.10, 0.12, 0.20, 1),
    "Head": (0.85, 0.75, 0.65, 1),
    "RA": (0.85, 0.75, 0.65, 1),
    "LA": (0.85, 0.75, 0.65, 1),
    "RL": (0.16, 0.18, 0.26, 1),
    "LL": (0.16, 0.18, 0.26, 1),
}


def to_blender(v):
    return Vector((v[0], -v[2], v[1]))


def to_roblox(v):
    return (v[0], v[2], -v[1])


def quat_from_roblox_angles(x, y, z):
    rx = Quaternion((1, 0, 0), math.radians(x))
    ry = Quaternion((0, 1, 0), math.radians(y))
    rz = Quaternion((0, 0, 1), math.radians(z))
    q = rx @ ry @ rz
    axis = to_blender((q.x, q.y, q.z))
    return Quaternion((q.w, axis.x, axis.y, axis.z))


def material(name, color, emission=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = 0.6
    if emission > 0:
        bsdf.inputs["Emission Color"].default_value = color
        bsdf.inputs["Emission Strength"].default_value = emission
    return mat


def box(name, size, location, parent, color):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = Vector((size[0], size[2], size[1]))
    obj.parent = parent
    obj.location = to_blender(location)
    obj.data.materials.append(material(name + "Mat", color))
    return obj


def build_rig(with_weapon=True):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = FPS
    nodes = {}
    root = bpy.data.objects.new("HRP", None)
    scene.collection.objects.link(root)
    nodes["HRP"] = root
    for name, spec in JOINTS.items():
        node = bpy.data.objects.new(name, None)
        node.empty_display_size = 0.3
        scene.collection.objects.link(node)
        node.parent = nodes[spec["parent"]] if spec["parent"] else root
        node.location = to_blender(spec["pivot"])
        node.rotation_mode = "QUATERNION"
        nodes[name] = node
        if spec["size"]:
            box(name + "Mesh", spec["size"], spec["center"], node, COLORS[name])
    if with_weapon:
        build_sword(nodes["Weapon"])
    return nodes


def build_sword(parent):
    steel = (0.13, 0.15, 0.2, 1)
    pale = (0.77, 0.89, 1.0, 1)
    parts = [
        ("Grip", (0.24, 0.24, 1.1), (0, 0, 0.1), steel, 0),
        ("Guard", (1.5, 0.16, 0.2), (0, 0, -0.55), steel, 0),
        ("Blade", (0.34, 0.07, 4.4), (0, 0, -2.9), pale, 3),
    ]
    for name, size, location, color, emission in parts:
        bpy.ops.mesh.primitive_cube_add(size=1)
        obj = bpy.context.active_object
        obj.name = "Sword" + name
        obj.scale = Vector((size[0], size[2], size[1]))
        obj.parent = parent
        obj.location = to_blender(location)
        obj.data.materials.append(material(name + "Mat", color, emission))


def key(nodes, joint, time, angles=None, offset=None, handle="AUTO_CLAMPED"):
    node = nodes[joint]
    frame = time * FPS
    if angles is not None:
        node.rotation_quaternion = quat_from_roblox_angles(*angles)
        node.keyframe_insert("rotation_quaternion", frame=frame)
    if offset is not None:
        node.location = to_blender(JOINTS[joint]["pivot"]) + to_blender(offset)
        node.keyframe_insert("location", frame=frame)
    return handle


def iter_fcurves(action):
    if hasattr(action, "fcurves") and len(getattr(action, "fcurves", [])):
        yield from action.fcurves
        return
    for layer in getattr(action, "layers", []):
        for strip in layer.strips:
            for bag in strip.channelbags:
                yield from bag.fcurves


def fix_quaternion_flips(nodes):
    for node in nodes.values():
        if not node.animation_data or not node.animation_data.action:
            continue
        curves = [c for c in iter_fcurves(node.animation_data.action) if c.data_path == "rotation_quaternion"]
        if len(curves) != 4:
            continue
        curves.sort(key=lambda c: c.array_index)
        count = len(curves[0].keyframe_points)
        previous = None
        for i in range(count):
            q = [curves[k].keyframe_points[i].co[1] for k in range(4)]
            if previous and sum(a * b for a, b in zip(q, previous)) < 0:
                for k in range(4):
                    curves[k].keyframe_points[i].co[1] = -q[k]
                q = [-v for v in q]
            previous = q
        for curve in curves:
            for point in curve.keyframe_points:
                point.interpolation = "BEZIER"
                point.handle_left_type = "AUTO_CLAMPED"
                point.handle_right_type = "AUTO_CLAMPED"
            curve.update()


def smooth_location(nodes):
    for node in nodes.values():
        if not node.animation_data or not node.animation_data.action:
            continue
        for curve in iter_fcurves(node.animation_data.action):
            if curve.data_path == "location":
                for point in curve.keyframe_points:
                    point.interpolation = "BEZIER"
                    point.handle_left_type = "AUTO_CLAMPED"
                    point.handle_right_type = "AUTO_CLAMPED"
                curve.update()


def bake(nodes, length):
    scene = bpy.context.scene
    frames = int(round(length * FPS))
    data = {}
    for joint in JOINTS:
        node = nodes[joint]
        if not node.animation_data or not node.animation_data.action:
            continue
        data[joint] = []
    rest = {joint: to_blender(JOINTS[joint]["pivot"]) for joint in JOINTS}
    for frame in range(frames + 1):
        scene.frame_set(frame)
        for joint in data:
            node = nodes[joint]
            q = node.rotation_quaternion.normalized()
            offset = node.location - rest[joint]
            px, py, pz = to_roblox(offset)
            qx, qy, qz = to_roblox((q.x, q.y, q.z))
            data[joint].append((px, py, pz, qx, qy, qz, q.w))
    return data


def write_luau(path, clips):
    def number(value):
        text = f"{value:.4f}".rstrip("0").rstrip(".")
        return "0" if text in ("-0", "") else text

    lines = ["return {"]
    for name, clip in clips.items():
        lines.append(f"\t{name} = {{")
        lines.append(f"\t\tFps = {FPS},")
        lines.append(f"\t\tLength = {number(clip['length'])},")
        for option, value in clip.get("options", {}).items():
            lines.append(f"\t\t{option} = {value},")
        lines.append("\t\tFrames = {")
        for joint, frames in clip["data"].items():
            rows = ", ".join("{" + ", ".join(number(v) for v in frame) + "}" for frame in frames)
            lines.append(f"\t\t\t{joint} = {{ {rows} }},")
        lines.append("\t\t},")
        lines.append("\t},")
    lines.append("}")
    with open(path, "w") as handle:
        handle.write("\n".join(lines) + "\n")


def setup_preview(target=(0, -0.3, 0), distance=13, azimuth=35, elevation=12):
    scene = bpy.context.scene
    camera_data = bpy.data.cameras.new("Cam")
    camera = bpy.data.objects.new("Cam", camera_data)
    scene.collection.objects.link(camera)
    az, el = math.radians(azimuth), math.radians(elevation)
    look = to_blender(target)
    camera.location = look + Vector((distance * math.sin(az) * math.cos(el), distance * math.cos(az) * math.cos(el), distance * math.sin(el)))
    direction = look - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera_data.lens = 50
    scene.camera = camera
    sun_data = bpy.data.lights.new("Sun", "SUN")
    sun_data.energy = 3
    sun = bpy.data.objects.new("Sun", sun_data)
    sun.rotation_euler = Euler((math.radians(50), 0, math.radians(30)))
    scene.collection.objects.link(sun)
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, -3))
    bpy.context.active_object.data.materials.append(material("Floor", (0.32, 0.33, 0.36, 1)))
    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.6, 0.7, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.9
    scene.world = world
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 12
    scene.cycles.use_denoising = False
    scene.render.resolution_x = 360
    scene.render.resolution_y = 360


def render_frames(times, prefix):
    scene = bpy.context.scene
    paths = []
    for index, time in enumerate(times):
        scene.frame_set(int(round(time * FPS)))
        scene.render.filepath = f"{prefix}_{index:02d}.png"
        bpy.ops.render.render(write_still=True)
        paths.append(scene.render.filepath)
    return paths
