shader_type canvas_item;

vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

// Value Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = smoothstep(0.0,1.0,f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}



void fragment()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = UV;
    vec2 aspect = vec2(16.0/9.0,1.0);

    // Time varying pixel color
    vec4 uvblop = vec4((uv-aspect*0.5)*3.0, 0.0, 0.0);
    float rotate = TIME * 0.2;
    uvblop *= vec4(cos(rotate), -sin(rotate), sin(rotate), cos(rotate));
    uvblop += uvblop*smoothstep(2.5, 0.0, length(uvblop))*-3.0;
    vec3 col = vec3(noise(uv*0.2+vec2(0.0,TIME*0.5)))*vec3(0.9,0.2,0.5)*0.85+0.85;
    col.r += noise(uvblop.xy*0.3+vec2(11.0,TIME*0.15))*0.43;
    col.g += noise(uvblop.xy*0.25+vec2(16.0,TIME*0.18))*0.63;
    col.b += noise(uvblop.xy*0.15+vec2(14.0,TIME*0.25))*0.33;
   
    float clod = noise((uvblop.xy *0.5+ vec2(noise(uv*3.3),noise(uv*7.4+vec2(-TIME * 0.1, 0.0))) * 0.5) * 4.0 + vec2(TIME * 0.4, 0.0));
    col.r += (clod-0.35)*1.45 * step(0.14,clod);
    clod = noise((uvblop.xy * 0.5 + vec2(noise(uv * 3.3 + 0.05), noise(uv * 7.4 + vec2(-TIME * 0.1, 0.0) + 0.1)) * 0.5) * 4.0 + vec2(TIME * 0.4, 0.0));
    col.g += (clod-0.35)*1.75 * step(0.17,clod);
	clod = noise((uvblop.xy * 0.5 + vec2(noise(uv * 3.3 + 0.07), noise(uv * 7.4 + vec2(-TIME * 0.1, 0.0) + 0.2)) * 0.5) * 4.0 + vec2(TIME * 0.4, 0.0));
    col.b += (clod-0.25)*1.85 * step(0.1,clod);

    // Output to screen
    COLOR = vec4(col * 0.5 + 0.5, 1.0);
}