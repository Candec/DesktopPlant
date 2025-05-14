#@tool
#@icon("res://icon.svg") # Make sure you have an icon.svg or remove this line
#extends Node3D
#class_name CactusGenerator
#
#@export var config: CactusConfig
##@export var growth_duration: float = 1.5 # Duration of the growth animation
##@export var regenerate := false:
	##set(value):
		##if value:
			### Check if nodes are ready before generating when using the setter
			##if not is_node_ready():
				### If not ready, wait for the next idle frame
				##await get_tree().process_frame
				##generate()
		##regenerate = false
#
#@onready var cactus_mesh_instance := $CactusMesh as MeshInstance3D
#@onready var spike_multimesh := $Spikes as MultiMeshInstance3D
#
#var cactus_shader: ShaderMaterial
#var rng := RandomNumberGenerator.new()
#var growth_tween: Tween # Variable to hold our tween
#
#func _ready():
	#if Engine.is_editor_hint():
		## Delay generation slightly to ensure config might be loaded
		#await get_tree().process_frame
		#if config:
			#generate()
			## Don't auto-animate on ready, only on regenerate toggle
			## Set growth to 1 initially if not animating on ready
			#if is_instance_valid(cactus_shader):
				#cactus_shader.set_shader_parameter("growth", 1.0)
#
#func generate():
	## --- Start of Checks ---
	#if not config:
		#push_warning("CactusGenerator: No CactusConfig resource assigned.")
		#return
	#var mesh_inst = get_node_or_null("CactusMesh") as MeshInstance3D
	#var multi_mesh_inst = get_node_or_null("Spikes") as MultiMeshInstance3D
	#if not mesh_inst:
		#push_error("CactusGenerator: Child node 'CactusMesh' (MeshInstance3D) not found or invalid.")
		#return
		#
	#if not multi_mesh_inst:
		#push_error("CactusGenerator: Child node 'Spikes' (MultiMeshInstance3D) not found or invalid.")
		#return
	## --- End of Checks ---
#
	#cactus_mesh_instance = mesh_inst
	#spike_multimesh = multi_mesh_inst
#
	## Proceed with generation
	#rng.seed = config.seed
	#var generated_height = _generate_cactus() # Function now returns the calculated max height
#
	## Check if mesh generation was successful (returned height > 0)
	#if generated_height > 0.0:
		#_place_spikes() # Spikes appear instantly
#
		## --- Trigger the growth animation ---
		## Pass the actual generated height to the animation function
		#animate_growth(generated_height)
		## --- End Trigger ---
		#print("Cactus generated! Starting growth animation.")
	#else:
		#print("Cactus generation failed.")
#
#
## --- MODIFIED: Returns calculated max height or 0.0 on failure ---
## --- MODIFIED: Returns calculated max height or 0.0 on failure ---
#func _generate_cactus() -> float:
	## Ensure the instance is valid
	#if not is_instance_valid(cactus_mesh_instance):
		#push_error("Cannot assign mesh, CactusMesh instance is invalid.")
		#return 0.0 # Return 0 on failure
#
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)	# --- Config and Cap Parameters ---
	## (Code remains the same)
	#var h = config.cactus_height
	#var rs = config.ring_resolution
	#var rc = config.ring_count
	#var angle_step = TAU / float(rs)
	#var cap_ring_count: int = 3
	#var cap_height_factor: float = 0.6
