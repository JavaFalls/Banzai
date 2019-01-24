shader_type canvas_item;

varying vec2 point;
varying vec4 color;

void vertex() {
	
}

void fragment() {
	if (TIME > 0.4) {
		COLOR.b = 0.5;
	}
}