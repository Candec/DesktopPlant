extends Node3D

@export var cactus_growth_speed: float = 0.005  # Overall growth speed of the cactus
@export var ring_growth_speed: float = 1.0
@export var ring_rise_speed: float = 0.005
@export var ring_thickness: float = 0.5
@export var ring_distance: float = 0.5
@export var ring_tilt: float = 0.0
@export var thickness_variance: float = 0.05
@export var distance_variance: float = 0.002
@export var tilt_variance: float = 0.0
@export var max_height: float = 3.0
@export var vertices_per_ring: int = 20
@export var branch_chance: float = 0.1
@export var branch_angle_range: float = 0.0
@export var flower_probability: float = 0.0
@export var segments_per_point: int = 4
@export var valley_depth: float = 0.4
@export var twist_enabled: bool = false
@export var twist_amount: float = 15.0  # degrees per ring
@export var taper_top_enabled: bool = false
@export var taper_start_ratio: float = 0.85  # start tapering after 85% height

@export_category("time")
@export var total_growth_duration: float = 300.0  # Total time in seconds to fully grow
@export var growth_speed_multiplier: float = 1.0  # Adjust at runtime for debugging or slow growth

var growth_time_elapsed := 0.0
var growth_progress := 0.0  # Ranges from 0.0 to 1.0


var rings := []
var branches := []
var flowers := []
var cactus_height := 0.0
var is_paused := false

@onready var mesh_instance: MeshInstance3D = $CactusMesh

const RingData = preload("res://scripts/RingData.gd")

# --- Preloaded Shaders ---
var ridge_shader := preload("res://shaders/ridge_shader.gdshader")
var cell_shader := preload("res://shaders/cell_shader.gdshader")
var pixel_shader := preload("res://shaders/pixel_shader.gdshader")
var cartoon_shader := preload("res://shaders/cartoon_shader.gdshader")

# --- Materials for each style ---
var ridge_mat := ShaderMaterial.new()
var cell_mat := ShaderMaterial.new()
var pixel_mat := ShaderMaterial.new()
var cartoon_mat := ShaderMaterial.new()

func _ready():
	_spawn_initial_rings()
	ridge_mat.shader = ridge_shader
	cell_mat.shader = cell_shader
	pixel_mat.shader = pixel_shader
	cartoon_mat.shader = cartoon_shader
	
	# Default material at start
	$CactusMesh.material_override = ridge_mat

func _process(delta):
	if is_paused or cactus_height >= max_height:
		return
	_update_ring_growth(delta)
	_generate_mesh()
	_draw_debug()

func _spawn_initial_rings():
	rings.clear()
	branches.clear()
	flowers.clear()
	cactus_height = 0.0

	var current_height := 0.0
	var ring_count := 0

	while current_height <= max_height:
		var pos = Vector3(0, current_height, 0)
		var ring = _create_ring(pos)
		ring.index = ring_count
		rings.append(ring)

		current_height += ring_distance + randf_range(-distance_variance, distance_variance)
		ring_count += 1

	# Assign normalized_index after ring count is known
	for i in range(rings.size()):
		#rings[i].normalized_index = float(i) / float(rings.size() - 1)
		var ring = rings[i]
		ring.index = i
		ring.normalized_index = float(i) / max(rings.size() - 1, 1)


func _create_ring(pos: Vector3, delay := false) -> RingData:
	var ring = RingData.new()
	ring.center = pos
	ring.radius = 0.0
	ring.thickness = ring_thickness + randf_range(-thickness_variance, thickness_variance)
	ring.tilt = ring_tilt + randf_range(-tilt_variance, tilt_variance)
	ring.progress = 0.0
	ring.active = true
	ring.start_y = pos.y - ring_distance # Underground start (can tweak multiplier)
	ring.target_y = pos.y + ring_distance * 2
	ring.center.y = ring.start_y  # Start visually lower
	ring.segments_per_point = segments_per_point

	# Gradual tapering as the cactus grows
	var height_ratio = cactus_height / max_height
	if height_ratio > 0.85:  # Start tapering after 85% height
		var taper_factor = 1.0 - (height_ratio - 0.85) * 4.0  # Reduce radius at the top
		ring.radius *= taper_factor

	# Smoothly reduce the valley depth at the top
	if height_ratio > 0.85:
		var fade = inverse_lerp(0.85, 1.0, height_ratio)
		ring.valley_depth = valley_depth * (1.0 - fade)
	else:
		ring.valley_depth = valley_depth
	
	if twist_enabled:
		ring.twist_offset = deg_to_rad(rings.size() * twist_amount)

	return ring


func _update_ring_growth(delta: float):
	growth_time_elapsed += delta * growth_speed_multiplier
	growth_progress = clamp(growth_time_elapsed / total_growth_duration, 0.0, 1.0)

	var full_ring_count := int(growth_progress * rings.size())
	var fractional_part := growth_progress * rings.size() - full_ring_count

	for ring in rings:
		var index = ring.index
		var ring_start = ring.normalized_index * 0.99
		var ring_end = ring_start + 0.25
		var t = inverse_lerp(ring_start, ring_end, growth_progress)
		t = clamp(t, 0.0, 1.0)

		var eased = ease(t, -2.0)  # optional ease-in

		ring.progress = eased
		#ring.progress = t
		ring.radius = ring.progress * ring.thickness
		ring.center.y = lerp(ring.start_y, ring.target_y, eased)




