shader_type canvas_item;

/**
Maps object texture onto a sphere and applies a spherical normal
based on a simulated light.

Adapted from
https://www.raywenderlich.com/2323-opengl-es-pixel-shaders-tutorial
and
https://gamedev.stackexchange.com/a/9385
**/

uniform float rot_speed = 0.0;
uniform vec3 light_vec = vec3(0.0, 0.0, 1.0);
uniform float steepness = 4.0;

void fragment() {
    float pi = 3.14159;
    float x = (UV.x - 0.5) * 2.0;
    float y = (UV.y - 0.5)  * 2.0;
    float r = sqrt((x*x) + (y*y));
    
    float d = bool(r) ? asin(r)/r : 0.0;
    float x2 = d * x;
    float y2 = d * y;
    
    float x3 = x2/ (2.0 * pi) +0.5;
//    float x3 =  mod(x2 / (4.0 * pi) + 0.5 + TIME / (1.0 /rot_speed), 1.0);
    float y3 = y2 / (2.0 * pi) + 0.5;
    

    r = 0.5;
    vec2 center = vec2(r);
    vec2 position = UV - center;
    
        
    float z = sqrt(r * r - position.x * position.x - position.y * position.y);
    vec3 normal = vec3(position.x, position.y, z);
    NORMAL = normalize(normal);
}