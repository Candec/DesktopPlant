extends Resource
class_name PlantSpecies

@export var name: String = "Default Species"

@export var cactus_growth_speed: float = 0.005
@export var ring_thickness: float = 0.5
@export var valley_depth: float = 0.4
@export var branch_chance: float = 0.1
@export var flower_probability: float = 0.0
@export var material: ShaderMaterial
@export var accessory_scene: PackedScene
# Add other parameters as needed, such as twist_enabled, taper ratios, colors, etc.

@export var ring_growth_speed: float = 1.0
@export var ring_rise_speed: float = 0.005
@export var ring_distance: float = 0.5
@export var ring_tilt: float = 0.0
@export var thickness_variance: float = 0.05
@export var distance_variance: float = 0.002
@export var tilt_variance: float = 0.0
@export var max_height: float = 3.0
@export var vertices_per_ring: int = 20
@export var branch_angle_range: float = 0.0
@export var segments_per_point: int = 4
@export var twist_enabled: bool = false
@export var twist_amount: float = 15.0  # degrees per ring
@export var taper_top_enabled: bool = false
@export var taper_start_ratio: float = 0.85  # start tapering after 85% height
