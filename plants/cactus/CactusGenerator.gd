extends PlantGenerator
class_name BaseCactusGenerator

@export var debug_visualization: bool = false

var max_height: float = 3.0
var growth_speed: float = 0.01
var ring_distance: float = 0.5
var ring_thickness: float = 0.5
var vertices_per_ring: int = 20

var rings := []

@onready var mesh_instance: MeshInstance3D = MeshInstance3D.new()

func _ready():
	add_child(mesh_instance)
	generate_plant()

func _load_species_config():
	max_height = species_config.get("max_height", max_height)
	growth_speed = species_config.get("growth_speed", growth_speed)
	ring_distance = species_config.get("ring_distance", ring_distance)
	ring_thickness = species_config.get("ring_thickness", ring_thickness)
	vertices_per_ring = species_config.get("vertices_per_ring", vertices_per_ring)

func _generate_structure():
	rings.clear()
	var current_height := 0.0
	while current_height <= max_height:
		rings.append(_create_ring(Vector3(0, current_height, 0)))
		current_height += ring_distance

func _update_growth(progress: float):
	growth_progress = progress
	var full_rings = int(progress * rings.size())
	for i in range(rings.size()):
		rings[i].radius = ring_thickness if i <= full_rings else 0.0
	_generate_mesh()

func _generate_mesh():
	# Generación de mesh básica con anillos (puedes mejorar con shaders y detalles)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(rings.size() - 1):
		var ring1 = _get_ring_vertices(rings[i])
		var ring2 = _get_ring_vertices(rings[i + 1])
		for j in range(vertices_per_ring):
			var next = (j + 1) % vertices_per_ring

			st.set_uv(Vector2(j / vertices_per_ring, i / rings.size()))
			st.add_vertex(ring2[j])
			st.set_uv(Vector2(j / vertices_per_ring, (i + 1) / rings.size()))
			st.add_vertex(ring1[j])
			st.set_uv(Vector2((j + 1) / vertices_per_ring, i / rings.size()))
			st.add_vertex(ring2[next])

			st.set_uv(Vector2((j + 1) / vertices_per_ring, i / rings.size()))
			st.add_vertex(ring2[next])
			st.set_uv(Vector2(j / vertices_per_ring, (i + 1) / rings.size()))
			st.add_vertex(ring1[j])
			st.set_uv(Vector2((j + 1) / vertices_per_ring, (i + 1) / rings.size()))
			st.add_vertex(ring1[next])
	st.generate_normals()
	mesh_instance.mesh = st.commit()
	
	if debug_visualization:
		_draw_debug_geometry()


func _create_ring(pos: Vector3) -> Dictionary:
	return {
		"center": pos,
		"radius": 0.0
	}

func _get_ring_vertices(ring: Dictionary) -> Array:
	var verts = []
	var center = ring.center
	var radius = ring.radius
	for i in range(vertices_per_ring):
		var angle = (2.0 * PI * i) / vertices_per_ring
		verts.append(Vector3(center.x + cos(angle) * radius, center.y, center.z + sin(angle) * radius))
	return verts

var debug_mesh_instance: ImmediateMesh = null

func set_debug_visualization(value: bool) -> void:
	debug_visualization = value
	if debug_visualization:
		_draw_debug_geometry()
	else:
		if debug_mesh_instance:
			debug_mesh_instance.clear()

func _draw_debug_geometry():
	if debug_mesh_instance == null:
		debug_mesh_instance = ImmediateMesh.new()
		var debug_mesh_instance_node = MeshInstance3D.new()
		debug_mesh_instance_node.name = "DebugVisualizer"
		debug_mesh_instance_node.mesh = debug_mesh_instance
		add_child(debug_mesh_instance_node)

	debug_mesh_instance.clear_surfaces()
	debug_mesh_instance.surface_begin(Mesh.PRIMITIVE_LINES)

	# Ejemplo: dibuja líneas entre los vértices de los anillos
	for i in range(rings.size() - 1):
		var ring1 = _get_ring_vertices(rings[i])
		var ring2 = _get_ring_vertices(rings[i + 1])
		for j in range(vertices_per_ring):
			var next = (j + 1) % vertices_per_ring

			debug_mesh_instance.surface_add_vertex(ring1[j])
			debug_mesh_instance.surface_add_vertex(ring1[next])

			debug_mesh_instance.surface_add_vertex(ring2[j])
			debug_mesh_instance.surface_add_vertex(ring2[next])

			debug_mesh_instance.surface_add_vertex(ring1[j])
			debug_mesh_instance.surface_add_vertex(ring2[j])

	debug_mesh_instance.surface_end()
