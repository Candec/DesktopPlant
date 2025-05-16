class_name RingData
extends RefCounted

var center: Vector3
var radius: float
var tilt: float
var thickness: float
var progress: float = 0.0
var segments_per_point: int = 1
var valley_depth: float = 0.1
var active: bool = true
var target_y: float = 0.0
var twist_offset: float = 0.0  # in radians
var start_y: float
var index: int
var normalized_index: float  # 0.0 = bottom, 1.0 = top


func get_vertices(vertices_count: int) -> Array[Vector3]:
	var verts: Array[Vector3] = []

	var points = vertices_count
	var star_frequency = points / (segments_per_point + 1)

	for i in range(points):
		var angle = i * TAU / float(points) + twist_offset
		var base_radius = radius

		# Calculate star modulation
		var star_pos = sin(angle * star_frequency)
		var modulation = 1.0 - valley_depth * abs(star_pos)
		var modulated_radius = base_radius * modulation

		var x = modulated_radius * cos(angle)
		var z = modulated_radius * sin(angle)

		var rotated = Vector3(x, 0, z).rotated(Vector3(0, 0, 1), deg_to_rad(tilt))
		verts.append(center + rotated)
	return verts
