@icon("res://icon.svg")
extends Resource
class_name CactusConfig

# IMPORTANT: Emit 'changed' signal in setters for properties that affect generation!

@export var seed: int = 0:
	set(value):
		if seed != value:
			seed = value
			emit_changed() # Notify listeners (like CactusGenerator)

@export var cactus_height: float = 2.0:
	set(value):
		if cactus_height != value:
			cactus_height = value
			emit_changed()

@export_range(0.4, 2.0) var radius: float = 0.5:
	set(value):
		if radius != value:
			radius = value
			emit_changed()

@export_range(4, 64) var ring_resolution: int = 12:
	set(value):		# Ensure resolution is reasonable
		var new_value = max(3, value) # Minimum 3 sides
		if ring_resolution != new_value:
			ring_resolution = new_value
			emit_changed()
			notify_property_list_changed() # Update inspector if value clamped

@export var ring_count: int = 10:
	set(value):
		var new_value = max(1, value) # Minimum 1 ring
		if ring_count != new_value:
			ring_count = new_value
			emit_changed()
			notify_property_list_changed()

@export_range(0.0, 1.0) var rim_roundness: float = 0.5:
	set(value):
		if rim_roundness != value:
			rim_roundness = value
			emit_changed()

@export var spike_count: int = 100:
	set(value):
		var new_value = max(0, value)
		if spike_count != new_value:
			spike_count = new_value
			emit_changed()
			notify_property_list_changed()

@export_enum("spiral", "vertical") var spike_pattern: String = "vertical": # e.g., "spiral", "vertical"
	set(value):
		if spike_pattern != value:
			spike_pattern = value
			emit_changed()
			
@export_range(0.01, 5.0) var spike_max_scale := 1.0: # Renamed from spike_max_scale for clarity
	set(value):
		var new_value = max(0.01, value) # Ensure scale is positive
		if spike_max_scale != new_value:
			spike_max_scale = new_value
			emit_changed()
			notify_property_list_changed()

# Note: spike_growth_rate might be better handled in the generator or shader if it affects animation speed
# For now, adding as a config parameter as requested.
@export_range(0.1, 5.0) var spike_growth_rate := 1.0:
	set(value):
		var new_value = max(0.1, value) # Ensure rate is positive
		if spike_growth_rate != new_value:
			spike_growth_rate = new_value
			emit_changed()
			notify_property_list_changed()
			
# --- Growth Animation Parameters ---
@export_range(0.1, 20.0) var growth_duration := 5.0:
	set(value):
		var new_value = max(0.1, value) # Ensure duration is positive
		if growth_duration != new_value:
			growth_duration = new_value
			emit_changed()
			notify_property_list_changed()

@export var growth_curve: Curve:
	set(value):
		if growth_curve != value:
			growth_curve = value
			emit_changed()
			
# --- Cap Parameters ---
@export_range(1, 10) var cap_ring_count: int = 3: # How many extra rings for the cap
	set(value):
		var new_value = max(1, value) # Min 1 cap ring
		if cap_ring_count != new_value:
			cap_ring_count = new_value
			emit_changed()
			notify_property_list_changed()

@export_range(0.0, 2.0) var cap_height_factor: float = 0.5: # How much the cap height extends relative to the last ring's radius
	set(value):
		var new_value = max(0.0, value)
		if cap_height_factor != new_value:
			cap_height_factor = new_value
			emit_changed()
			notify_property_list_changed()
# Add setters with emit_changed() for ALL other properties
# that should trigger a cactus regeneration when changed.
