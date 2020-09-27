#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
layout (std140, binding = 0) uniform buf {
    mat4 mvp;
    mat4 invm;
} ubuf;
layout (location = 0) in vec4 pos;
layout (location = 1) in vec2 inTexCoords;
layout (location = 2) in vec3 normal;
layout (location = 0) out vec2 texcoord;
layout (location = 1) out vec3 color;
void main() {
   texcoord = inTexCoords;
   vec4 light = ubuf.invm * vec4(normalize(vec3(0.0, 1, 1)), 1.0);
   color = dot(normal, light.xyz)*vec3(1.0, 1.0, 1.0);
   gl_Position = ubuf.mvp * pos;
}
