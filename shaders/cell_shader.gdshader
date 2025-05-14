shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.2, 0.8, 0.3, 1.0);
uniform int steps = 3;

void fragment() {
	float light_strength = dot(NORMAL, normalize(vec3(0.0, 1.0, 1.0)));
	light_strength = clamp(light_strength, 0.0, 1.0);

	float shade = floor(light_strength * float(steps)) / float(steps);
	ALBEDO = base_color.rgb * shade;
}