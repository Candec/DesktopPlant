shader_type spatial;

uniform vec4 color_ridge : source_color = vec4(0.1, 0.6, 0.2, 1.0);
uniform vec4 color_valley : source_color = vec4(0.0, 0.4, 0.1, 1.0);

uniform float dot_size = 10.0;     // Bigger = fewer/larger spots
uniform float ridge_cutoff = 0.0;  // Controls where valleys switch to ridges
uniform float spot_blend = 0.3;    // 0 = hard edge, 1 = full noise blend

void fragment() {
	// Use vertex X/Z direction from center as a fake "ridge axis"
	float radial_strength = cos(atan(VERTEX.z, VERTEX.x) * 5.0); // 5.0 = number of ribs

	// Add procedural noise-like pattern to break the edge
	vec2 spot_uv = UV * dot_size;
	float spot_noise = fract(sin(dot(spot_uv, vec2(12.9898, 78.233))) * 43758.5453);

	// Mix color based on ridge/valley + noise threshold
	float blend_mask = step(ridge_cutoff + spot_blend * (spot_noise - 0.5), radial_strength);

	ALBEDO = mix(color_valley.rgb, color_ridge.rgb, blend_mask);
}
