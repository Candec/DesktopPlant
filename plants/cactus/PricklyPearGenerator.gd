extends CactusGenerator
class_name PricklyPearGenerator

var pads := []

func _generate_structure():
	print("Generation Structure")
	rings.clear()
	pads.clear()
	var base_pos = Vector3.ZERO

	# Crear pads planos simulando hojas
	for i in range(5):
		var offset = Vector3(randf_range(-1,1), i * 0.3, randf_range(-1,1))
		pads.append(_create_pad(base_pos + offset))

func _create_pad(pos: Vector3) -> Dictionary:
	print("Generating Pad")
	return {
		"center": pos,
		"radius": 0.6
	}

func _update_growth(progress: float):
	print("Updating Growth")
	# Actualiza pads igual que anillos
	growth_progress = progress
	# Actualizar lógica de pads si quieres
