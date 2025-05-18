shader_type spatial;
render_mode cull_back, depth_draw_opaque, blend_mix;

uniform float ridge_frequency : hint_range(1.0, 20.0) = 6.0;
uniform float ridge_sharpness : hint_range(1.0, 10.0) = 5.0;

uniform vec3 color_valley : source_color = vec3(0.1, 0.9, 0.8);   // soft mint green
uniform vec3 color_mid    : source_color = vec3(0.95, 0.9, 0.7);   // warm banana yellow
uniform vec3 color_crest  : source_color = vec3(1.0, 0.98, 0.92);  // light cream

uniform float ambient_light = 0.4;
uniform vec3 light_direction = vec3(-0.4, -1.0, -0.2);

uniform sampler2D noise_texture;
uniform float noise_scale : hint_range(1.0, 20.0) = 6.0;
uniform float noise_strength : hint_range(0.0, 0.2) = 0.05;

void fragment() {
	vec3 N = normalize(NORMAL);
	vec3 L = normalize(-light_direction);
	float lighting = max(dot(N, L), 0.0);
	lighting = mix(ambient_light, 1.0, lighting);

	// Ridge pattern based on UV.x
	float wave = sin(UV.x * ridge_frequency * 6.2831);
	float ridge = pow(abs(wave), ridge_sharpness);

	// Blend from valley → mid → crest
	vec3 ridge_base = mix(color_valley, color_mid, ridge);
	vec3 ridge_color = mix(ridge_base, color_crest, pow(ridge, 3.0)); // crest accent

	float v_fade = clamp(UV.y, 0.0, 1.0);
	ridge_color = mix(ridge_color, color_valley, pow(1.0 - v_fade, 2.0));  // darker at base

	// Add pastel noise detail
	vec2 noise_uv = UV * noise_scale;
	float n = texture(noise_texture, noise_uv).r;
	ridge_color *= 1.0 - (1.0 - n) * noise_strength;


// Soft vertical gradient from base green to ridge_color
	float vertical_blend = pow(clamp(UV.y, 0.0, 1.0), 1.5);
	vec3 vertical_tint = mix(color_valley, ridge_color, vertical_blend);
	ALBEDO = vertical_tint * lighting;
	ROUGHNESS = 0.85;
	SPECULAR = 0.05;
}
