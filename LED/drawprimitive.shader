SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 LED_pivot;
uniform vec2 position[4];

// in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]-LED_pivot, 0.0, 1.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 LED_pivot;
uniform vec2 position[4];

// in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]-LED_pivot, 0.0, 1.0));
}
@OpenGL4.Fragment
#version 400

uniform vec4 LED_drawcolor;

out vec4 fragData0;

void main(void)
{
    fragData0 = LED_drawcolor;
}
