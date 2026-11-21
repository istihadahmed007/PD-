shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Bangladesh Open-World Game: Monsoon Road Wetness & Puddle Shader
uniform vec4 albedo_color : source_color = vec4(0.2, 0.2, 0.22, 1.0);
uniform sampler2D road_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D puddle_noise : hint_default_black, filter_linear_mipmap, repeat_enable;

uniform float base_roughness : hint_range(0.0, 1.0) = 0.85;
uniform float wetness_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float puddle_threshold : hint_range(0.0, 1.0) = 0.55;

void fragment() {
	vec2 uv = UV * 10.0;
	vec4 base_tex = texture(road_texture, uv);
	vec3 base_col = albedo_color.rgb * (base_tex.rgb > vec3(0.01) ? base_tex.rgb : vec3(1.0));
	
	// Sample procedural puddle accumulation
	float noise_val = texture(puddle_noise, UV * 2.5).r;
	float is_puddle = smoothstep(puddle_threshold - 0.1, puddle_threshold + 0.1, noise_val * wetness_intensity);
	
	// Wet asphalt darkens and becomes reflective
	vec3 wet_color = base_col * (1.0 - 0.25 * wetness_intensity);
	float final_roughness = mix(base_roughness, 0.05, max(wetness_intensity * 0.4, is_puddle));
	
	ALBEDO = wet_color;
	ROUGHNESS = final_roughness;
	SPECULAR = mix(0.2, 0.8, is_puddle);
	METALLIC = 0.0;
}
