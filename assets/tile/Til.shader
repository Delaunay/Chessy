shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D tex_frg_2;
varying vec4 custom_data;


void vertex() {
// Output:0
	custom_data = INSTANCE_CUSTOM;
}

void fragment() {
// Texture:2
	vec4 tex_frg_2_read = texture(tex_frg_2, UV.xy);
	vec3 n_out2p0 = tex_frg_2_read.rgb;
	float n_out2p1 = tex_frg_2_read.a;

	float selection = float(custom_data.x > 0.f);
	vec3 n_out3p0 = vec3(0.207843, 0.262745, 0.615686);
	float n_out3p1 = 0.988235;

// Output:0 
	ALBEDO = n_out2p0 + selection * n_out3p0;
}

void light() {
// Output:0

}
