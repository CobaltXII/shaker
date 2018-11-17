float random(vec2 seed) 
{
    return fract(sin(dot(seed, vec2(12.9898f, 78.233f))) * 43758.5453123f);
}

float noise(vec2 seed) 
{
    vec2 i = floor(seed);
    vec2 f = fract(seed);

    float a = random(i);

    float b = random(i + vec2(1.0f, 0.0f));
    float c = random(i + vec2(0.0f, 1.0f));
    float d = random(i + vec2(1.0f, 1.0f));

    vec2 u = f * f * (3.0f - 2.0f * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0f - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 seed) 
{
    float v = 0.0f;
    float a = 0.5f;

    vec2 shift = vec2(100.0f);

    mat2 rot = mat2(cos(0.5f), sin(0.5f), -sin(0.5f), cos(0.5f));

    for (int i = 0; i < 5; ++i) 
    {
        v += a * noise(seed);

        seed = rot * seed * 2.0 + shift;

        a *= 0.5;
    }

    return v;
}

void main() 
{
    vec2 seed = glx_FragCoord.xy / glx_Resolution.yy * 3.0f;

    vec3 color = vec3(0.0f);

    vec2 q = vec2(0.0f);

    q.x = fbm(seed + 0.0f * glx_Time);

    q.y = fbm(seed + vec2(1.0f));

    vec2 r = vec2(0.0f);

    r.x = fbm(seed + 1.0f * q + vec2(1.7f, 9.2f) + 0.150f * glx_Time);
    r.y = fbm(seed + 1.0f * q + vec2(8.3f, 2.8f) + 0.126f * glx_Time);

    float f = fbm(seed + r);

    color = mix
    (
        vec3(0.667f, 0.165f, 0.418f),
        vec3(0.667f, 0.084f, 0.299f),
        
        clamp((f * f) * 4.0, 0.0, 1.0)
    );

    color = mix
    (
        color,
        
        vec3(0.265f, 0.185f, 0.127f),

        clamp(length(q), 0.0f, 1.0f)
    );

    color = mix
    (
        color,

        vec3(0.666667f, 1.0f, 1.0f),

        clamp(length(r.x), 0.0f, 1.0f)
    );

    glx_FragColor = vec4((f * f * f + 0.6f * f * f + 0.5f * f) * color, 1.0f);
}
