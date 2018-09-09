shader_type canvas_item;

render_mode blend_mix;

float noise(vec2 p, float ltime)
{
  return sin(p.x*10.0) * sin(p.y*(3.0 + sin(ltime/11.0))) + .2; 
}

mat2 rotate(float angle)
{
  return mat2(vec2(cos(angle), -sin(angle)),vec2( sin(angle), cos(angle)));
}

float fbm(vec2 p, float ltime)
{
  p *= 1.1;
  float f = 0.0;
  float amp = 0.5;
  for( int i = 0; i < 3; i++) {
    mat2 modify = rotate(ltime/50.0 * float(i*i));
    f += amp*noise(p, ltime);
    p = modify * p;
    p *= 2.0;
    amp /= 2.2;
  }
  return f;
}

float pattern(vec2 p, out vec2 q, out vec2 r, float ltime) {
  q = vec2( fbm(p + vec2(1.0),ltime),
	    fbm(rotate(0.1*ltime)*p + vec2(3.0),ltime));
  r = vec2( fbm(rotate(0.2)*q + vec2(0.0),ltime),
	    fbm(q + vec2(0.0),ltime));
  return fbm(p + 1.0*r, ltime);

}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment () {
  vec2 p = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;
  float ltime = TIME;
  float ctime = TIME + fbm(p/8.0, ltime)*40.0;
  float ftime = fract(ctime/6.0);
  ltime = floor(ctime/6.0) + (1.0-cos(ftime*3.1415)/2.0);
  ltime = ltime*6.0;
  vec2 q;
  vec2 r;
  float f = pattern(p, q, r, ltime);
  vec3 col = hsv2rgb(vec3(q.x/10.0 + ltime/100.0 + 0.4, abs(r.y)*3.0 + 0.1, r.x + f));
  float vig = 1.0 - pow(4.0*(p.x - 0.5)*(p.x - 0.5), 10.0);
  vig *= 1.0 - pow(4.0*(p.y - 0.5)*(p.y - 0.5), 10.0);
  vec4 pixel = vec4(col*vig, 1.0);


    vec3 cLight = normalize(vec3(0.0, -0.5, 1.0));

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
        COLOR = diffuse * pixel;
    }
}