#
	## --- Step 1: Define all unique vertex positions ---
	## (Code remains the same - includes main rings and cap rings)
	#var vertices = PackedVector3Array()
	#var uvs = PackedVector2Array()
	#var ring_start_indices = []
	#var last_main_ring_radius = 0.0
	## ... (vertex generation code for main rings) ...
	#for i in range(rc + 1):
		#var t = float(i) / rc
		#var y = t * h
		#var r = max(0.01, config.radius * (0.85 + rng.randf_range(0, 0.3)) * _rim_shape(t))
		#ring_start_indices.append(vertices.size())
		#if i == rc: last_main_ring_radius = r
		#for j in range(rs):
			#var angle = j * angle_step
			#var x = cos(angle) * r
			#var z = sin(angle) * r
			#vertices.append(Vector3(x, y, z))
			#var uv_x = float(j) / rs
			#var uv_y = t
			#uvs.append(Vector2(uv_x, uv_y))
			#
	## ... (vertex generation code for cap rings)
	#var cap_base_y = h
	#var cap_base_r = last_main_ring_radius
	#var cap_height = cap_base_r * cap_height_factor
	#var max_h = cap_base_y + cap_height # Total height including cap
	## ... (sphere calculations) ...
	#var sphere_r_denom = 2.0 * cap_height
	#var sphere_r = cap_base_r * cap_base_r if sphere_r_denom <= 0.001 else (cap_base_r * cap_base_r + cap_height * cap_height) / sphere_r_denom
	#var sphere_center_y = cap_base_y + cap_height - sphere_r
	#var start_angle_cos = (cap_base_y - sphere_center_y) / sphere_r if sphere_r > 0.001 else 0.0
	#var start_angle = acos(clampf(start_angle_cos, -1.0, 1.0))
	#for k in range(1, cap_ring_count + 1):
		#var cap_t = float(k) / cap_ring_count
		#var current_angle = lerpf(start_angle, 0.0, cap_t)
		#var r = sphere_r * sin(current_angle)
		#var y = sphere_center_y + sphere_r * cos(current_angle)
		#ring_start_indices.append(vertices.size())
		#var uv_cap_y = lerpf(float(rc) / (rc + cap_ring_count), 1.0, cap_t)
		#for j in range(rs):
			#var angle = j * angle_step
			#var x = cos(angle) * r
			#var z = sin(angle) * r
			#vertices.append(Vector3(x, y, z))
			#var uv_x = float(j) / rs
			#uvs.append(Vector2(uv_x, uv_cap_y))
			#
	## ... (add top center vertex) ...
	#var top_center_pos = Vector3(0, max_h, 0)
	#var top_center_idx = vertices.size()
	#vertices.append(top_center_pos)
	#uvs.append(Vector2(0.5, 1.0))
#
#
	## --- Step 2: Add vertices and attributes ---
	## (Code remains the same)
	#for i in range(vertices.size()):
		#st.set_uv(uvs[i])
		#st.add_vertex(vertices[i])
#
	## --- Step 3: Add indices for sides ---
	## (Code remains the same)
	#var total_rings = rc + cap_ring_count
	#for i in range(total_rings):
		#var idx_a = ring_start_indices[i]
		#var idx_b = ring_start_indices[i+1]
		#for j in range(rs):
			#var v_a_j = idx_a + j
			#var v_a_next = idx_a + (j + 1) % rs
			#var v_b_j = idx_b + j
			#var v_b_next = idx_b + (j + 1) % rs
			## Tri 1 (CCW)
			#st.add_index(v_a_j); st.add_index(v_b_next); st.add_index(v_b_j)
			## Tri 2 (CCW)
			#st.add_index(v_a_j); st.add_index(v_a_next); st.add_index(v_b_next)
#
	## --- Step 4: Add indices for top cap ---
	## (Code remains the same)
	#var idx_top_ring_start = ring_start_indices[total_rings]
	#for j in range(rs):
		#var v_top_j = idx_top_ring_start + j
		#var v_top_next = idx_top_ring_start + (j + 1) % rs
		## Cap Tri (CCW)
		#st.add_index(top_center_idx); st.add_index(v_top_j); st.add_index(v_top_next)
#
	## --- Step 5: Generate normals and commit ---
	#st.generate_normals()
	## st.generate_tangents()
#
	## Commit to a new mesh resource
	#var mesh = st.commit()
	#if not mesh:
		#push_error("Failed to commit SurfaceTool mesh.")
		#return 0.0 # Return 0 on failure
		#
	## --- >> NEW << Revised Shader and Material Setup ---
	## 1. Create and validate the Shader resource first
	#var shader_res = Shader.new()
	#shader_res.code = _growth_shader()
#
	#if shader_res.code.is_empty():
		#push_error("Growth shader code is empty. Cannot setup material.")
		#cactus_mesh_instance.material_override = null # Use default material
		#cactus_mesh_instance.mesh = mesh
		#return 0.0 # Indicate failure	# 2. ALWAYS create a new ShaderMaterial instance
	#var new_material = ShaderMaterial.new() 
#
	## 3. Assign the validated Shader to the NEW ShaderMaterial
	#new_material.shader = shader_res
#
	## 4. Assign the mesh and the NEW material override
	#cactus_mesh_instance.mesh = mesh
	#cactus_mesh_instance.material_override = new_material # Assign the fresh material
#
	## 5. Set shader parameters on the NEW material instance
	#new_material.set_shader_parameter("total_height", max_h)
	#new_material.set_shader_parameter("growth", 0.0) # Start growth at 0
#
	## 6. Update the class variable to hold the reference to the NEW material
	## This is needed so the animate_growth function can find it
	#cactus_shader = new_material 
	## --- >> END NEW << Revised Setup ---
#
	## Return calculated height for animation function
	#return max_h
