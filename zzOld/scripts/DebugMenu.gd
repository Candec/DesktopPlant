extends Control

@onready var pause_btn = $PauseButton
@onready var restart_btn = $RestartButton
@onready var save_btn = $SaveButton
@onready var load_btn = $LoadButton
@onready var status_label = $StatusLabel
@onready var style_selector := $StyleSelector

var generator: Node = null

func _ready():
	generator = get_parent()
	print("Pause button is: ", pause_btn)

	pause_btn.pressed.connect(_on_pause)
	restart_btn.pressed.connect(_on_restart)
	save_btn.pressed.connect(_on_save)
	load_btn.pressed.connect(_on_load)
	

	style_selector.add_item("Ridge Shading")
	style_selector.add_item("Cell Shaded")
	style_selector.add_item("Pixelated")
	style_selector.add_item("Cartoon")
	style_selector.connect("item_selected", _on_style_selected)

func _process(_delta):
	if generator:
		var mode = "Paused" if generator.is_paused else "Growing"
		status_label.text = "%s | Rings: %d | Height: %.2f" % [mode, generator.rings.size(), generator.cactus_height]

func _on_pause():
	if generator:
		generator.is_paused = !generator.is_paused

func _on_restart():
	if generator:
		generator.reset()

func _on_save():
	if generator:
		generator.save_cactus("user://cactus_data.txt")

func _on_load():
	if generator:
		generator.load_cactus("user://cactus_data.txt")
		
func _on_style_selected(index: int):
	if not generator:
		return

	match index:
		0: generator.set_cactus_material(generator.ridge_mat)
		1: generator.set_cactus_material(generator.cell_mat)
		2: generator.set_cactus_material(generator.pixel_mat)
		3: generator.set_cactus_material(generator.cartoon_mat)
