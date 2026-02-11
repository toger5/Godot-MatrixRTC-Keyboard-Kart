shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    float alpha = tex.a;
    float outline = 0.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            outline += texture(
                TEXTURE,
                UV + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * outline_size
            ).a;
        }
    }

    if (alpha == 0.0 && outline > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = tex;
    }
}
