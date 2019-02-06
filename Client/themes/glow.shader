shader_type canvas_item;

vec4 glow_pixel(sampler2D tex, vec2 uv) {
	float hdr_threshold = 0.1;
	return max(textureLod(tex, uv, 2.0) - hdr_threshold, vec4(0.0));
}

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	
	vec4 col0 = glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
	vec4 col1 = glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
	vec4 col2 = glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
	vec4 col3 = glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));
	
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 blur = 0.25 * (col0 + col1 + col2 + col3);
	
	COLOR = vec4(col.rgb + blur.rgb, col.a);
}