extends Control

@onready var pause_btn = $PauseButton
@onready var restart_btn = $RestartButton
@onready var save_btn = $SaveButton
@onready var load_btn = $LoadButton
@onready var status_label = $StatusLabel

var generator: Node = null

func _ready():
	generator = get_parent()
	print("Pause button is: ", pause_btn)

	pause_btn.pressed.connect(_on_pause)
	restart_btn.pressed.connect(_on_restart)
	save_btn.pressed.connect(_on_save)
	load_btn.pressed.connect(_on_load)

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
