shader_type canvas_item;

uniform float time;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

uniform vec2 screen_size;

uniform float pixel_size = 4.0;
uniform int offset = 3;
uniform int circle_size = 10;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    if (base.a == 0.0) {
        COLOR = base;
    }

    vec2 fragCoord = UV * screen_size;
    vec2 n = floor(fragCoord / pixel_size);
    vec2 p = n * pixel_size;

    int ym = int(n.x) / circle_size;
    int x = int(n.x) % circle_size;
    int y = (int(n.y) + (ym * offset)) % circle_size;

    vec2 centered = vec2(float(x), float(y)) - vec2(float(circle_size) / 2.0);
    float d = distance(centered, vec2(0.0));
    float time_term = 1.0 + cos(time);
    float sweep_term = 1.0 - (p.x / screen_size.x);
    float threshold = (time_term - sweep_term);

    threshold += progress * 2.0;
    threshold *= float(circle_size);
    float mask = d > threshold ? 1.0 : 0.0;
    base.a *= (1.0 - mask);
    COLOR = base;
}
