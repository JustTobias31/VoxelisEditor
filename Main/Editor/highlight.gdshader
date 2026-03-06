shader_type spatial;
render_mode unshaded, depth_test_disabled, blend_mix;
uniform bool highlight = false;

void fragment() {
    ALBEDO = vec3(ALBEDO.x, ALBEDO.y, (ALBEDO.z + 0.5) / 2.0);
	if (highlight) {
    	ALPHA = sin(TIME*2.0) * 0.1+ 0.1; // 0.0 = fully transparent, 1.0 = fully opaque
	} else {
		ALPHA = 0.0;
	}
}