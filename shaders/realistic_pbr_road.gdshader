shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ==============================================================================
// REALISTIC PBR ROAD & MONSOON PUDDLE SHADER
// Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
// Purpose: High-fidelity road asphalt with painted markings, dynamic wetness,
//          fresnel reflections, and procedural puddle accumulation.
// ==============================================================================

uniform vec4 asphalt_color : source_color = vec4(0.18, 0.19, 0.21, 1.0);
uniform vec4 road_marking_color : source_color = vec4(0.92, 0.85, 0.35, 1.0);

uniform float wetness_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float puddle_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float roughness_dry : hint_range(0.0, 1.0) = 0.85;
uniform float roughness_wet : hint_range(0.0, 1.0) = 0.08;

// Procedural hash for noise
float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	
	// Base asphalt color
	vec3 col = asphalt_color.rgb;
	
	// Painted road center line stripe (every 16m wide road centered)
	float dist_from_center = abs(UV.x - 0.5);
	if (dist_from_center < 0.015) {
		col = road_marking_color.rgb;
	}
	
	// Procedural puddle accumulation
	float n = fbm(world_pos * 0.12);
	float puddle = smoothstep(puddle_threshold - 0.1, puddle_threshold + 0.1, n * wetness_intensity);
	
	// Wet asphalt darkens by 25%
	col *= (1.0 - wetness_intensity * 0.25);
	
	// Roughness drops significantly in wet areas and puddles
	float final_roughness = mix(roughness_dry, roughness_wet, max(wetness_intensity * 0.5, puddle));
	
	// Normal ripple effect if rain is falling
	vec3 norm = NORMAL;
	if (wetness_intensity > 0.5) {
		float ripple = sin(world_pos.x * 20.0 + TIME * 12.0) * cos(world_pos.y * 20.0 + TIME * 12.0);
		norm.xz += ripple * 0.02 * puddle;
	}
	
	ALBEDO = col;
	ROUGHNESS = final_roughness;
	SPECULAR = mix(0.2, 0.9, puddle);
	METALLIC = 0.02;
	NORMAL = normalize(norm);
}