#
#
#
## --- MODIFIED: Accepts generated_height parameter ---
## --- MODIFIED: Accepts generated_height parameter + Extra Check ---
#func animate_growth(generated_height: float):
	## Ensure we have a valid material to animate (using the class variable)
	#if not is_instance_valid(cactus_shader) or not cactus_shader is ShaderMaterial:
		#push_warning("Cannot animate growth: Class ShaderMaterial variable is invalid.")
		#return
		#
	## >>> ADDED CHECK: Ensure the shader *inside* the material is valid <<<
	#if not is_instance_valid(cactus_shader.shader):
		#push_warning("Cannot animate growth: Shader resource inside ShaderMaterial is invalid.")
		## Set growth to 1 directly if shader is bad, so mesh is at least visible
		#cactus_shader.set_shader_parameter("growth", 1.0) 
		#return
	## >>> END ADDED CHECK <<<
#
	## Ensure generated_height is valid
	#if generated_height <= 0.0:
		#push_warning("Cannot animate growth: Invalid generated_height (%f)." % generated_height)
		## Set growth to 1 directly if height is invalid
		#cactus_shader.set_shader_parameter("growth", 1.0)
		#return
#
	## Validate growth_duration
	#var duration: float = config.growth_duration if config and config.growth_duration > 0.0 else 1.5
#
	## If a previous tween is running, kill it
	#if is_instance_valid(growth_tween) and growth_tween.is_running():
		#growth_tween.kill()
#
	## --- Update total_height uniform just before animating ---
	#cactus_shader.set_shader_parameter("total_height", generated_height)
	## --- Ensure growth starts at 0 ---
	#cactus_shader.set_shader_parameter("growth", 0.0)
#
	## Create a new tween
	#growth_tween = create_tween()
	#growth_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # Use PHYSICS for editor
	#growth_tween.set_parallel(false)
	#print("Starting tween for growth parameter to 1.0 over %f seconds" % duration)
	## Tween the "growth" shader parameter from 0.0 to 1.0
	#growth_tween.tween_property(cactus_shader, "shader_parameter/growth", 1.0, duration)\
		#.from(0.0)\
		#.set_trans(Tween.TRANS_QUAD)\
		#.set_ease(Tween.EASE_OUT)
#
	## Optional callback
	## growth_tween.tween_callback(_on_growth_finished)
#
#
#
#func _rim_shape(t: float) -> float:
	## (Code remains the same)
	#t = clampf(t, 0.0, 1.0)
	#return 0.5 + 0.5 * sin((t - 0.5) * PI) * config.rim_roundness
#
#func _spike_mesh() -> Mesh:
	## (Code remains the same, with corrected winding order)
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#var tip = Vector3(0, 0.1, 0); var base = 0.02
	#st.add_vertex(Vector3(-base, 0, -base)) # 0
	#st.add_vertex(Vector3( base, 0, -base)) # 1
	#st.add_vertex(Vector3( base, 0,  base)) # 2
	#st.add_vertex(Vector3(-base, 0,  base)) # 3
	#st.add_vertex(tip)                      # 4
	## Corrected Winding Order
	#st.add_index(4); st.add_index(0); st.add_index(1)
	#st.add_index(4); st.add_index(1); st.add_index(2)
	#st.add_index(4); st.add_index(2); st.add_index(3)
	#st.add_index(4); st.add_index(3); st.add_index(0)
	#st.generate_normals()
	#return st.commit()
#
#func _place_spikes():
	## Ensure the instance is valid one last time before assignment
	#if not is_instance_valid(spike_multimesh):
		#push_error("Cannot assign multimesh, Spikes instance is invalid.")
		#return
#
	#var mm = MultiMesh.new()
	## --- MultiMesh Setup Order ---
	#mm.transform_format = MultiMesh.TRANSFORM_3D # Set format FIRST
	#mm.mesh = _spike_mesh()                     # Assign mesh
	#
	## Check if spike mesh is valid
	#if not mm.mesh:
		#push_error("Failed to create spike mesh for MultiMesh.")
		#return
		#
	#mm.instance_count = config.spike_count      # Set count LAST
	## --- End Setup ---
#
	## Assign multimesh
	#spike_multimesh.multimesh = mm
#
	## Check if count is > 0 before looping
	#if config.spike_count <= 0:
		#return
#
	## Pre-calculate some values for the loop
	#var safe_ring_res = max(1, config.ring_resolution)
	#var radius_spike = max(0.01, config.radius * 1.05)
	#var spike_scale_val = 0.1 # Adjust scale as needed
	#var spike_scale_vec = Vector3.ONE * spike_scale_val
#
	#for i in range(config.spike_count):
		#var t = float(i) / config.spike_count
		## Place spikes based on the *original* configured height, not the potentially capped height
		#var y = t * config.cactus_height 
		#var angle = 0.0 # Initialize angle
