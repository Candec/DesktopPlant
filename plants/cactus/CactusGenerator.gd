extends PlantGenerator
class_name CactusGenerator

@export var debug_visualization: bool = false

var max_height: float = 3.0
var growth_speed: float = 0.01
var ring_distance: float = 0.5
var ring_thickness: float = 0.5
var vertices_per_ring: int = 20

var rings := []  # Declaring rings in the child class
var growth_time_elapsed: float = 0.0

@onready var mesh_instance: MeshInstance3D = MeshInstance3D.new()

# Generate the cactus plant based on the species' config
func generate_plant():
	self.species_name = species_name
	_load_species_config()  # Load the species-specific config
	_generate_structure()  # Generate the cactus structure
	_update_growth(growth_progress)  # Start growth with initial progress

# Method to load species configuration from JSON
func _load_species_config():
	var path = "res://plants/cactus/cactus_species.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(json_text)
		if parse_result.size() != 0:
			# TODO No estoy cargando bien Cactus_Species_Config
			var cactus_species_config = parse_result.get(species_name, {})
			print(cactus_species_config)
			if cactus_species_config.size() > 0:
				max_height = cactus_species_config.get("max_height", max_height)
				growth_speed = cactus_species_config.get("growth_speed", growth_speed)
				ring_distance = cactus_species_config.get("ring_distance", ring_distance)
				ring_thickness = cactus_species_config.get("ring_thickness", ring_thickness)
				vertices_per_ring = cactus_species_config.get("vertices_per_ring", vertices_per_ring)
		else:
			push_error("Error parsing cactus species configuration for " + species_name)
	else:
		push_error("Error opening species config file")


# Generate cactus rings and add them to the rings list
func _generate_structure():
	rings.clear()
	var current_height := 0.0
	while current_height <= max_height:
		rings.append(_create_ring(Vector3(0, current_height, 0)))
		current_height += ring_distance

# Update growth based on the growth progress
# TODO Mesh is not being drawn right now. Need to discover why
func _update_growth(progress: float):
	growth_progress = progress
	var full_rings = int(progress * rings.size())
	for i in range(rings.size()):
		rings[i].radius = ring_thickness if i <= full_rings else 0.0
	_generate_mesh()

# Generate the mesh based on the rings data
func _generate_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(rings.size() - 1):
		var ring1 = _get_ring_vertices(rings[i])
		var ring2 = _get_ring_vertices(rings[i + 1])
		for j in range(vertices_per_ring):
			var next = (j + 1) % vertices_per_ring
			st.add_vertex(ring2[j])
			st.add_vertex(ring1[j])
			st.add_vertex(ring2[next])

			st.add_vertex(ring2[next])
			st.add_vertex(ring1[j])
			st.add_vertex(ring1[next])

	st.generate_normals()
	mesh_instance.mesh = st.commit()
	
	# ✅ Add a basic material for visibility
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 1.0, 0.5)  # Light green cactus color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Optional, helps show inside faces
	mesh_instance.material_override = mat

	if debug_visualization:
		_draw_debug_geometry()

# Helper function to create a ring
# TODO The rings right now are completly circular, and require of more parameters and logic to create the ridges
func _create_ring(pos: Vector3) -> Dictionary:
	return {
		"center": pos,
		"radius": 0.0
	}

# Helper function to get vertices for each ring
func _get_ring_vertices(ring: Dictionary) -> Array:
	var verts = []
	var center = ring.center
	var radius = ring.radius
	for i in range(vertices_per_ring):
		var angle = (2.0 * PI * i) / vertices_per_ring
		verts.append(Vector3(center.x + cos(angle) * radius, center.y, center.z + sin(angle) * radius))
	return verts

# Debug function to visualize the growth (optional)
func _draw_debug_geometry():
	if debug_mesh_instance == null:
		debug_mesh_instance = ImmediateMesh.new()
		var debug_mesh_instance_node = MeshInstance3D.new()
		debug_mesh_instance_node.name = "DebugVisualizer"
		debug_mesh_instance_node.mesh = debug_mesh_instance
		add_child(debug_mesh_instance_node)

	debug_mesh_instance.clear_surfaces()
	debug_mesh_instance.surface_begin(Mesh.PRIMITIVE_LINES)

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

func _ready() -> void:
	add_child(mesh_instance)
	generate_plant()

# Process function to handle growth over time
# TODO Growth is done by intervals instead of a constante continious growth
func _process(delta: float) -> void:
	if growth_progress < 1.0:
		growth_time_elapsed += delta * growth_speed
		growth_progress = clamp(growth_time_elapsed / max_height, 0.0, 1.0)
		_update_growth(growth_progress)
