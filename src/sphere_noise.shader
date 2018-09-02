shader_type canvas_item;

/**
Maps object texture onto a sphere and applies a spherical normal
based on a simulated light.

Adapted from
https://www.raywenderlich.com/2323-opengl-es-pixel-shaders-tutorial
and
https://gamedev.stackexchange.com/a/9385
**/

vec3 hash( vec3 p ) {
  p = vec3( dot(p,vec3(127.1, 311.7, 74.7)),
            dot(p,vec3(269.5, 183.3, 246.1)),
            dot(p,vec3(113.5, 271.9, 124.6)));

  return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// return value noise (in x) and its derivatives (in yzw)
vec4 noised( in vec3 x ) {
  // grid
  vec3 p = floor(x);
  vec3 w = fract(x);

  // quintic interpolant
  vec3 u = w * w * w * (w * (w * 6.0 - 15.0) + 10.0);
  vec3 du = 30.0 * w * w * (w * (w - 2.0) + 1.0);

  // gradients
  vec3 ga = hash( p + vec3(0.0, 0.0, 0.0) );
  vec3 gb = hash( p + vec3(1.0, 0.0, 0.0) );
  vec3 gc = hash( p + vec3(0.0, 1.0, 0.0) );
  vec3 gd = hash( p + vec3(1.0, 1.0, 0.0) );
  vec3 ge = hash( p + vec3(0.0, 0.0, 1.0) );
  vec3 gf = hash( p + vec3(1.0, 0.0, 1.0) );
  vec3 gg = hash( p + vec3(0.0, 1.0, 1.0) );
  vec3 gh = hash( p + vec3(1.0, 1.0, 1.0) );

  // projections
  float va = dot( ga, w - vec3(0.0, 0.0, 0.0) );
  float vb = dot( gb, w - vec3(1.0, 0.0, 0.0) );
  float vc = dot( gc, w - vec3(0.0, 1.0, 0.0) );
  float vd = dot( gd, w - vec3(1.0, 1.0, 0.0) );
  float ve = dot( ge, w - vec3(0.0, 0.0, 1.0) );
  float vf = dot( gf, w - vec3(1.0, 0.0, 1.0) );
  float vg = dot( gg, w - vec3(0.0, 1.0, 1.0) );
  float vh = dot( gh, w - vec3(1.0, 1.0, 1.0) );

  // interpolations
  return vec4( va + u.x*(vb-va) + u.y*(vc-va) + u.z*(ve-va) + u.x*u.y*(va-vb-vc+vd) + u.y*u.z*(va-vc-ve+vg) + u.z*u.x*(va-vb-ve+vf) + (-va+vb+vc-vd+ve-vf-vg+vh)*u.x*u.y*u.z,    // value
               ga + u.x*(gb-ga) + u.y*(gc-ga) + u.z*(ge-ga) + u.x*u.y*(ga-gb-gc+gd) + u.y*u.z*(ga-gc-ge+gg) + u.z*u.x*(ga-gb-ge+gf) + (-ga+gb+gc-gd+ge-gf-gg+gh)*u.x*u.y*u.z +   // derivatives
               du * (vec3(vb,vc,ve) - va + u.yzx*vec3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf) + u.zxy*vec3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg) + u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh) ));
}


vec3 rgb2hsb(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                vec4(c.gb, K.xy),
                step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                vec4(c.r, p.yzx),
                step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsb2rgb(vec3 c){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                    6.0)-3.0)-1.0,
                    0.0,
                    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


uniform float rot_speed = 0.0;
uniform float pi = 3.14159;

void fragment() {
    float x = (UV.x - 0.5) * 2.0;
    float y = (UV.y - 0.5)  * 2.0;
    float r = sqrt((x*x) + (y*y));
    
    float d = bool(r) ? asin(r)/r : 0.0;
    float x2 = d * x;
    float y2 = d * y;
    
    float x3 = 0.0;
    if (rot_speed > 0.0){
        x3 =  mod(x2 / (4.0 * pi) + 0.5 + TIME / (1.0 /rot_speed), 1.0);
    } else {
        x3 = x2/ (2.0 * pi) +0.5;
    }
    float y3 = y2 / (2.0 * pi) + 0.5;
    
    r = 0.5;
    vec2 center = vec2(r);
    vec2 position = UV - center;
    
    float z = sqrt(r * r - position.x * position.x - position.y * position.y);
    vec3 normal = vec3(position.x, position.y, z);
    
    vec4 n = noised(normal * 10.0);
    n += noised(normal * 10.0) * 0.25;
    n += noised(normal * 20.0) * 0.125;
    n += noised(normal * 40.0) * 0.0625;
    
    normal =  normalize(normal + n.xyz / 40.0);
    NORMAL = normal;

    
    vec4 col = texture(TEXTURE,vec2(x3, y3)); //grab sphere-mapped pixel from texture
    if (length(position) > r) { //discard pixels outside the sphere
        discard;
    } else {
//        COLOR = col;
//        col.xyz -= vec3(n.x * 0.5 + 0.25);
//        col.xyz += mix(vec3(0.05, 0.3, 0.5), vec3(0.2, 0.2, 0.1), smoothstep(-0.2, 0.0, n.x));
//        col.xyz /= 2.0;
        col = vec4(sqrt(1.0 - col.r), cos(col.g),tan(col.b),col.a);
//        vec3 hsb = rgb2hsb(col.rgb);
//        hsb.x += cos(floor(TIME/10.0));
//        hsb.y *= 0.8;
//        hsb.z *= 1.2;
//        col.rgb = hsb2rgb(hsb.rgb);
        COLOR = col;
    
    }
}