#
		## Use safe division for ring pattern
		#if config.spike_pattern == "spiral":
			#angle = TAU * t * 3.0 + rng.randf_range(0, 0.2)
		#else: # Assuming "ring" or default
			#angle = float(i % safe_ring_res) * TAU / safe_ring_res
#
		## Calculate spike position
		#var x = cos(angle) * radius_spike
		#var z = sin(angle) * radius_spike
		#var pos = Vector3(x, y, z)
#
		## Calculate basis looking outwards from center (approximately)
		#var dir = Vector3(x, 0, z).normalized() # Direction on the XZ plane
		#if dir.length_squared() < 0.001: # Check if close to zero (e.g., at origin)
			#dir = Vector3.FORWARD # Default direction if at origin
		#var basis = Basis.looking_at(dir, Vector3.UP)
#
		## Set instance transform
		#mm.set_instance_transform(i, Transform3D(basis.scaled(spike_scale_vec), pos))
#
#
#
## --- MODIFIED: Removed color uniform ---
#func _growth_shader() -> String:
	## Shader that clips geometry based on original Y position and growth uniform
	#return """
#shader_type spatial;
#render_mode blend_mix, depth_draw_opaque, cull_back;uniform float growth : hint_range(0.0, 1.0) = 0.0;
#uniform float total_height = 1.0; // Set by script
#
#// Varying to pass original Y position to fragment shader
#varying float original_y;
#
#void vertex() {
	#original_y = VERTEX.y; // Store original Y before modification
	#// Vertex position is not scaled here anymore
#}
#
#void fragment() {	float current_max_y = growth * total_height;
#
	#// Discard fragment if its original Y is above the current growth height
	#if (original_y > current_max_y + 0.001) { // Add small tolerance
		#discard;
	#}
#
	#// Default white color
	#ALBEDO = vec3(1.0);
	#ALPHA = 0.5; 
	#
	#// Default PBR values
	#ROUGHNESS = 0.8;
	#METALLIC = 0.1;
#}
#"""

@tool
@icon("res://icon.svg") # Make sure you have an icon.svg or remove this line
extends Node3D
class_name CactusGenerator

# --- Exported Variables ---# Config is now the primary source for most settings
@export var config: CactusConfig:
	set(value):
		# Disconnect from the previous config if it exists and is valid
		if Engine.is_editor_hint():
			if is_instance_valid(_previous_config) and _previous_config.is_connected("changed", _on_config_changed):
				_previous_config.disconnect("changed", _on_config_changed)
			# Also disconnect from previous curve if needed
			if is_instance_valid(_previous_curve) and _previous_curve.is_connected("changed", _on_config_changed):
				_previous_curve.disconnect("changed", _on_config_changed)

		config = value
		_previous_config = config # Update the previous config reference

		if Engine.is_editor_hint():
			# Connect to the new config if it's valid
			if is_instance_valid(config):
				if not config.is_connected("changed", _on_config_changed):
					config.connect("changed", _on_config_changed, CONNECT_DEFERRED) # Use deferred connection

				# Connect to the curve resource within the config
				if is_instance_valid(config.growth_curve):
					if not config.growth_curve.is_connected("changed", _on_config_changed):
						config.growth_curve.connect("changed", _on_config_changed, CONNECT_DEFERRED)
					_previous_curve = config.growth_curve
				else:
					_previous_curve = null

			# Trigger generation when config resource is assigned/changed in editor
			_trigger_editor_generation()
		elif config: # Also regenerate if changed at runtime (optional)
			generate()


# REMOVED: @export var growth_duration: float = 1.5 - Now controlled by config

@export var regenerate := false:
	set(value):
		regenerate = value # Assign first
		if regenerate:
			if Engine.is_editor_hint():
				_trigger_editor_generation()
			else:
				generate() # Direct call at runtime is usually fine
			# Reset the checkbox visually after triggering
			# Need to wait a frame for the editor property to update
			call_deferred("set", "regenerate", false)


# --- Nodes ---
# Use get_node_or_null for robustness
@onready var cactus_mesh_instance := get_node_or_null("CactusMesh") as MeshInstance3D
@onready var spike_multimesh := get_node_or_null("Spikes") as MultiMeshInstance3D

# --- Internal Variables ---
var cactus_shader: ShaderMaterial
var rng := RandomNumberGenerator.new()
var growth_tween: Tween # Variable to hold our tween
var _previous_config: CactusConfig = null # To manage signal connections
var _previous_curve: Curve = null # To manage curve signal connection
var _editor_generate_queued := false # Prevent multiple queued generations


