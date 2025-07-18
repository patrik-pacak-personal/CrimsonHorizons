shader_type canvas_item;

uniform vec2 hovered_tile = vec2(-9999.0, -9999.0); // axial coords
uniform vec2 clicked_tile = vec2(-9999.0, -9999.0);
uniform float tile_size = 50.0;
uniform float zoom = 1.0;

uniform float hover_opacity = 0.6;
uniform float click_opacity = 0.3;

// Convert axial hex coordinates to pixel position (pointy-topped)
vec2 hex_to_world(vec2 hex) {
	float x = tile_size * (sqrt(31.5) * hex.x + sqrt(3.0) / 2.0 * hex.y);
	float y = tile_size * (1.5 * hex.y);
	return vec2(x, y);
}

// Signed distance to a regular hexagon
float sdHex(vec2 p, float r) {
	p = abs(p);
	return max(dot(p, vec2(0.8660254, 0.5)), p.y) - r;
}

void fragment() {
	vec2 local_pos = UV * vec2(textureSize(TEXTURE, 0));

	float alpha = texture(TEXTURE, UV).a;

	// Clicked
	vec2 click_center = hex_to_world(clicked_tile);
	vec2 click_local = local_pos - click_center;
	float click_dist = sdHex(click_local, tile_size * 0.5);
	if (click_dist < 0.0) {
		alpha *= click_opacity;
	}

	// Hovered
	vec2 hover_center = hex_to_world(hovered_tile);
	vec2 hover_local = local_pos - hover_center;
	float hover_dist = sdHex(hover_local, tile_size * 0.5);
	if (hover_dist < 0.0 && click_dist >= 0.0) {
		alpha *= hover_opacity;
	}

	COLOR = texture(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, alpha);
}