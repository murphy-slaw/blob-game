shader_type canvas_item;

render_mode blend_mix;

// Wind settings.
uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0);
uniform float maxStrength : hint_range(0.0, 1.0);
uniform float strengthScale = 100.0;
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform float heightOffset = 0.0;

float noise(vec2 p, float ltime)
{
  return sin(p.x*10.0) * sin(p.y*(3.0 + sin(ltime/11.0))) + .2; 
}

//float getWind(vec2 vertex, vec2 uv, float timer){
//        vec2 pos = mix(vec2(1.0), vertex, distortion).xy;
//        float time = noise(pos, timer) * speed;
////        float time = timer * speed + pos.x * pos.y;
//        float diff = pow(maxStrength - minStrength, 2);
//        float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength) * strengthScale;
//        float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, (1.0-uv.y) - heightOffset);
//
//        return wind;
//        }
//
//void vertex() {
//        VERTEX.x += getWind(VERTEX, UV, TIME);
//        VERTEX.y += getWind(VERTEX, UV, TIME);
//}


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
  vec2 p = FRAGCOORD.xy / vec2(1280.0,720.0);
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
  COLOR = vec4(col*vig,1.0);
}
