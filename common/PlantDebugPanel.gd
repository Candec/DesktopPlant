extends Panel

var plant_generator: Object = null  # Referencia al generador a modificar

var controls = {}

func set_plant_generator(gen):
	plant_generator = gen
	if plant_generator:
		_build_controls()
	else:
		push_error("plant_generator no asignado")

func _ready():
	pass

func _build_controls():
	# Limpia controles previos
	for child in get_children():
		child.queue_free()

	var y_offset = 10

	for prop in plant_generator.get_property_list():
		if not prop.has("name") or not prop.has("type"):
			continue
		var name = prop.name
		var type = prop.type

		# Solo propiedades exportadas en editor
		if not prop.has("usage") or not (prop.usage & PROPERTY_USAGE_EDITOR):
			continue

		var label = Label.new()
		label.text = name
		label.position = Vector2(10, y_offset)
		add_child(label)

		var control
		match type:
			TYPE_BOOL:
				control = CheckBox.new()
				control.button_pressed  = bool(plant_generator.get(name))
				control.position = Vector2(150, y_offset)
				control.connect("toggled", Callable(self, "_on_control_changed").bind(name))
			TYPE_FLOAT:
				control = HSlider.new()
				control.min_value = 0.0
				control.max_value = 10.0
				control.step = 0.01
				control.value = plant_generator.get(name)
				control.rect_size = Vector2(200, 20)
				control.rect_position = Vector2(150, y_offset)
				control.connect("value_changed", Callable(self, "_on_control_changed").bind(name))
			TYPE_INT:
				control = SpinBox.new()
				control.min_value = 0
				control.max_value = 100
				control.value = plant_generator.get(name)
				control.position = Vector2(150, y_offset)
				control.connect("value_changed", Callable(self, "_on_control_changed").bind(name))
			_:
				continue

		add_child(control)
		controls[name] = control
		y_offset += 30

func _on_control_changed(value, property_name):
	if not plant_generator:
		return
	plant_generator.set(property_name, value)
	if property_name == "growth_progress":
		plant_generator._update_growth(value)
