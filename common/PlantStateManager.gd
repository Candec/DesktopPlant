extends Node

class_name PlantStateManager

# Directory for saving and loading plant states
const SAVE_DIR := "user://plant_saves/"

# File extension for saved states
const FILE_EXT := ".json"

func _ready():
	var dir = DirAccess.open(SAVE_DIR)
	if not dir:
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# Save plant state to a file
func save_plant_state(plant_name: String, plant_data: Dictionary) -> void:
	var file_path = SAVE_DIR + plant_name + FILE_EXT
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(plant_data, "\t"))
		file.close()
	else:
		push_error("Failed to save plant state to %s" % file_path)

# Load plant state from a file
func load_plant_state(plant_name: String) -> Dictionary:
	var file_path = SAVE_DIR + plant_name + FILE_EXT
	if not FileAccess.file_exists(file_path):
		push_warning("Plant save file does not exist: %s" % file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var result = JSON.parse_string(content)
		if result is Dictionary:
			return result
		else:
			push_error("Invalid JSON format in %s" % file_path)
	else:
		push_error("Failed to open file for reading: %s" % file_path)

	return {}

# List all saved plant states
func list_saved_plants() -> Array[String]:
	var saved_files: Array[String] = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(FILE_EXT):
				saved_files.append(file_name.trim_suffix(FILE_EXT))
			file_name = dir.get_next()
		dir.list_dir_end()
	return saved_files
