unitsize(1cm);

pen B[] = { rgb("2e75b6"), rgb("5b9bd5"), rgb("9dc3e6") };
pen O[] = { rgb("000000"), rgb("ed7d31"), rgb("f9cbad") };
pen G[] = { rgb("000000"), rgb("70ad47"), rgb("a9d18e") };

void draw_pixelgrid(int w, int h, pen lines = lightgray, pen dots = invisible) {
	for (int x = 0; x <= w; ++x)
		draw((x,0)--(x,h), lightgray);
	for (int y = 0; y <= h; ++y)
		draw((0,y)--(w,y), lightgray);
	for (int x = 0; x < w; ++x)
		for (int y = 0; y < h; ++y)
			dot((x+.5,y+.5), linewidth(4)+dots);
}

struct pixel_pos {
	int x, y;
	void operator init(int x, int y) {
		this.x = x;
		this.y = y;
	}
};

void draw_pixel(real x, real y, pen border = black+linewidth(2), pen fill = lightgray) {
	void draw_pixel_discrete(int x, int y) {
		filldraw((x,y)--(x+1,y)--(x+1,y+1)--(x,y+1)--cycle, fill, border);
	}
	draw_pixel_discrete((int)x, (int)y);
}

pair line_normal(pair a, pair b) {
	pair v = b-a;
	v = v/sqrt(dot(v,v));
	return (-v.y,v.x);
}

struct tri {
	pair a, b, c;
	void operator init(pair a, pair b, pair c) {
		this.a = a;
		this.b = b;
		this.c = c;
	}
	void draw(pen outline = black+linewidth(2), pen inner = invisible, bool labels=true) {
		filldraw(a--b--c--cycle, inner, outline);
		if (labels) {
			label("\huge$a$", a - .5*unit(line_normal(a,b)+line_normal(c,a)));
			label("\huge$b$", b - .5*unit(line_normal(a,b)+line_normal(b,c)));
			label("\huge$c$", c - .5*unit(line_normal(b,c)+line_normal(c,a)));
		}
	}
};

int res_x = 16, res_y = 9;

/*
 * Aufgabe 5.
 * Erweitern Sie diese Funktion wie beschrieben.
 *
 */
void raster_signed_distance(tri tri, bool draw_bb=false, bool use_bb=true) {
	// Bounding Box berechnen
	int x_min = (int)floor(min(tri.a.x, tri.b.x, tri.c.x));
	int x_max = (int)ceil( max(tri.a.x, tri.b.x, tri.c.x));
	int y_min = (int)floor(min(tri.a.y, tri.b.y, tri.c.y));
	int y_max = (int)ceil( max(tri.a.y, tri.b.y, tri.c.y));
	if (!use_bb) {
		x_min = y_min = 0;
		x_max = res_x;
		y_max = res_y;
	}
	if (draw_bb) {
		draw((x_min,y_min)--(x_max,y_min)--(x_max,y_max)--(x_min,y_max)--cycle);
	}
	// Normalen berechnen
	pair n_a = line_normal(tri.a, tri.b);
	pair n_b = line_normal(tri.b, tri.c);
	pair n_c = line_normal(tri.c, tri.a);
	for (int y = y_min; y <= y_max; y += 1)
		for (int x = x_min; x <= x_max; x += 1) {
			bool hit = false;
			bool point_in_tri(real pixel_x, real pixel_y) {
				if (dot(n_a, (pixel_x, pixel_y) - tri.a) < 0) return false;
				if (dot(n_b, (pixel_x, pixel_y) - tri.b) < 0) return false;
				if (dot(n_c, (pixel_x, pixel_y) - tri.c) < 0) return false;
				return true;
			}
			real pixel_x = x + 0.5;
			real pixel_y = y + 0.5;
			hit = point_in_tri(pixel_x, pixel_y);
			if (hit)
				draw_pixel(x, y, B[1], B[2]);
		} 
}

/*
 * Aufgabe 5.
 * Demonstrieren Sie ihre Implementierung mit einzelnen Beispielen.
 * Gruppierung in {} der Übersichtlichkeit halber.
 *
 */

{
	tri tri = tri((10.2,8.3), (2.7,2.2), (14.3,1.1));

	draw_pixelgrid(res_x,res_y,dots=lightgray);

	raster_signed_distance(tri, draw_bb=true, use_bb=true);
	tri.draw(B[1]+linewidth(2));

	shipout("raster-tri-1.pdf"); erase();
}


{
	tri tri = tri((12.4,6.3),(11.1,1.7),(14.9,3.7));

	draw_pixelgrid(res_x,res_y,dots=lightgray);

	raster_signed_distance(tri, draw_bb=true, use_bb=true);
	tri.draw(B[1]+linewidth(2));

	shipout("raster-tri-2.pdf"); erase();
}

/* 
 * Performance Abschätzung -- kann nur einen groben Überblick geben.
 * Achtung, je nach System kann das lange dauern, passen Sie die Schleifengrenzen ggf an.
 *
 */
bool perf = false;
if (perf) {
	res_x = res_y = 128;
	tri tri = tri((12.4,6.3),(11.1,1.7),(14.9,3.7));

	draw_pixelgrid(res_x,res_y,dots=lightgray);
	tri.draw(B[1]+linewidth(2));

	int a = seconds();
	for (int i = 0; i < 500; ++i)
		raster_signed_distance(tri, draw_bb=false, use_bb=false);
	int b = seconds();
	for (int i = 0; i < 500; ++i)
		raster_signed_distance(tri, draw_bb=false, use_bb=true);
	int c = seconds();

	write(b-a, c-b);
}