# --- Godot Functions ---
func _ready():
	# Validate child nodes immediately
	if not is_instance_valid(cactus_mesh_instance):
		push_error("CactusGenerator: Child node 'CactusMesh' (MeshInstance3D) not found or invalid.")
		# cactus_mesh_instance = null # No need, get_node_or_null handles this
	if not is_instance_valid(spike_multimesh):
		push_error("CactusGenerator: Child node 'Spikes' (MultiMeshInstance3D) not found or invalid.")
		# spike_multimesh = null

	if Engine.is_editor_hint():
		# Initial connection and generation in editor
		if is_instance_valid(config):
			if not config.is_connected("changed", _on_config_changed):
				config.connect("changed", _on_config_changed, CONNECT_DEFERRED)
			_previous_config = config
			# Connect to initial curve
			if is_instance_valid(config.growth_curve):
				if not config.growth_curve.is_connected("changed", _on_config_changed):
					config.growth_curve.connect("changed", _on_config_changed, CONNECT_DEFERRED)
				_previous_curve = config.growth_curve
			# Generate on ready only if config is valid
				_trigger_editor_generation()
			else:
			# Clear mesh if no config initially
				_clear_meshes()
	elif config:
		# Initial generation at runtime if config is assigned
		generate()


# --- Core Logic ---
func generate():
	# --- Start of Checks ---
	if not config:
		push_warning("CactusGenerator: No CactusConfig resource assigned.")
		_clear_meshes() # Clear existing meshes if config removed
		return	# Re-check nodes just in case they became invalid
	if not is_instance_valid(cactus_mesh_instance):
		push_error("CactusGenerator: Required child node 'CactusMesh' is missing or invalid.")
		return
	if not is_instance_valid(spike_multimesh):
		push_error("CactusGenerator: Required child node 'Spikes' is missing or invalid.")
		return
	# --- End of Checks ---

	# Proceed with generation
	rng.seed = config.seed
	var generated_height = _generate_cactus() # Function now returns the calculated max height

	# Check if mesh generation was successful (returned height > 0)
	if generated_height > 0.0:
		_place_spikes() # Spikes appear instantly

		# --- Trigger the growth animation ---
		# Pass the actual generated height to the animation function
		# Only animate if not in editor OR if regenerate was explicitly toggled
		if not Engine.is_editor_hint() or regenerate:
			animate_growth(generated_height)
		elif is_instance_valid(cactus_shader):
			# In editor, set growth to full immediately unless animating via regenerate
			cactus_shader.set_shader_parameter("growth", 1.0)

		# print("Cactus generated!") # Less spammy
	else:
		push_warning("Cactus generation failed or produced zero height.")
		_clear_meshes()


