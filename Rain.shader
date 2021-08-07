shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo;
uniform vec4 transmission : hint_color;

uniform float screen_sample_offset = 0.1;
uniform float sample_mip = 5.0;

uniform bool use_screentex = false;
uniform float passthrough = 1.0;
uniform float const_emit = 0.005;


void vertex() {
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.a;
	ALPHA = albedo.a * albedo_tex.a;
	TRANSMISSION = transmission.rgb;
	
	if (use_screentex) {
		vec4 col = textureLod(SCREEN_TEXTURE, SCREEN_UV + (albedo_tex.rg - 0.5) * screen_sample_offset, sample_mip);
		col *= albedo.a;
		EMISSION = col.rgb * passthrough + const_emit;
	
	} else {
		EMISSION = vec3(const_emit);
	}
}
