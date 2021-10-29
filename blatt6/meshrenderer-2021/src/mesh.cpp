#include <vector>
#include <glm/glm.hpp>
#include <glm/gtc/random.hpp>
#include <GL/glew.h>
#include <GL/gl.h>

using namespace std;
using namespace glm;

vector<vec3> vertices;
vector<unsigned> indices;

void add_tri(int a, int b, int c) {
	indices.push_back(a);
	indices.push_back(b);
	indices.push_back(c);
}

void add_vert(float x, float y, float z,
			  float, float, float) {
	vertices.push_back({x,y,z});
}

static GLuint vao = -1;
static GLuint vbo = -1;
static GLuint vbo_col = -1;
static GLuint ibo = -1;

// #define CS_TRI
#define ES_TRI
// #define BUNNY

#define VAO

void load_mesh() {
#ifdef BUNNY
	#include "bunny.data"
#elif defined CS_TRI
	add_vert(-1,-1,0,0,0,0);
	add_vert( 1,-1,0,0,0,0);
	add_vert(0,1,0,0,0,0);
#else
	add_vert( 0, 0,-10,0,0,0);
	add_vert(10, 0,-10,0,0,0);
	add_vert( 0,10,-10,0,0,0);
#endif
	add_tri(0,1,2);


	// TODO: Aufgabe 1.3
	// VAO aufsetzen
	#ifdef VAO
		glGenVertexArrays(1, &vao);

		glBindVertexArray(vao);
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*vertices.size(),
			&vertices[0], GL_STATIC_DRAW);
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(),
			&indices[0], GL_STATIC_DRAW);

		vector<vec3> colors;
		colors.reserve(vertices.size());
		for (int i = 0; i < vertices.size(); i+=3) {
			colors[i+0] = colors[i+1] = colors[i+2] = vec3(linearRand(0.0f,1.0f), linearRand(0.0f,1.0f), linearRand(0.0f,1.0f));
		}
		glBindVertexArray(vao);
		glGenBuffers(1, &vbo_col);
		glBindBuffer(GL_ARRAY_BUFFER, vbo_col);
		glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*vertices.size(), &colors[0], GL_STATIC_DRAW);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindVertexArray(0);
	#else
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*vertices.size(), &vertices[0], GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(), &indices[0], GL_STATIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		vector<vec3> colors;
		colors.reserve(vertices.size());
		for (int i = 0; i < vertices.size(); i+=3) {
			colors[i+0] = colors[i+1] = colors[i+2] = vec3(linearRand(0.0f,1.0f), linearRand(0.0f,1.0f), linearRand(0.0f,1.0f));
		}
		glGenBuffers(1, &vbo_col);
		glBindBuffer(GL_ARRAY_BUFFER, vbo_col);
		glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*vertices.size(), &colors[0], GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	#endif
}

void draw_mesh() {
	#ifdef VAO
		glBindVertexArray(vao);
		glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);
		glBindVertexArray(0);
	#else
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
		
		glBindBuffer(GL_ARRAY_BUFFER, vbo_col);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	#endif
}


