shader_type spatial;

uniform vec3 color_top = vec3(1.0, 0.9, 0.6);
uniform vec3 color_bottom = vec3(0.2, 0.6, 0.3);
uniform vec3 ridge_color = vec3(1.0, 0.95, 0.8);

uniform float ridge_frequency = 8.0;
uniform float ridge_sharpness = 3.0;

uniform sampler2D noise_texture;
uniform float noise_scale = 5.0;
uniform float noise_strength = 0.1;

uniform vec3 light_direction = vec3(-0.4, -1.0, -0.3);
uniform float ambient_light = 0.3;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs((q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(0., 1./3., 2./3.)) * 6. - 3.);
    vec3 rgb = c.z * mix(vec3(1.), clamp(p - 1., 0., 1.), c.y);
    return rgb;
}

void fragment() {
    vec3 N = normalize(NORMAL);
    vec3 L = normalize(-light_direction);
    float diff = max(dot(N, L), 0.0);
    float lighting = mix(ambient_light, 1.0, diff);

    // Use vertex color r for angle, wrapped in [0,1]
    float angle = fract(UV.x);

    // Ridge pattern: sine wave with frequency and softened edges
    float ridge_mask = smoothstep(0.3, 1.0, 1.0 - abs(sin(angle * ridge_frequency * 6.2831853)));
    ridge_mask = pow(ridge_mask, ridge_sharpness);

    // Vertical gradient from bottom to top (using UV.y)
    float v = clamp(UV.y, 0.0, 0.7);
    vec3 base_color = mix(color_bottom, color_top, v);

    // Blend ridge highlight softly, modulated by vertical fade
    vec3 color = mix(base_color, ridge_color, ridge_mask * (1.0 - v) * 0.5);

	vec3 color_hsv = rgb2hsv(color);
	color_hsv.y = clamp(color_hsv.y * 1.5, 0.0, 1.0); // Increase saturation 30%
	color = hsv2rgb(color_hsv);

    // Apply subtle noise to color only
    float noise_val = texture(noise_texture, UV * noise_scale).r;
    color *= mix(1.0, noise_val, noise_strength);

    ALBEDO = color * lighting;
    ROUGHNESS = 0.85;
    SPECULAR = 0.05;
}
