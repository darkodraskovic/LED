SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 LED_pivot;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 drawoffset;

in vec3 vertex_position;
in vec2 vertex_texcoords0;

out vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]-LED_pivot, 1.0, 1.0));
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 LED_pivot;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 drawoffset;

in vec3 vertex_position;
in vec2 vertex_texcoords0;

out vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]-LED_pivot, 1.0, 1.0));
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

uniform vec4 LED_drawcolor;
uniform sampler2D texture0;

in vec2 ex_texcoords0;

out vec4 fragData0;

void main(void)
{
	vec4 color = LED_drawcolor;
	color.a *= texture(texture0,ex_texcoords0).a;
	fragData0 = color;
}
