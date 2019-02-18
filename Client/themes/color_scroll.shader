shader_type canvas_item;

uniform float offset;

void fragment() {
	float t = cos(TIME + offset);
	COLOR = vec4(t, t, t, 1);
}