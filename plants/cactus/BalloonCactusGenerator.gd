extends CactusGenerator
class_name BalloonCactusGenerator

# You can override methods for species-specific customization
func _generate_structure():
	# No branches, only rings
	_generate_structure()  # Call the base structure generation
