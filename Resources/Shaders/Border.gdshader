shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;
//just toying around lol (but works :P)
uniform float pulsating_thickness : hint_range(0, 10) = 0.0;
uniform float alpha_threashold : hint_range(0.0, 1.0);

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1),
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

varying vec4 v_vertex_color;
void vertex() {
	v_vertex_color = COLOR; // Captures modulate * self_modulate * vertex color
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * (line_thickness + (0.5 + cos(TIME) / 2.0) * pulsating_thickness);
	float border = 0.0;

	if (texture(TEXTURE, UV).a <= alpha_threashold || line_thickness == 0.0) {
		border = 0.0;
		// Texture edge
	} else {
		for (int i = 0; i < OFFSETS.length(); i++) {
			vec2 offset_position = UV + size * OFFSETS[i];
			border += 1.0 - texture(TEXTURE, offset_position).a;
			if (offset_position.x < 0.0 || offset_position.x > 1.0 || offset_position.y < 0.0 || offset_position.y > 1.0) {
				border += 1.0;
			}
		}
	}
	border = min(border, 1.0);

	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, line_color, border) * v_vertex_color;
}