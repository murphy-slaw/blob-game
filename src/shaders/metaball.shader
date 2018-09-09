shader_type canvas_item;
render_mode blend_mix;

uniform vec4 background: hint_color = vec4(1.0);
uniform float TAU = 6.28318530718;
uniform int MAX_ITER = 5;


vec4 water_caustic (float iTime, vec2 uv) {
	float time = iTime * .5+23.0;
    vec2 p = mod(uv*TAU, TAU)-250.0;
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
    return vec4(clamp(colour + vec3(0.0, 0.5, 0.35), 0.0, 1.0), 1.0);
}


void fragment () {
    vec4 foreground = water_caustic(TIME, FRAGCOORD.xy * SCREEN_PIXEL_SIZE);
    vec4 pixel = textureLod(SCREEN_TEXTURE, SCREEN_UV, 2.0);
    vec4 fg =  floor(pixel * 1.2);
    vec4 bg = vec4(1.0) - fg;
    vec4 fgcolor = fg * foreground;
    vec4 bgcolor = bg * background;

    COLOR  = fgcolor + bgcolor;
}