func _spawn_branch_from(base_ring: RingData):
	var angle = randf_range(-branch_angle_range, branch_angle_range)
	var direction = Vector3(sin(deg_to_rad(angle)), 0.5, cos(deg_to_rad(angle))).normalized()
	var branch_pos = base_ring.center + direction * ring_distance
	var ring = _create_ring(branch_pos)
	ring.tilt = angle
	branches.append(ring)
	rings.append(ring)
	if randf() < flower_probability:
		_spawn_flower(branch_pos + Vector3(0, 0.2, 0))

func _spawn_flower(pos: Vector3):
	var flower = MeshInstance3D.new()
	flower.mesh = SphereMesh.new()
	flower.scale = Vector3(0.1, 0.1, 0.1)
	flower.translation = pos
	flowers.append(flower)
	add_child(flower)

func _generate_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(rings.size() - 1):
		var ring1 = rings[i].get_vertices(vertices_per_ring)
		var ring2 = rings[i + 1].get_vertices(vertices_per_ring)

		for j in range(vertices_per_ring):
			var next = (j + 1) % vertices_per_ring

			# Triangle 1
			st.add_vertex(ring2[j])
			st.add_vertex(ring1[j])
			st.add_vertex(ring2[next])

			# Triangle 2
			st.add_vertex(ring2[next])
			st.add_vertex(ring1[j])
			st.add_vertex(ring1[next])

	var mesh = st.commit()
	$CactusMesh.mesh = mesh

func save_cactus(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line("CactusConfig")
	file.store_line("rings=%d" % rings.size())
	for ring in rings:
		file.store_line("ring:%.3f,%.3f,%.3f,%.3f" % [ring.center.y, ring.radius, ring.thickness, ring.tilt])
	file.store_line("branches=%d" % branches.size())
	for b in branches:
		file.store_line("branch:%.3f,%.3f,%.3f,%.3f" % [b.center.y, b.radius, b.thickness, b.tilt])
	file.store_line("flowers=%d" % flowers.size())
	for f in flowers:
		file.store_line("flower:%.3f,%.3f,%.3f" % [f.translation.x, f.translation.y, f.translation.z])
	file.close()

func load_cactus(path: String):
	rings.clear()
	branches.clear()
	flowers.clear()
	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		if line.begins_with("ring:"):
			var d = line.replace("ring:", "").split(",")
			var ring = RingData.new()
			ring.center = Vector3(0, float(d[0]), 0)
			ring.radius = float(d[1])
			ring.thickness = float(d[2])
			ring.tilt = float(d[3])
			ring.progress = 1.0
			rings.append(ring)
		elif line.begins_with("branch:"):
			var d = line.replace("branch:", "").split(",")
			var ring = RingData.new()
			ring.center = Vector3(0, float(d[0]), 0)
			ring.radius = float(d[1])
			ring.thickness = float(d[2])
			ring.tilt = float(d[3])
			ring.progress = 1.0
			branches.append(ring)
			rings.append(ring)
		elif line.begins_with("flower:"):
			var d = line.replace("flower:", "").split(",")
			var pos = Vector3(float(d[0]), float(d[1]), float(d[2]))
			_spawn_flower(pos)
	file.close()
	_generate_mesh()

func toggle_pause():
	is_paused = not is_paused

func restart_growth():
	_spawn_initial_rings()
	_generate_mesh()
	
func _clear_flower_nodes():
	for child in get_children():
		if child is MeshInstance3D and child.name.begins_with("Flower"):
			remove_child(child)
			child.queue_free()

# Debug Menu
func reset():
	rings.clear()
	branches.clear()
	flowers.clear()
	cactus_height = 0.0
	_clear_flower_nodes()
	_spawn_initial_rings()
	
func _draw_debug():
	var mesh = ImmediateMesh.new()
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for i in range(rings.size() - 1):
		var ring1 = rings[i].get_vertices(vertices_per_ring)
		var ring2 = rings[i + 1].get_vertices(vertices_per_ring)
		
		for j in range(vertices_per_ring):
			var next = (j + 1) % vertices_per_ring

			# Ring edges
			mesh.surface_add_vertex(ring1[j])
			mesh.surface_add_vertex(ring1[next])

			mesh.surface_add_vertex(ring2[j])
			mesh.surface_add_vertex(ring2[next])

			# Vertical lines between rings
			mesh.surface_add_vertex(ring1[j])
			mesh.surface_add_vertex(ring2[j])
	
	mesh.surface_end()
	$DebugVisualizer.mesh = mesh

func set_cactus_material(mat: ShaderMaterial):
	$CactusMesh.material_override = mat
