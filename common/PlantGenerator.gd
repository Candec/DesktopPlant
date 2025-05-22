extends Node3D
class_name PlantGenerator

signal plant_updated

# Nombre de la especie para cargar configuración
var species_name: String = ""

# Diccionario donde se almacenará la configuración cargada de JSON
var species_config: Dictionary = {}

# Ruta base donde se almacenan los archivos JSON de configuración por categoría
@export var config_base_path: String = "res://plants/"

# Parámetros generales
var growth_progress: float = 0.0

func _ready():
	# Puedes iniciar generación automática o dejarlo al control externo
	pass

func _load_species_config():
	# Ruta completa al archivo JSON de configuración para la especie
	if species_name == "":
		push_error("No se ha definido 'species_name' en PlantGenerator")
		return

	var category = get_category_from_class()
	var json_path = "%s%s/%s_species.json" % [config_base_path, category, category]

	# Cargar JSON
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var parse_result = JSON.parse_string(json_text)
		if parse_result.error != OK:
			push_error("Error parseando JSON en %s: %s" % [json_path, parse_result.error_string])
			species_config = {}
		else:
			var all_species = parse_result.result
			species_config = all_species.get(species_name, {})
			if species_config.size() == 0:
				push_warning("No se encontró configuración para especie '%s' en %s" % [species_name, json_path])
	else:
		push_error("No se pudo abrir archivo de configuración: %s" % json_path)
		species_config = {}

func _generate_structure():
	push_error("_generate_structure() debe implementarse en subclases")

func _update_growth(progress: float):
	push_error("_update_growth() debe implementarse en subclases")

func generate_plant():
	_load_species_config()
	_generate_structure()
	_update_growth(0.0)
	emit_signal("plant_updated")

func serialize() -> Dictionary:
	return {
		"species_name": species_name,
		"growth_progress": growth_progress,
		"config": species_config
	}

func deserialize(data: Dictionary) -> void:
	species_name = data.get("species_name", "")
	species_config = data.get("config", {})
	growth_progress = data.get("growth_progress", 0.0)
	_generate_structure()
	_update_growth(growth_progress)

# Método auxiliar para obtener la categoría (cactus, flowers, bonsais) desde el nombre de la clase
func get_category_from_class() -> String:
	# Asume que el script está en una ruta como res://plants/cactus/Algo.gd
	# O que el nombre de clase contiene la categoría
	# Ejemplo simple: extrae 'cactus' de la ruta o nombre clase
	var lowered_class_name = get_class().to_lower()
	if "cactus" in lowered_class_name:
		return "cactus"
	elif "flower" in lowered_class_name:
		return "flowers"
	elif "bonsai" in lowered_class_name:
		return "bonsais"
	else:
		# Valor por defecto si no se identifica
		return "cactus"
