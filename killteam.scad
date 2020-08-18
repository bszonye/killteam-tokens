inch = 25.4;
nozzle = 0.4;  // nozzle width
layer = 0.2;  // layer height
border = 0.45;  // filament perimeter width
overlap = layer * (1 - PI/4);  // overlap between perimeters
// echo(4*border-3*overlap);  // width of 4 perimeters
slope = 1.5;
tolerance = 0.001;

$fa = 6;
$fs = layer;

module test_frame(d=inch) {
    difference() {
        cylinder(d=d, h=nozzle/2);
        cylinder(d=d-4*nozzle, h=2*nozzle, center=true);
    }
    for (a=[0, 90]) rotate(a)
        translate([0, 0, nozzle/4]) cube([d, 2*nozzle, nozzle/2], center=true);
}

module extrude_symbol() {
    linear_extrude(2*nozzle) children();
    linear_extrude(nozzle) offset(delta=nozzle/2) children();
}

module token_die(d=16) {
    difference() {
        intersection() {
            cube(d, center=true);
            sphere(r=sqrt(2)*d/2);
        }
        a = [
            [180, 0, 0],
            [90, 90, 0],
            [-90, 0, -90],
            [90, 0, -90],
            [-90, 90, 0],
            [0, 0, 0],
        ];
        for (i=[0:5]) rotate(a[i])
            translate([0, 0, d/2+tolerance]) mirror([0, 0, 1])
                children(i < $children ? i : $children-1);
    }
}

// echo(25 * 24/600);  // crosshairs
// echo(25 * 36/600);  // dot diameter & circle thickness
// echo(25 * 192/600);  // circle radius (to center of stroke)
// echo(25 * 96/600);  // diagonal cutout
// echo(25 * 99/600);  // center to inside crosshair center
// echo(25 * 252/600);  // center to outside crosshair center

module symbol_arrow(d) {
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("test arrow", d/2);
}

module symbol_ready(d) {
    // TODO
    *translate([d/2, d/4, 0]) text("ready", d/2);
    s = d / 25;
    wide = max(border, 1.5*s);
    // echo(wide);
    thin = max(border, 1.0*s);
    // echo(thin);
    // spot = max(4*border, wide);  // counter shrinkage
    spot = wide;
    // echo(spot);
    ring = 8.0*s;  // radius of ring around crosshairs
    xcut = max(3*border-2*overlap, 2.0*s);
    echo(xcut-nozzle);
    xin = 4.125*s;  // inner end of crosshairs
    xout = 10.5*s;  // outer end of crosshairs
    difference() {
        circle(ring + wide/2);
        circle(ring - wide/2);
        for (a=[45, 135]) rotate(a) square([xcut, d], center=true);
    }
    for (a=[0:90:270]) {
        rotate(a) {
            hull() {
                translate([xout, 0]) circle(d=thin);
                translate([xin, 0]) circle(d=thin);
            }
        }
    }
    circle(d=spot);
}

module symbol_move(d) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("move", d/2);
}

module symbol_advance(d) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("advance", d/2);
}

module symbol_fall_back(d) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("fall back", d/2);
}

module symbol_charge(d) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("charge", d/2);
}

module symbol_shoot(d) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("shoot", d/2);
}

size = 12;

*token_die(size) {
    extrude_symbol() square(1, center=true);
    extrude_symbol() square(2, center=true);
    extrude_symbol() square(3, center=true);
    extrude_symbol() square(4, center=true);
    extrude_symbol() square(5, center=true);
    extrude_symbol() square(6, center=true);
}

*token_die(size) {
    #extrude_symbol(engrave=true) symbol_ready(size-2);
    #extrude_symbol() symbol_ready(size-2);
    #extrude_symbol() symbol_ready(size-2);
    #extrude_symbol() symbol_ready(size-2);
    #extrude_symbol() symbol_ready(size-2);
    #extrude_symbol() symbol_ready(size-2);
}

token_die(size) extrude_symbol() symbol_ready(size-2);
*token_die(size) linear_extrude(2*nozzle) symbol_ready(size-2);

*token_die(size) {
    extrude_symbol() symbol_ready(size-2);
    extrude_symbol() symbol_move(size-2);
    extrude_symbol() symbol_advance(size-2);
    extrude_symbol() symbol_fall_back(size-2);
    extrude_symbol() symbol_charge(size-2);
    extrude_symbol() symbol_shoot(size-2);
}
