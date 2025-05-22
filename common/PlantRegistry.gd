extends Node
class_name PlantRegistry

var generators = {
	"BalloonCactus": preload("res://plants/cactus/BalloonCactusGenerator.gd"),
	"SaguaroCactus": preload("res://plants/cactus/SaguaroCactusGenerator.gd"),
	"PricklyPear": preload("res://plants/cactus/PricklyPearGenerator.gd")
}

func get_generator(species_name: String) -> Script:
	return generators.get(species_name, null)