# --- Mesh Generation ---
func _generate_cactus() -> float:
	# Ensure the instance is valid
	if not is_instance_valid(cactus_mesh_instance):
		push_error("Cannot assign mesh, CactusMesh instance is invalid.")
		return 0.0 # Return 0 on failure

	# --- >> IMPORTANT: Ensure cactus_mesh_instance.material_override is reset << ---
	cactus_mesh_instance.material_override = null
	cactus_shader = null # Clear reference to old shader material

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# --- Config and Cap Parameters ---
	if not config: return 0.0 # Added check

	# Use values from config
	var h = config.cactus_height
	var rs = config.ring_resolution
	var rc = config.ring_count
	var cap_ring_count: int = config.cap_ring_count # <-- USE CONFIG
	var cap_height_factor: float = config.cap_height_factor # <-- USE CONFIG

	var angle_step = TAU / float(rs) if rs > 0 else 0.0 # Avoid division by zero

	# --- Step 1: Define all unique vertex positions ---
	var vertices = PackedVector3Array()
	var uvs = PackedVector2Array()
	var ring_start_indices = []
	var last_main_ring_radius = 0.0

	# Main rings
	for i in range(rc + 1):
		var t = float(i) / rc if rc > 0 else 0.0
		var y = t * h
		# Use config radius and rim shape
		var r = max(0.01, config.radius * (0.85 + rng.randf_range(0, 0.3)) * _rim_shape(t))
		ring_start_indices.append(vertices.size())
		if i == rc: last_main_ring_radius = r
		for j in range(rs):
			var angle = j * angle_step
			var x = cos(angle) * r
			var z = sin(angle) * r
			vertices.append(Vector3(x, y, z))
			var uv_x = float(j) / rs if rs > 0 else 0.0
			var uv_y = t
			uvs.append(Vector2(uv_x, uv_y))

	# Cap rings
	var cap_base_y = h
	var cap_base_r = last_main_ring_radius
	var cap_height = cap_base_r * cap_height_factor # Factor applied to radius
	var max_h = cap_base_y + cap_height # Total height including cap

	# Sphere calculations for cap
	var sphere_r_denom = 2.0 * cap_height
	var sphere_r = 0.0
	if sphere_r_denom > 0.001:
		sphere_r = (cap_base_r * cap_base_r + cap_height * cap_height) / sphere_r_denom
	else: # Avoid division by zero / handle flat cap case
		sphere_r = 1e6 # Effectively flat top if cap_height is near zero

	var sphere_center_y = cap_base_y + cap_height - sphere_r
	var start_angle_cos = 0.0
	if sphere_r > 0.001:
		start_angle_cos = (cap_base_y - sphere_center_y) / sphere_r
	var start_angle = acos(clampf(start_angle_cos, -1.0, 1.0))

	# Use config cap_ring_count
	for k in range(1, cap_ring_count + 1):
		var cap_t = float(k) / cap_ring_count if cap_ring_count > 0 else 0.0
		var current_angle = lerpf(start_angle, 0.0, cap_t)
		var r = sphere_r * sin(current_angle)
		var y = sphere_center_y + sphere_r * cos(current_angle)
		ring_start_indices.append(vertices.size())
		# Correct UV mapping for cap
		var total_segments = rc + cap_ring_count
		var uv_cap_y = lerpf(float(rc) / total_segments, 1.0, cap_t) if total_segments > 0 else 1.0
		for j in range(rs):
			var angle = j * angle_step
			var x = cos(angle) * r
			var z = sin(angle) * r
			vertices.append(Vector3(x, y, z))
			var uv_x = float(j) / rs if rs > 0 else 0.0
			uvs.append(Vector2(uv_x, uv_cap_y))

	# Top center vertex
	var top_center_pos = Vector3(0, max_h, 0)
	var top_center_idx = vertices.size()
	vertices.append(top_center_pos)
	uvs.append(Vector2(0.5, 1.0)) # UV for the very top point

	# --- Step 2: Add vertices and attributes ---
	# Optimization: Set all at once if supported (Godot 4.x+)
	st.set_uvs(uvs)
	st.set_vertices(vertices) # Use set_vertices for efficiency

	# --- Step 3: Add indices for sides ---
	var total_rings = rc + cap_ring_count # Use config value here too
	for i in range(total_rings):
		var idx_a = ring_start_indices[i]
		var idx_b = ring_start_indices[i+1]
		for j in range(rs):
			var v_a_j = idx_a + j
			var v_a_next = idx_a + (j + 1) % rs
			var v_b_j = idx_b + j
			var v_b_next = idx_b + (j + 1) % rs
			# Tri 1 (CCW)
			st.add_index(v_a_j); st.add_index(v_b_next); st.add_index(v_b_j)
			# Tri 2 (CCW)
			st.add_index(v_a_j); st.add_index(v_a_next); st.add_index(v_b_next)

	# --- Step 4: Add indices for top cap ---
	var idx_top_ring_start = ring_start_indices[total_rings]
	for j in range(rs):
		var v_top_j = idx_top_ring_start + j
		var v_top_next = idx_top_ring_start + (j + 1) % rs
		# Cap Tri (CCW)
		st.add_index(top_center_idx); st.add_index(v_top_j); st.add_index(v_top_next)

	# --- Step 5: Generate normals and commit ---
	st.generate_normals()
	# st.generate_tangents() # Uncomment if your shader needs tangents
	var mesh = st.commit()
	if not mesh:
		push_error("Failed to commit SurfaceTool mesh.")
		return 0.0 # Return 0 on failure

	# --- Shader and Material Setup ---
	var shader_res = Shader.new()
	shader_res.code = _growth_shader()
	if shader_res.code.is_empty():
		push_error("Growth shader code is empty. Cannot setup material.")
		cactus_mesh_instance.material_override = null # Use default material
		cactus_mesh_instance.mesh = mesh
		return 0.0 # Indicate failure	var new_material = ShaderMaterial.new()
	new_material.shader = shader_res
	cactus_mesh_instance.mesh = mesh
	cactus_mesh_instance.material_override = new_material # Assign the fresh material

	# Set shader parameters on the NEW material instance
	new_material.set_shader_parameter("total_height", max_h)
	# Set initial growth based on context (0 for animation, 1 for static editor view)
	var initial_growth = 0.0 if (not Engine.is_editor_hint() or regenerate) else 1.0
	new_material.set_shader_parameter("growth", initial_growth)

	# Update the class variable to hold the reference to the NEW material
	cactus_shader = new_material

	return max_h


