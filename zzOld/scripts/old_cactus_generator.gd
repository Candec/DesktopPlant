#extends PlantGenerator
#class_name CactusGenerator

@export var debug_visualization: bool = false

# Default parameters that will be overridden by the species config
var max_height: float = 3.0
var growth_speed: float = 0.01
var ring_distance: float = 0.5
var ring_thickness: float = 0.5
var vertices_per_ring: int = 20
var flower_probability: float = 0.0  # Default value, can be modified by species config


var rings := []
#var growth_progress: float = 0.0  # From 0 to 1
var growth_time_elapsed: float = 0.0  # Time passed in seconds

@onready var mesh_instance: MeshInstance3D = MeshInstance3D.new()

# This will hold the species config loaded from the JSON
var cactus_species_config: Dictionary = {}

# Load species configuration (this will be called when a species is selected)
func _load_species_config(species_name: String):
	var path = "res://plants/cactus/cactus_species.json"  # Adjust path to your actual JSON file
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(json_text)
		if parse_result.error == OK:
			cactus_species_config = parse_result.result.get(species_name, {})
			if cactus_species_config.size() > 0:
				# Apply the configuration to the cactus generator
				max_height = cactus_species_config.get("max_height", max_height)
				growth_speed = cactus_species_config.get("growth_speed", growth_speed)
				ring_distance = cactus_species_config.get("ring_distance", ring_distance)
				ring_thickness = cactus_species_config.get("ring_thickness", ring_thickness)
				vertices_per_ring = cactus_species_config.get("vertices_per_ring", vertices_per_ring)
				flower_probability = cactus_species_config.get("flower_probability", 0.0)
		else:
			push_error("Error parsing cactus species configuration for " + species_name)
	else:
		push_error("Error opening species config file")

# Called when the plant is generated
func generate_plant(species_name: String):
	_load_species_config(species_name)  # Load species-specific settings
	_generate_structure()  # Generate the cactus structure
	_update_growth(growth_progress)  # Initialize growth

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

	if debug_visualization:
		_draw_debug_geometry()

func _create_ring(pos: Vector3) -> Dictionary:
	var ring = {
		"center": pos,
		"radius": 0.0
	}
	return ring

func _get_ring_vertices(ring: Dictionary) -> Array:
	var verts = []
	var center = ring.center
	var radius = ring.radius
	for i in range(vertices_per_ring):
		var angle = (2.0 * PI * i) / vertices_per_ring
		verts.append(Vector3(center.x + cos(angle) * radius, center.y, center.z + sin(angle) * radius))
	return verts

func _process(delta: float) -> void:
	if growth_progress < 1.0:
		growth_time_elapsed += delta * growth_speed
		growth_progress = clamp(growth_time_elapsed / max_height, 0.0, 1.0)

		_update_growth(growth_progress)
