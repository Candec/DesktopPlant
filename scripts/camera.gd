extends Node3D

@export_category("mouse")
@export var h_mouse_sensitivity: float = 1.0
@export var v_mouse_sensitivity: float = 1.0
@export var v_m_invert: bool = false
@export var h_m_invert: bool = false
var multiplier: float = 0.001

@onready var h_m_invert_sign: int = 1 if h_m_invert else -1
@onready var v_m_invert_sign: int = 1 if v_m_invert else -1

@export var camera_distance: float = 5.0

# Angular velocity for inertia-based rotation
var angular_velocity: Vector2 = Vector2.ZERO
@export var damping_factor: float = 0.99  # How quickly the rotation slows down (closer to 1 = slower)


var is_panning := false
var last_mouse_pos := Vector2.ZERO
var pan_velocity := Vector3.ZERO
@export var pan_damping := 0.9  # 0.99 = very slow stop, 0.8 = fast stop
@export var pan_speed_multiplier := 0.01

func _ready() -> void:
	if camera_distance <= 0.0:
		camera_distance = $Camera3D.position.z
	update_camera_distance()

func _input(event: InputEvent) -> void:
	# Handle mouse button press and release
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if Input.is_key_pressed(KEY_SHIFT):
					is_panning = true
					last_mouse_pos = event.position
					pan_velocity = Vector3.ZERO
				else:
					is_panning = false  # Just rotation
			else:
				is_panning = false  # On release

	# Scroll for zooming
	if Input.is_action_just_pressed("scroll_up"):
		camera_distance -= 1.0
		update_camera_distance()

	if Input.is_action_just_pressed("scroll_down"):
		camera_distance += 1.0
		update_camera_distance()

	# Handle mouse movement
	if event is InputEventMouseMotion:
		if is_panning:
			# Panning logic
			var delta = event.position - last_mouse_pos
			last_mouse_pos = event.position

			var right = global_transform.basis.x.normalized()
			var forward = -global_transform.basis.y.normalized()
			var direction = (-right * delta.x + -forward * delta.y) * pan_speed_multiplier

			global_position += direction
			pan_velocity = direction
			
		elif Input.is_action_pressed("left_click") and not Input.is_key_pressed(KEY_SHIFT):
			# Rotation logic
			angular_velocity.x = event.relative.x * h_mouse_sensitivity * multiplier * h_m_invert_sign
			angular_velocity.y = event.relative.y * v_mouse_sensitivity * multiplier * v_m_invert_sign

			rotate_from_mouse_vector(Vector2(angular_velocity.x, angular_velocity.y))


func _process(_delta: float) -> void:
	# Apply inertia-based rotation if no input is detected
	if !Input.is_action_pressed("left_click"):
		rotate_from_mouse_vector(angular_velocity)
		
		# Gradually reduce angular velocity using damping
		angular_velocity *= damping_factor
		
		# Stop completely when velocity is very small (to avoid infinite spinning)
		if angular_velocity.length() < 0.001:
			angular_velocity = Vector2.ZERO

	if not is_panning and pan_velocity.length() > 0.001:
		global_position += pan_velocity
		pan_velocity *= pow(pan_damping, _delta * 60.0)

		# Snap to stop if velocity is very low
		if pan_velocity.length() < 0.001:
			pan_velocity = Vector3.ZERO

func rotate_from_mouse_vector(v: Vector2):
	if v.length() == 0:
		return
	rotation.y += v.x
	rotation.x += v.y

func update_camera_distance() -> void:
	$Camera3D.position = Vector3(0, 0, camera_distance)