# --- Spike Placement ---
func _place_spikes():
	if not is_instance_valid(spike_multimesh):
		push_error("Cannot assign multimesh, Spikes instance is invalid.")
		return
		
	if not config:
		return # Added check

	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _spike_mesh()
	if not mm.mesh:
		push_error("Failed to create spike mesh for MultiMesh.")
		spike_multimesh.multimesh = null # Clear invalid multimesh		return

	# Set count LAST only after mesh and format are set
	mm.instance_count = config.spike_count

	# Assign multimesh
	spike_multimesh.multimesh = mm # Assign the new MultiMesh resource

	if config.spike_count <= 0:
		return # No spikes to place

	# Pre-calculate values
	var safe_ring_res = max(1, config.ring_resolution)	# Use spike_max_scale from config
	var spike_scale_val = config.spike_max_scale # <-- USE CONFIG
	var spike_scale_vec = Vector3.ONE * spike_scale_val
	for i in range(config.spike_count):
		# Using random t for potentially better distribution
		var t = rng.randf() # Random height fraction [0, 1]

		# Calculate y position based on configured height
		var y = t * config.cactus_height
		# Calculate radius at this height t using the rim shape
		var r_at_t = max(0.01, config.radius * (0.85 + rng.randf_range(0, 0.3)) * _rim_shape(t))

		var angle = 0.0
		# Use spike_pattern from config
		if config.spike_pattern == "spiral":
			angle = TAU * t * 5.0 + rng.randf_range(-0.1, 0.1) # Example spiral
		else: # "ring" or default - use random angle for less regularity
			angle = rng.randf() * TAU

		# Calculate spike position using radius at height t
		var x = cos(angle) * r_at_t
		var z = sin(angle) * r_at_t
		var pos = Vector3(x, y, z)

		# Calculate basis looking outwards from center (approximate)
		var normal = Vector3(x, 0, z).normalized()
		if normal.length_squared() < 0.001: normal = Vector3.FORWARD # Handle center case

		# Add some randomness to spike orientation
		# normal = normal.rotated(Vector3.UP, rng.randf_range(-0.1, 0.1))
		# normal = normal.rotated(Vector3(normal.z, 0, -normal.x).normalized(), rng.randf_range(-0.1, 0.1))

		# Point spike roughly normal to the surface (using XZ direction as approximation)
		var basis = Basis.looking_at(normal, Vector3.UP)

		# Set instance transform using config scale
		mm.set_instance_transform(i, Transform3D(basis.scaled(spike_scale_vec), pos))


# --- Spike Mesh Generation ---
func _spike_mesh() -> Mesh:	# (Your existing _spike_mesh code - seems fine)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tip = Vector3(0, 0.1, 0); var base = 0.02
	var base_verts = [
		Vector3(-base, 0, -base), # 0
		Vector3( base, 0, -base), # 1
		Vector3( base, 0,  base), # 2
		Vector3(-base, 0,  base)  # 3
	]
	var tip_idx = 4

	st.add_vertex(base_verts[0])
	st.add_vertex(base_verts[1])
	st.add_vertex(base_verts[2])
	st.add_vertex(base_verts[3])
	st.add_vertex(tip) # 4

	# Sides (Corrected Winding Order)
	st.add_index(tip_idx); st.add_index(0); st.add_index(1)
	st.add_index(tip_idx); st.add_index(1); st.add_index(2)
	st.add_index(tip_idx); st.add_index(2); st.add_index(3)
	st.add_index(tip_idx); st.add_index(3); st.add_index(0)

	# Optional Base (Comment out if not needed)
	# st.add_index(0); st.add_index(2); st.add_index(1) # Tri 1
	# st.add_index(0); st.add_index(3); st.add_index(2) # Tri 2

	st.generate_normals()
	return st.commit()


# --- Animation ---
func animate_growth(generated_height: float):
	if not config: return # Need config for duration/curve
	if not is_instance_valid(cactus_shader) or not cactus_shader is ShaderMaterial:
		push_warning("Cannot animate growth: ShaderMaterial is invalid.")
		return
	if not is_instance_valid(cactus_shader.shader):
		push_warning("Cannot animate growth: Shader resource inside ShaderMaterial is invalid.")
		if is_instance_valid(cactus_shader): cactus_shader.set_shader_parameter("growth", 1.0)
		return
		if generated_height <= 0.0:
			push_warning("Cannot animate growth: Invalid generated_height (%f)." % generated_height)
		if is_instance_valid(cactus_shader): cactus_shader.set_shader_parameter("growth", 1.0)
		return

	# Use growth_duration from config
	var duration = config.growth_duration if config.growth_duration > 0.0 else 1.5 # <-- USE CONFIG

	# Kill existing tween if running
	if is_instance_valid(growth_tween) and growth_tween.is_running():
		growth_tween.kill()

	# Ensure parameters are set correctly before starting
	cactus_shader.set_shader_parameter("total_height", generated_height)
	cactus_shader.set_shader_parameter("growth", 0.0) # Start from 0

	# Create and configure the tween
	growth_tween = create_tween()
	# Use PHYSICS process for editor compatibility if needed, otherwise PROCESS is fine
	growth_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE if Engine.is_editor_hint() else Tween.TWEEN_PROCESS_PHYSICS)
	growth_tween.set_parallel(false)

	# --- Apply Growth Curve ---
	var trans_type = Tween.TRANS_QUAD # Default transition
	var ease_type = Tween.EASE_OUT   # Default ease

	# Check if a valid curve is assigned in the config
	if is_instance_valid(config.growth_curve) and config.growth_curve.get_point_count() > 0:
		# If curve exists, use TRANS_CURVE and set the ease type (usually EASE_IN_OUT for curves)
		trans_type = Tween.TRANS_CURVE
		ease_type = Tween.EASE_IN_OUT # Or EASE_IN, EASE_OUT depending on desired curve effect
		print("Using growth curve for tween.")
	else:
		print("No valid growth curve found, using default Quad Out easing.")

	var prop_tween = growth_tween.tween_property(cactus_shader, "shader_parameter/growth", 1.0, duration)\
		.from(0.0)\
		.set_trans(trans_type)\
		.set_ease(ease_type)

	# If using TRANS_CURVE, assign the curve resource to the tween
	if trans_type == Tween.TRANS_CURVE:
		prop_tween.set_curve(config.growth_curve) # <-- SET CURVE

	# print("Starting growth tween...") # Less spammy# --- Helpers ---
