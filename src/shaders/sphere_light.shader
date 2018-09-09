shader_type canvas_item;
render_mode blend_add;

uniform sampler2D tex;

void fragment(){
    
    vec3 cLight = normalize(vec3(0.0, -1.0, 1.0));

    vec2 center = vec2(0.5, 0.5);
    float radius = 0.5;
    
    vec2 position = UV - center;
    
    float z = sqrt(radius * radius - position.x * position.x - position.y * position.y);
    vec3 normal = normalize(vec3(position.x, position.y, z));
    if (length(position) > radius) {
        discard;
    } else {
        float diffuse = max(0.0, dot(normal, cLight));
        vec4 sample = texture(TEXTURE,UV);
        COLOR = vec4(vec3(min(0.7, diffuse)),1.0) * sample;
    }
}