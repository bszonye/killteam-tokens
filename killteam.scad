$fa = 6;
$fs = 0.2;

inch = 25.4;
nozzle = 0.4;
tolerance = 0.001;

module symbol_ready(d=inch) {
    s = d / 32;
    h = sin(60);
    line = max(nozzle, 2*s);
    thin = max(nozzle, 1.5*s);
    dot = line+nozzle;  // add a little extra to keep this from disappearing
    difference() {
        rotate_extrude()
            polygon([[11*s, 0], [11*s-line, 0], [11*s-line/2, h*line]]);
        for (a=[45, 135]) rotate(a)
            translate([0, 0, -tolerance]) scale(1+2*tolerance)
            linear_extrude(h*line, scale=[3/2, 17/16])
                square([4*s, 30*s], center=true);
    }
    for (a=[0:90:270]) {
        rotate(a) hull() {
            translate([13*s, 0]) cylinder(d1=thin, d2=0, h=h*thin);
            translate([5*s, 0]) cylinder(d1=thin, d2=0, h=h*thin);
        }
    }
    cylinder(d1=dot, d2=0, h=h*dot);
}

module token(d=inch, square=false) {
    h = max(inch/16, d/16);
    difference() {
        // if (square) cube([d, d, h]) else cylinder(d=d, h=h);
        if (square) { translate([0, 0, h/2]) cube([d, d, h], center=true); }
        else { cylinder(d=d, h=h); }
        translate([0, 0, h+tolerance]) mirror([0, 0, 1]) children();
    }
}

module token_ready(d=inch, square=false) {
    token(d, square) symbol_ready(d);
}

size = 12;
token_ready(size, square=true);
*symbol_ready(size);
