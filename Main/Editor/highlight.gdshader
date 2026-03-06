shader_type spatial;
render_mode unshaded, depth_test_disabled, blend_mix;
uniform bool highlight = false;

varying vec3 bary;

void vertex() {
    // assign barycentric coords per vertex
    int idx = VERTEX_ID % 3;
    if (idx == 0) bary = vec3(1.0, 0.0, 0.0);
    if (idx == 1) bary = vec3(0.0, 1.0, 0.0);
    if (idx == 2) bary = vec3(0.0, 0.0, 1.0);
}

void fragment() {
    ALBEDO = vec3(ALBEDO.x, ALBEDO.y, (ALBEDO.z + 0.5) / 2.0);
	if (highlight) {
    	ALPHA = sin(TIME*2.0) * 0.1+ 0.1; // 0.0 = fully transparent, 1.0 = fully opaque

		vec3 d = fwidth(bary) * 1.0;
	    vec3 a = smoothstep(vec3(0.0), d, bary);
	    float edge = 1.0 - min(a.x, min(a.y, a.z));
	    
		if (edge > 0.0) {
			ALPHA = sin(TIME*2.0) * 0.3 + 0.7;
		}
		
	} else {
		ALPHA = 0.0;
	}
}