func _rim_shape(t: float) -> float:
	if not config: return 1.0 # Default shape if no config
	t = clampf(t, 0.0, 1.0)
	# Use rim_roundness from config
	return 0.5 + 0.5 * sin((t - 0.5) * PI) * config.rim_roundness # <-- USE CONFIGfunc _growth_shader() -> String:
	# (Keep your existing shader code - no changes needed here for config values)
	return """
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back; // Consider cull_disabled if backfaces needed

uniform float growth : hint_range(0.0, 1.0) = 0.0;
uniform float total_height = 1.0; // Set by script
uniform sampler2D texture_albedo : source_color; // Example texture
uniform vec4 albedo_color : source_color = vec4(0.2, 0.8, 0.1, 1.0); // Default green

varying float original_y;
varying vec2 vertex_uv; // Pass UV to fragment

void vertex() {
	original_y = VERTEX.y; // Store original Y before modification
	vertex_uv = UV; // Pass UV
	// Vertex position is not scaled here anymore
}void fragment() {
	float current_max_y = growth * total_height;
	// Discard fragment if its original Y is above the current growth height
	if (original_y > current_max_y + 0.001) { // Add small tolerance
		discard;
	}

	// Sample texture or use color
	vec4 tex_color = texture(texture_albedo, vertex_uv);
	ALBEDO = albedo_color.rgb * tex_color.rgb;
	ALPHA = albedo_color.a * tex_color.a; // Use alpha from color and texture

	// Default PBR values
	ROUGHNESS = 0.8;
	METALLIC = 0.1;
}
"""

# --- Signal Callback ---
func _on_config_changed():
	if Engine.is_editor_hint() and is_instance_valid(config): # Check config validity
		# print("Config or Curve changed, regenerating...") # Debug print
		_trigger_editor_generation()


# --- Editor Specific ---
func _trigger_editor_generation():
	# Prevent queuing multiple updates in the same frame
	if _editor_generate_queued:
		return
	_editor_generate_queued = true
	# Use call_deferred to ensure generation happens after property updates settle
	call_deferred("_deferred_generate")

func _deferred_generate():
	_editor_generate_queued = false # Reset queue flag
	if not is_node_ready():
		# Check if node is ready, wait if necessary (safer in editor)
		if get_tree():
			await get_tree().process_frame
		else:
			push_warning("Cannot wait for frame, node not in tree.")
			return # Cannot proceed if not in tree

	# Double check config validity before generating
	if is_instance_valid(config):
		generate()
	else:
		_clear_meshes() # Clear if config became invalid

func _clear_meshes():
	if is_instance_valid(cactus_mesh_instance):
		cactus_mesh_instance.mesh = null
		cactus_mesh_instance.material_override = null
	if is_instance_valid(spike_multimesh):
		spike_multimesh.multimesh = null
	cactus_shader = null # Clear shader reference

# Optional: Clean up connections when the node exits the tree
func _exit_tree():
	if Engine.is_editor_hint():
		if is_instance_valid(_previous_config) and _previous_config.is_connected("changed", _on_config_changed):
			_previous_config.disconnect("changed", _on_config_changed)
		if is_instance_valid(_previous_curve) and _previous_curve.is_connected("changed", _on_config_changed):
			_previous_curve.disconnect("changed", _on_config_changed)

	if is_instance_valid(growth_tween):
		growth_tween.kill() # Stop any running tweens
