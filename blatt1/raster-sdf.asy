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

bool check_for_line_intersection(pair line_p1, pair line_p2, pair rectangle_p3, pair rectangle_p4) {
	real y = ((line_p1.y * line_p2.x) - (rectangle_p3.y * line_p2.x) + (rectangle_p3.x * line_p2.y) -
		(line_p1.x * line_p2.y)) / ((line_p2.x * rectangle_p4.y) - (rectangle_p4.x * line_p2.y));

	if (y > 0) {
		write(y);
		return true;
	}

	return false;
}

bool check_for_rectangle_intersection(pair line_p1, pair line_p2, pair p0, pair p1, pair p2, pair p3) {
	return (
		check_for_line_intersection(line_p1, line_p2, p0, p1) ||
		check_for_line_intersection(line_p1, line_p2, p1, p3) ||
		check_for_line_intersection(line_p1, line_p2, p3, p2) ||
		check_for_line_intersection(line_p1, line_p2, p2, p0)
	);

	// return (
	// 	(check_for_line_intersection(line_p1, line_p2, p0, p1) &&
	// 	check_for_line_intersection(line_p1, line_p2, p0, p2)) ||
	
	// 	(check_for_line_intersection(line_p1, line_p2, p2, p0) &&
	// 	check_for_line_intersection(line_p1, line_p2, p2, p3)) ||
	
	// 	(check_for_line_intersection(line_p1, line_p2, p2, p3) &&
	// 	check_for_line_intersection(line_p1, line_p2, p1, p3)) ||

	// 	(check_for_line_intersection(line_p1, line_p2, p3, p1) &&
	// 	check_for_line_intersection(line_p1, line_p2, p0, p1)) ||

	// 	(check_for_line_intersection(line_p1, line_p2, p2, p3) &&
	// 	check_for_line_intersection(line_p1, line_p2, p0, p1)) ||

	// 	(check_for_line_intersection(line_p1, line_p2, p2, p0) &&
	// 	check_for_line_intersection(line_p1, line_p2, p3, p1)) 
	// );
}

/*
 * Aufgabe 5 & 6.
 * Erweitern Sie diese Funktion wie beschrieben.
 *
 */
void raster_signed_distance(tri tri, bool draw_bb=false, bool use_bb=true, bool conservative=false) {
	int x_min = 0;
	int x_max = 0;
	int y_min = 0;
	int y_max = 0;
	if (!use_bb) {
		x_min = y_min = 0;
		x_max = res_x;
		y_max = res_y;
	} else {
		x_min = min(floor(tri.a.x), floor(tri.b.x), floor(tri.c.x));
		x_max = max(ceil(tri.a.x), ceil(tri.b.x), ceil(tri.c.x));
		y_min = min(floor(tri.a.y), floor(tri.b.y), floor(tri.c.y));
		y_max = max(ceil(tri.a.y), ceil(tri.b.y), ceil(tri.c.y));
	}
	if (draw_bb) {
		draw((x_min,y_min)--(x_max,y_min)--(x_max,y_max)--(x_min,y_max)--cycle);
	}

	pair n_dab = line_normal(tri.a, tri.b);
	pair n_dbc = line_normal(tri.b, tri.c);
	pair n_dca = line_normal(tri.c, tri.a);

	for (real y = y_min; y <= y_max; y += 1) {
		for (real x = x_min; x <= x_max; x += 1) {
			pair p = (x + 0.5, y + 0.5);
			real scalar_dab = dot(n_dab, p - tri.a);
			real scalar_dbc = dot(n_dbc, p - tri.b);
			real scalar_dca = dot(n_dca, p - tri.c);

			if ((scalar_dab < 0 || scalar_dbc < 0 || scalar_dca < 0) && conservative) {
				bool hit = false;

				path pixel = (p.x-.5,p.y-.5)--(p.x+.5,p.y-.5)--(p.x+.5,p.y+.5)--(p.x-.5,p.y+.5)--cycle;
				hit = intersect(pixel, tri.a--tri.b).length > 0;
				hit = hit || (intersect(pixel, tri.b--tri.c).length > 0);
				hit = hit || (intersect(pixel, tri.c--tri.a).length > 0);
				if (hit)
					draw_pixel(x, y, B[1], G[2]);

				// pair p0 = (x, y);
				// pair p1 = (x + 1, y);
				// pair p2 = (x, y + 1);
				// pair p3 = (x + 1, y + 1);

				// if (
				// 	check_for_rectangle_intersection(tri.a, tri.b, p0, p1, p2, p3) ||
				// 	check_for_rectangle_intersection(tri.b, tri.c, p0, p1, p2, p3) ||
				// 	check_for_rectangle_intersection(tri.c, tri.a, p0, p1, p2, p3)
				// ) {
				// 	draw_pixel(x, y, G[1], G[2]);
				// }
			} else {
				draw_pixel(x, y, B[1], B[2]);
			}
		} 
	}
}

/*
 * Aufgabe 5 & 6.
 * Demonstrieren Sie ihre Implementierung mit einzelnen Beispielen.
 * Gruppierung in {} der Übersichtlichkeit halber.
 *
 */

{
	tri tri = tri((10.2,8.3), (2.7,2.2), (14.3,1.1));

	draw_pixelgrid(res_x,res_y,dots=lightgray);
	tri.draw(B[1]+linewidth(2));

	raster_signed_distance(tri, draw_bb=true, use_bb=true, conservative=true);

	shipout("raster-tri-1.pdf"); erase();
}


