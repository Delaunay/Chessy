shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D tex_frg_2 : hint_albedo;
uniform sampler2D tex_frg_3 : hint_albedo;



void vertex() {
// Output:0

}

void fragment() {
// Texture:2
	vec4 tex_frg_2_read = texture(tex_frg_2, UV.xy);
	vec3 n_out2p0 = tex_frg_2_read.rgb;
	float n_out2p1 = tex_frg_2_read.a;

// Texture:3
	vec3 n_out3p0 = vec3(0, 0, 0);
	float n_out3p1 = 0.0;
	// ivec2 size = textureSize(tex_frg_3, 1);
	
	// if (size.x > 1){
		vec4 tex_frg_3_read = texture(tex_frg_3, UV.xy);
		n_out3p0 = tex_frg_3_read.rgb;
		n_out3p1 = tex_frg_3_read.a;
	// }

// VectorOp:4
	vec3 n_out4p0 = n_out2p0 + n_out3p0;

// ScalarOp:5
	float n_out5p0 = n_out2p1 + n_out3p1;

// Output:0
	ALBEDO = n_out4p0;
	ALPHA = n_out5p0;

}

void light() {
// Output:0

}
