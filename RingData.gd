class_name RingData
extends RefCounted

var center: Vector3
var radius: float
var tilt: float
var thickness: float
var progress: float = 0.0

func get_vertices(vertices_count: int) -> Array[Vector3]:
	var verts: Array[Vector3] = []
	for i in range(vertices_count):
		var angle = i * TAU / float(vertices_count)
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var rotated = Vector3(x, 0, z).rotated(Vector3(0, 0, 1), deg_to_rad(tilt))
		verts.append(center + rotated)
	return verts
