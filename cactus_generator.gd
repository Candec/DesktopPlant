extends Node3D

@export var ring_growth_speed: float = 1.0
@export var ring_thickness: float = 0.5
@export var ring_distance: float = 0.5
@export var ring_tilt: float = 0.0
@export var thickness_variance: float = 0.1
@export var distance_variance: float = 0.1
@export var tilt_variance: float = 5.0
@export var max_height: float = 10.0
@export var vertices_per_ring: int = 8
@export var branch_chance: float = 0.1
@export var branch_angle_range: float = 30.0
@export var flower_probability: float = 0.3


var rings := []
var branches := []
var flowers := []
var cactus_height := 0.0
var is_paused := false

@onready var mesh_instance: MeshInstance3D = $CactusMesh

const RingData = preload("res://RingData.gd")


func _ready():
	_spawn_initial_rings()

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
	rings.append(_create_ring(Vector3.ZERO))
	rings.append(_create_ring(Vector3(0, ring_distance, 0), true))

func _create_ring(pos: Vector3, delay := false) -> RingData:
	var ring := RingData.new()
	ring.center = pos
	ring.radius = 0.0
	ring.thickness = ring_thickness + randf_range(-thickness_variance, thickness_variance)
	ring.tilt = ring_tilt + randf_range(-tilt_variance, tilt_variance)
	# Ring start position
	#ring.progress = 0.0 if delay else 0.0
	ring.progress = 0.0
	return ring

func _update_ring_growth(delta: float):
	for ring in rings:
		ring.progress += delta * ring_growth_speed
		if ring.progress > 1.0:
			ring.progress = 1.0
		ring.radius = ring.progress * ring.thickness

	if rings[-1].progress >= 0.5:
		var next_pos = rings[-1].center + Vector3(0, ring_distance + randf_range(-distance_variance, distance_variance), 0)
		if cactus_height + ring_distance < max_height:
			rings.append(_create_ring(next_pos, true))
			cactus_height += ring_distance
			if randf() < branch_chance:
				_spawn_branch_from(rings[-1])

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
		var r1 = rings[i].get_vertices(vertices_per_ring)
		var r2 = rings[i + 1].get_vertices(vertices_per_ring)
		for j in range(vertices_per_ring):
			var n = (j + 1) % vertices_per_ring
			st.add_vertex(r1[j])
			st.add_vertex(r2[n])
			st.add_vertex(r2[j])
			st.add_vertex(r1[j])
			st.add_vertex(r1[n])
			st.add_vertex(r2[n])
	mesh_instance.mesh = st.commit()

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
