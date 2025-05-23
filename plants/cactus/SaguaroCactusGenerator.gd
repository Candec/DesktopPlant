extends CactusGenerator
class_name SaguaroCactusGenerator

var branches := []

func _generate_structure():
	rings.clear()
	branches.clear()

	var current_height := 0.0
	while current_height <= max_height:
		rings.append(_create_ring(Vector3(0, current_height, 0)))

		# Add branches starting from a certain height (example: simple)
		if current_height > max_height * 0.3 and randi() % 5 == 0:
			_spawn_branch(Vector3(0, current_height, 0))
		current_height += ring_distance

func _spawn_branch(position: Vector3):
	var branch_pos = position + Vector3(randf_range(-1,1), 0, randf_range(-1,1))
	branches.append(_create_ring(branch_pos))

#func _update_growth(progress: float):
	#_update_growth(progress)
	## Optionally, update branches here (not implemented yet)
