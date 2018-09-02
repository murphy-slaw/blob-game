shader_type canvas_item;
uniform sampler2D tex;

void fragment(){
    
    vec3 cLight = normalize(vec3(-0.5, -0.5, 1.0));

    vec2 center = vec2(0.5, 0.5);
    float radius = 0.5;
    
    vec2 position = UV - center;
    
    float z = sqrt(radius * radius - position.x * position.x - position.y * position.y);
    vec3 normal = normalize(vec3(position.x, position.y, z));
    if (length(position) > radius) {
        discard;
    } else {
        float diffuse = max(0.0, dot(normal, cLight));
        vec4 sample = texture(SCREEN_TEXTURE,SCREEN_UV);
        COLOR = vec4(vec3(diffuse), 1.0) * sample;
    }
}