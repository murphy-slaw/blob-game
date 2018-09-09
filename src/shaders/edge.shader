shader_type canvas_item;

uniform float Threshold = 0.01;
uniform vec4 EdgeColor : hint_color = vec4(vec3(0.0),1.0);

void fragment(){
    vec4 col = textureLod(SCREEN_TEXTURE, SCREEN_UV, 8.0);
    
    vec4 avg_color = vec4(0.0);
    
    for(float j = -1.0; j < 2.0; j++){
        for (float k = -1.0; k < 2.0; k++) {
            vec2 offset = vec2(j,k);
            if (offset == vec2(0.0)) continue;
            avg_color = texture(SCREEN_TEXTURE, SCREEN_UV + (offset * SCREEN_PIXEL_SIZE));
        }
    }
    avg_color /= 8.0;
    
    COLOR =  mix(col, EdgeColor, step(Threshold, length(avg_color - col)));
    COLOR = vec4(1.0);
}