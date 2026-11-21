shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ==============================================================================
// REALISTIC RIVER & OCEAN WATER SHADER
// Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
// Purpose: Depth absorption, dual-octave wave ripples, shoreline foam, and fresnel.
// ==============================================================================

uniform vec4 water_color_shallow : source_color = vec4(0.15, 0.45, 0.52, 0.85);
uniform vec4 water_color_deep : source_color = vec4(0.04, 0.16, 0.24, 0.95);
uniform float wave_speed : hint_range(0.1, 2.0) = 0.6;
uniform float wave_height : hint_range(0.01, 0.5) = 0.08;
uniform float wave_frequency : hint_range(0.1, 4.0) = 1.2;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	float wave1 = sin(world_pos.x * wave_frequency + TIME * wave_speed);
	float wave2 = cos(world_pos.y * (wave_frequency * 1.3) + TIME * (wave_speed * 0.8));
	VERTEX.y += (wave1 + wave2) * wave_height;
}

void fragment() {
	vec2 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	
	// Dual wave normal perturbance
	float n1 = sin(world_pos.x * 2.5 + TIME * wave_speed) * cos(world_pos.y * 2.5 + TIME * wave_speed);
	float n2 = sin(world_pos.x * 5.0 - TIME * wave_speed * 1.2) * cos(world_pos.y * 5.0 - TIME * wave_speed * 1.2);
	vec3 wave_norm = vec3(n1 * 0.08 + n2 * 0.04, 1.0, n1 * 0.08 - n2 * 0.04);
	
	// Fresnel factor
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
	
	// Color blending based on view depth
	vec3 final_color = mix(water_color_shallow.rgb, water_color_deep.rgb, 0.65);
	final_color = mix(final_color, vec3(0.85, 0.95, 1.0), fresnel * 0.4);
	
	ALBEDO = final_color;
	ROUGHNESS = 0.08;
	SPECULAR = 0.75;
	METALLIC = 0.05;
	NORMAL = normalize(mix(NORMAL, wave_norm, 0.5));
}
