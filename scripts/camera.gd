extends Node3D

@export_category("mouse")
@export var h_mouse_sensitivity: float = 1.0
@export var v_mouse_sensitivity: float = 1.0
@export var v_m_invert: bool = false
@export var h_m_invert: bool = false
var multiplier: float = 0.001

@onready var h_m_invert_sign: int = 1 if h_m_invert else -1
@onready var v_m_invert_sign: int = 1 if v_m_invert else -1

@export var camera_distance: float = 20.0

# Angular velocity for inertia-based rotation
var angular_velocity: Vector2 = Vector2.ZERO
@export var damping_factor: float = 0.99  # How quickly the rotation slows down (closer to 1 = slower)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("left_click"):
		# Update angular velocity based on mouse motion
		angular_velocity.x = event.relative.x * h_mouse_sensitivity * multiplier * h_m_invert_sign
		angular_velocity.y = event.relative.y * v_mouse_sensitivity * multiplier * v_m_invert_sign
		
		# Apply rotation immediately
		rotate_from_mouse_vector(Vector2(angular_velocity.x, angular_velocity.y))
	
	if Input.is_action_just_pressed("scroll_up"):
		$Camera3D.position.z += 0.05
	if Input.is_action_just_pressed("scroll_down"):
		$Camera3D.position.z -= 0.05
	
		return

func _process(_delta: float) -> void:
	# Apply inertia-based rotation if no input is detected
	if !Input.is_action_pressed("left_click"):
		rotate_from_mouse_vector(angular_velocity)
		
		# Gradually reduce angular velocity using damping
		angular_velocity *= damping_factor
		
		# Stop completely when velocity is very small (to avoid infinite spinning)
		if angular_velocity.length() < 0.001:
			angular_velocity = Vector2.ZERO

func rotate_from_mouse_vector(v: Vector2):
	if v.length() == 0:
		return
	rotation.y += v.x
	rotation.x += v.y
