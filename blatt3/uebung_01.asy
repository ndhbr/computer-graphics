unitsize(1cm);

// Transforms
transform T1 = shift(-1, -1);
transform T2 = rotate(-45);
transform T3 = shift(1, 1);

pair p = (2, 4);

// Draw coordinate system
draw((0,-5)--(0,5), Arrow);
draw((-5,0)--(5,0), Arrow);
for (int i = -5; i < 5; ++i) draw((0,i)--(.1,i));
for (int i = -5; i < 5; ++i) draw((i,0)--(i,.1));

// Draw point
dot((1, 1), purple);
dot(p, red);
dot(T3 * T2 * T1 * p, green);