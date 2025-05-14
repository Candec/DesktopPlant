@tool
#extends EditorPlugin
#
#
#func _enter_tree():
	#add_custom_type("CactusGenerator", "Node3D", preload("res://addons/proc_cactus/cactus_generator.gd"), preload("res://icon.svg"))
	#add_custom_type("CactusConfig", "Resource", preload("res://addons/proc_cactus/cactus_config.gd"), preload("res://icon.svg"))
#
#func _exit_tree():
	#remove_custom_type("CactusGenerator")
	#remove_custom_type("CactusConfig")
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"CactusGenerator",
		"Node3D",
		preload("res://addons/proc_cactus/cactus_generator.gd"),
		preload("res://addons/proc_cactus/icon.svg")
	)
	add_custom_type(
		"CactusConfig",
		"Resource",
		preload("res://addons/proc_cactus/cactus_config.gd"),
		preload("res://addons/proc_cactus/icon.svg")
	)

func _exit_tree():
	remove_custom_type("CactusGenerator")
	remove_custom_type("CactusConfig")
