extends Node3D

@onready var ui_selector = $CanvasLayer/UISelector
@onready var debug_panel = $CanvasLayer/PlantDebugPanel
@onready var plant_holder = $PlantHolder
@onready var state_manager = PlantStateManager.new()

var current_plant: PlantGenerator = null

func _ready():
	add_child(state_manager)

	ui_selector.connect("request_generate", Callable(self, "_on_generate_request"))
	ui_selector.connect("request_save", Callable(self, "_on_save_request"))
	ui_selector.connect("request_load", Callable(self, "_on_load_request"))
	
	#debug_panel.set_plant_generator(current_plant)
	#debug_panel._build_controls()


func _on_generate_request(category: String, species: String):
	# Create the plant generator based on the selected category and species
	var path = "res://plants/%s/%sGenerator.gd" % [category.to_lower(), species]
	var plant_script = load(path)

	if plant_script:
		current_plant = plant_script.new()
		current_plant.species_name = species
		plant_holder.add_child(current_plant)

		# Now that the plant is created, update the debug panel
		if debug_panel:
			debug_panel.set_plant_generator(current_plant)
			debug_panel._build_controls()  # Update the controls with the new plant
	else:
		push_error("Error: Couldn't load plant generator for species: %s" % species)

func _on_save_request():
	if current_plant:
		var data = current_plant.serialize()
		state_manager.save_plant_state(current_plant.species_name, data)

func _on_load_request():
	var category = ui_selector.category_dropdown.get_item_text(ui_selector.category_dropdown.selected)
	var species = ui_selector.species_dropdown.get_item_text(ui_selector.species_dropdown.selected)
	var data = state_manager.load_plant_state(species)
	if data.size() > 0:
		_on_generate_request(category, species)
		current_plant.deserialize(data)
