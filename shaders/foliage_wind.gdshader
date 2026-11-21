shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// ==============================================================================
// FOLIAGE WIND & TRANSLUCENCY SHADER
// Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
// Purpose: Natural wind swaying for palms, banyans, tea bushes, and crops with SSS.
// ==============================================================================

uniform vec4 foliage_color : source_color = vec4(0.18, 0.48, 0.22, 1.0);
uniform vec4 foliage_backlight_color : source_color = vec4(0.35, 0.72, 0.32, 1.0);
uniform float wind_speed : hint_range(0.2, 4.0) = 1.2;
uniform float wind_strength : hint_range(0.01, 0.4) = 0.08;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	float height_factor = clamp(VERTEX.y * 0.3, 0.0, 1.0);
	
	// Dynamic wind sway
	float sway = sin(TIME * wind_speed + world_pos.x * 0.4 + world_pos.y * 0.4);
	float gust = sin(TIME * (wind_speed * 0.3) + world_pos.x * 0.1);
	
	VERTEX.x += (sway * 0.7 + gust * 0.3) * wind_strength * height_factor;
	VERTEX.z += (sway * 0.5 - gust * 0.4) * wind_strength * height_factor;
}

void fragment() {
	// Subsurface transmission when facing away from light
	float view_light_dot = clamp(dot(normalize(VIEW), -normalize(NORMAL)), 0.0, 1.0);
	vec3 col = mix(foliage_color.rgb, foliage_backlight_color.rgb, view_light_dot * 0.35);
	
	ALBEDO = col;
	ROUGHNESS = 0.65;
	SPECULAR = 0.2;
}
