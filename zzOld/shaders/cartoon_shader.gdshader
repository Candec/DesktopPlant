shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.3, 1.0, 0.3, 1.0);

void fragment() {
	vec3 light_dir = normalize(vec3(0.0, 1.0, -1.0));
	float light_val = max(0.0, dot(NORMAL, light_dir));

	if (light_val > 0.7)
		ALBEDO = base_color.rgb * 1.0;
	else if (light_val > 0.4)
		ALBEDO = base_color.rgb * 0.75;
	else
		ALBEDO = base_color.rgb * 0.5;
}
