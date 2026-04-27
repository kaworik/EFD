shader_type spatial;

render_mode cull_disabled;

uniform sampler2D Texture:source_color,filter_nearest;
uniform sampler2D Normal_Map : hint_normal;


group_uniforms Wave;
uniform float Wave_Speed = 5.0;
uniform float Wave_Size = 0.1;
uniform float Wave_Repeat = 5.0;
uniform sampler2D Wave_Power_Texture:source_color;
uniform bool Vertical_Gradient = true;


group_uniforms Rotation;
uniform float Rotate_Deg ;


group_uniforms Bend;
uniform float Bend_Angle = 0.0;


group_uniforms Material;
uniform float Normal_Map_Depth = 1.0;
uniform float Metallic = 0.0;
uniform float Roughness = 0.5;



vec2 rotate_uv(vec2 uv, float deg) {
	float rad = radians(deg);
	mat2 rot = mat2(vec2(cos(rad), -sin(rad)),vec2(sin(rad),  cos(rad)));
	return (rot * (uv - 0.5)) + 0.5;
}

void vertex() {
	vec2 uv = UV;
	uv = rotate_uv(uv,Rotate_Deg);

	float Wave_Base = sin((uv.y * Wave_Repeat) + (-Wave_Speed * TIME));
	
	float Power_UV = clamp(UV.y,0.01,0.99);
	float Wave_Power;
	if (Vertical_Gradient) {
		Wave_Power = texture(Wave_Power_Texture, vec2(0.5, Power_UV)).r;
	} else {
		Wave_Power = texture(Wave_Power_Texture, vec2(Power_UV, 0.5)).r;
	}
	
	
	float Sin_Value = Wave_Base * Wave_Size * Wave_Power ;
	
	
	
	VERTEX.z = Sin_Value;
	
	// Bend around cylindrical tower
	float angle_rad = radians(Bend_Angle * UV.x);
	float cos_a = cos(angle_rad);
	float sin_a = sin(angle_rad);
	float orig_x = VERTEX.x;
	float orig_z = VERTEX.z;
	VERTEX.x = cos_a * orig_x - sin_a * orig_z;
	VERTEX.z = sin_a * orig_x + cos_a * orig_z;
}


void fragment() {
	vec4 Final_Color =  texture(Texture,UV);
	ALBEDO = Final_Color.rgb;
	ALPHA = Final_Color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	NORMAL_MAP = texture(Normal_Map, UV).rgb;
	NORMAL_MAP_DEPTH = Normal_Map_Depth;
	METALLIC = Metallic;
	ROUGHNESS = Roughness;
}
