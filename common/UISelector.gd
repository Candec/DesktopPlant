extends Control

@onready var category_dropdown = $CategoryDropdown
@onready var species_dropdown = $SpeciesDropdown

signal request_generate(category: String, species: String)
signal request_save()
signal request_load()

func _ready():
	category_dropdown.clear()
	category_dropdown.add_item("Cactus")
	category_dropdown.add_item("Flowers")
	category_dropdown.add_item("Bonsais")
	_populate_species("Cactus")

	category_dropdown.connect("item_selected", Callable(self, "_on_category_selected"))
	$GenerateButton.connect("pressed", Callable(self, "_on_generate_pressed"))
	$SaveButton.connect("pressed", Callable(self, "_on_save_pressed"))
	$LoadButton.connect("pressed", Callable(self, "_on_load_pressed"))

func _on_category_selected(index):
	var category = category_dropdown.get_item_text(index)
	_populate_species(category)

func _populate_species(category: String):
	species_dropdown.clear()
	match category:
		"Cactus":
			species_dropdown.add_item("PricklyPear")
			species_dropdown.add_item("BalloonCactus")
			species_dropdown.add_item("SaguaroCactus")
		"Flowers":
			species_dropdown.add_item("Rose")
			species_dropdown.add_item("Tulip")
		"Bonsais":
			species_dropdown.add_item("Maple")
			species_dropdown.add_item("Oak")

func _on_generate_pressed():
	var category = category_dropdown.get_item_text(category_dropdown.selected)
	var species = species_dropdown.get_item_text(species_dropdown.selected)
	emit_signal("request_generate", category, species)

func _on_save_pressed():
	emit_signal("request_save")

func _on_load_pressed():
	emit_signal("request_load")
