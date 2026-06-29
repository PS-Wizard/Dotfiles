#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(vec3(g), c.a);
}
