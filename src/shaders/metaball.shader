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

vec4 surrounding_average(sampler2D tex, vec2 pos, vec2 pixel_size, float radius, float lod){
    vec4 avg_color;

    for(float j = -radius; j <= radius; j++){
        for (float k = -radius; k <= radius; k++) {
            vec2 offset = vec2(j,k);
            if (offset == vec2(0.0)) continue;
            vec4 pixel = textureLod(tex, pos + (offset * pixel_size), lod);
            avg_color += floor(pixel * 1.5);
        }
    }
    avg_color /= pow(radius * 2.0, 2.0) - 1.0;
    return avg_color;
}


void fragment () {
    float border_width = 2.0;
    float lod = 2.0;
    vec2 frag = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;
    vec4 foreground = water_caustic(TIME, frag);
    vec4 pixel = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    vec4 fg =  floor(pixel * 1.5);
    vec4 bg = vec4(1.0) - fg;
    vec4 fgcolor = fg * foreground;
    vec4 bgcolor = bg * background;
    
    pixel = fgcolor + bgcolor;

    vec4 avg = surrounding_average(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE, border_width, lod);
    
    if (avg.r < 1.0 && avg.r > 0.0) {
        COLOR = vec4(0.0, 0.25, 0.0, 1);
    } else {
        COLOR  = pixel;
    }
}