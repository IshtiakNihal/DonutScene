extends Node3D

# ══════════════════════════════════════════════════════════════
#  Donut Showcase – cinematic real-time animation
#  • Applies baked PBR textures from Blender
#  • Camera slow orbit + donut float/spin/wobble
#  • 1920×1080 @ 24fps
# ══════════════════════════════════════════════════════════════

var donut_root: Node3D = null
var cam_pivot:  Node3D = null
var camera:     Camera3D = null

const ORBIT_SPEED   := 0.35
const FLOAT_SPEED   := 0.5
const FLOAT_AMP     := 0.06
const SPIN_SPEED    := 0.55
const WOBBLE_SPEED  := 0.9
const WOBBLE_AMP    := 0.025

var _time:   float = 0.0
var _base_y: float = 0.0

# ─────────────────────────────────────────────────────────
func _ready() -> void:
	# Find donut root node (the GLB instance)
	for child in get_children():
		if child is Node3D and child.name != "CameraPivot" \
		   and child.name != "WorldEnvironment" \
		   and not child.name.begins_with("Omni") \
		   and not child.name.begins_with("Directional") \
		   and not child.name.begins_with("Key") \
		   and not child.name.begins_with("Fill") \
		   and not child.name.begins_with("Rim") \
		   and not child.name.begins_with("Under"):
			donut_root = child
			break

	cam_pivot = $CameraPivot
	camera    = $CameraPivot/Camera3D

	if donut_root:
		_base_y = donut_root.position.y
		print("[Donut] Root: ", donut_root.name,
			  " | children: ", donut_root.get_child_count())
		# Apply realistic materials
		_apply_pbr_materials(donut_root)
	else:
		push_warning("[Donut] No donut root found")

	Engine.physics_ticks_per_second = 24


# ─────────────────────────────────────────────────────────
#  MATERIAL SETUP – apply baked textures + PBR overrides
# ─────────────────────────────────────────────────────────
func _apply_pbr_materials(root: Node3D) -> void:
	# Recursively find all MeshInstance3D nodes
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(root, meshes)
	print("[Donut] Found ", meshes.size(), " mesh instances")

	for mi in meshes:
		var mesh = mi.mesh
		if mesh == null:
			continue

		for surf_idx in range(mesh.get_surface_count()):
			var mat = mesh.surface_get_material(surf_idx)
			if mat == null:
				continue

			var mat_name = mat.resource_name.to_lower()
			print("[Donut] Processing material: ", mat.resource_name)

			# Create a new StandardMaterial3D override
			var new_mat = StandardMaterial3D.new()

			if "donut" in mat_name or "base" in mat_name or "bread" in mat_name:
				_setup_donut_base_material(new_mat)
			elif "icing" in mat_name or "glaze" in mat_name or "frosting" in mat_name:
				_setup_icing_material(new_mat)
			elif "sprinkle" in mat_name or "spr" in mat_name:
				_setup_sprinkle_material(new_mat, mat)
			else:
				# Unknown material – make it look decent
				_setup_generic_material(new_mat, mat)

			mi.set_surface_override_material(surf_idx, new_mat)


func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		_collect_meshes(child, result)


# ── Donut Base (bread) ───────────────────────────────────
func _setup_donut_base_material(mat: StandardMaterial3D) -> void:
	# Load baked textures
	var color_tex = load("res://textures/donut_base_color.png")
	var rough_tex = load("res://textures/donut_base_roughness.png")
	var norm_tex  = load("res://textures/donut_base_normal.png")

	if color_tex:
		mat.albedo_texture = color_tex
	else:
		mat.albedo_color = Color(0.72, 0.45, 0.2)  # Warm bread fallback

	if rough_tex:
		mat.roughness_texture = rough_tex
		mat.roughness = 1.0  # Let texture control it
	else:
		mat.roughness = 0.75  # Bread is fairly rough

	if norm_tex:
		mat.normal_enabled = true
		mat.normal_texture = norm_tex
		mat.normal_scale = 1.5  # Boost bumps for realism

	mat.metallic = 0.0
	mat.metallic_specular = 0.4

	# Subsurface scattering approximation (backlight)
	mat.subsurf_scatter_enabled = true
	mat.subsurf_scatter_strength = 0.3
	mat.subsurf_scatter_skin_mode = true

	mat.cull_mode = BaseMaterial3D.CULL_BACK
	print("[Donut] Applied donut base material with baked textures")


# ── Icing / Frosting ────────────────────────────────────
func _setup_icing_material(mat: StandardMaterial3D) -> void:
	var color_tex = load("res://textures/donut_icing_color.png")
	var rough_tex = load("res://textures/donut_icing_roughness.png")
	var norm_tex  = load("res://textures/donut_icing_normal.png")

	if color_tex:
		mat.albedo_texture = color_tex
	else:
		mat.albedo_color = Color(0.85, 0.55, 0.65)  # Pink icing fallback

	if rough_tex:
		mat.roughness_texture = rough_tex
		mat.roughness = 1.0
	else:
		mat.roughness = 0.2  # Icing is glossy

	if norm_tex:
		mat.normal_enabled = true
		mat.normal_texture = norm_tex
		mat.normal_scale = 0.8

	mat.metallic = 0.0
	mat.metallic_specular = 0.6  # Nice specular highlights

	# Clearcoat for that wet-looking glaze
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.5
	mat.clearcoat_roughness = 0.15

	mat.cull_mode = BaseMaterial3D.CULL_BACK
	print("[Donut] Applied icing material with baked textures + clearcoat")


# ── Sprinkles ────────────────────────────────────────────
func _setup_sprinkle_material(mat: StandardMaterial3D, original: Material) -> void:
	# Keep the original color from GLB
	if original is StandardMaterial3D:
		mat.albedo_color = original.albedo_color
	else:
		# Random candy-like color
		mat.albedo_color = Color(0.9, 0.3, 0.4)

	mat.roughness = 0.25       # Candy coating is smooth
	mat.metallic = 0.0
	mat.metallic_specular = 0.5

	# Clearcoat for candy sheen
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.4
	mat.clearcoat_roughness = 0.1

	mat.cull_mode = BaseMaterial3D.CULL_BACK


# ── Generic fallback ────────────────────────────────────
func _setup_generic_material(mat: StandardMaterial3D, original: Material) -> void:
	if original is StandardMaterial3D:
		mat.albedo_color = original.albedo_color
	else:
		mat.albedo_color = Color(0.6, 0.6, 0.6)

	mat.roughness = 0.5
	mat.metallic = 0.0
	mat.metallic_specular = 0.4
	mat.cull_mode = BaseMaterial3D.CULL_BACK


# ─────────────────────────────────────────────────────────
#  RUNTIME ANIMATION
# ─────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_time += delta

	if cam_pivot:
		cam_pivot.rotation.y += ORBIT_SPEED * delta

	if donut_root == null:
		return

	donut_root.position.y = _base_y \
		+ sin(_time * TAU * FLOAT_SPEED) * FLOAT_AMP

	donut_root.rotation.y += SPIN_SPEED * delta

	donut_root.rotation.x = sin(_time * TAU * WOBBLE_SPEED) * WOBBLE_AMP
	donut_root.rotation.z = cos(_time * TAU * WOBBLE_SPEED * 0.7) * WOBBLE_AMP * 0.6
