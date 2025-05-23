extends Node3D
class_name PlantGenerator

signal plant_updated

var species_name: String = ""
var species_config: Dictionary = {}

@export var config_base_path: String = "res://plants/"

var growth_progress: float = 0.0
var debug_mesh_instance: ImmediateMesh

func _ready():
	# Default behavior
	pass

# This method is expected to be implemented in the subclass
func _load_species_config():
	push_error("_load_species_config() must be implemented in sub-classes")

func _generate_structure():
	push_error("_generate_structure() must be implemented in sub-classes")

func _update_growth(progress: float):
	push_error("_update_growth() must be implemented in sub-classes")

func generate_plant():
	_load_species_config()
	_generate_structure()
	_update_growth(0.0)
	emit_signal("plant_updated")
