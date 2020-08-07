$fa = 6;
$fs = 0.2;

inch = 25.4;
nozzle = 0.4;  // nozzle width
border = 0.45;  // filament perimeter width
tolerance = 0.001;
bevel = 0.4;
slope = 1.5;

module symbol_ready(d=inch, b=bevel, slope=slope, inset=false) {
    s = d / 25;
    h = max(1.5*nozzle, b * slope);
    bx = inset ? 0 : b;
    wide = max(border, 1.5*s);
    thin = max(border, 1.0*s);
    spot = max(4*border, wide);  // counter shrinkage
    ring = 8.0*s;  // radius of ring around crosshairs
    xcut = inset ? border/2 + b : 2.0*s;
    xin = inset ? 5.5*s : 4.125*s;  // inner end of crosshairs
    xout = 10.5*s;  // outer end of crosshairs
    difference() {
        in = ring - wide/2;
        out = ring + wide/2;
        rotate_extrude()
            polygon([[in-bx, 0], [out+bx, 0], [out, h], [in, h]]);
        translate([0, 0, -tolerance]) scale([1, 1, (h+2*tolerance)/h])
        for (a=[45, 135])
            rotate([90, 0, a]) linear_extrude(d, center=true)
                polygon([[xcut-b, 0], [xcut, h], [-xcut, h], [-xcut+b, 0]]);
    }
    for (a=[0:90:270]) {
        rotate(a) {
            if (inset) {
                rotate([90, 0, 0]) linear_extrude(thin, center=true)
                    polygon([[xin, 0], [xout, 0], [xout, h], [xin, h]]);
            }
            else hull() {
                translate([xout, 0]) cylinder(d1=thin+2*b, d2=thin, h=h);
                translate([xin, 0]) cylinder(d1=thin+2*b, d2=thin, h=h);
            }
        }
    }
    cylinder(d1=spot+2*bx, d2=spot, h=h);
}

module token(d=inch, b=bevel, h=undef, square=false) {
    z = is_undef(h) ? max(inch/16, d/16) : h;
    difference() {
        // if (square) cube([d, d, z]) else cylinder(d=d, h=z);
        if (square) { translate([0, 0, z/2]) cube([d, d, z], center=true); }
        else { cylinder(d=d, h=z); }
        translate([0, 0, z+tolerance]) mirror([0, 0, 1]) children();
    }
}

module token_ready(d=inch, b=bevel, h=undef, square=false) {
    token(d=d, b=b, h=h, square=square) symbol_ready(d=d, b=b, inset=true);
}

module test_frame(d=inch) {
    difference() {
        cylinder(d=d, h=nozzle/2);
        cylinder(d=d-4*nozzle, h=2*nozzle, center=true);
    }
    for (a=[0, 90]) rotate(a)
        translate([0, 0, nozzle/4]) cube([d, 2*nozzle, nozzle/2], center=true);
}

// echo(25 * 24/600);  // crosshairs
// echo(25 * 36/600);  // dot diameter & circle thickness
// echo(25 * 192/600);  // circle radius (to center of stroke)
// echo(25 * 96/600);  // diagonal cutout
// echo(25 * 99/600);  // center to inside crosshair center
// echo(25 * 252/600);  // center to outside crosshair center

size = 12;
token_ready(size, square=true);
*symbol_ready(size);
*symbol_ready();
*test_frame();
