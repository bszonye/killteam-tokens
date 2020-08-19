layer_height = 0.2;
extrusion_width = 0.45;
extrusion_overlap = layer_height * (1 - PI/4);
extrusion_spacing = extrusion_width - extrusion_overlap;

// convert between path counts and spacing, qspace to quantize
function xspace(n=1) = n*extrusion_spacing;
function nspace(x=xspace()) = x/extrusion_spacing;
function qspace(x=xspace()) = xspace(round(nspace(x)));
function cspace(x=xspace()) = xspace(ceil(nspace(x)));
function fspace(x=xspace()) = xspace(floor(nspace(x)));

// convert between path counts and width, qspace to quantize
function xwall(n=1) = xspace(n) + (0<n ? extrusion_overlap : 0);
function nwall(x=xwall()) =  // first path gets full extrusion width
    x < 0 ? nspace(x) :
    x < extrusion_overlap ? 0 :
    nspace(x - extrusion_overlap);
function qwall(x=xwall()) = xwall(round(nwall(x)));
function cwall(x=xwall()) = xwall(ceil(nwall(x)));
function fwall(x=xwall()) = xwall(floor(nwall(x)));

// quantize thin walls only (less than n paths wide, default for 2 perimeters)
function qthin(x=xwall(), n=4.5) = x < xwall(n) ? qwall(x) : x;
function cthin(x=xwall(), n=4.5) = x < xwall(n) ? cwall(x) : x;
function fthin(x=xwall(), n=4.5) = x < xwall(n) ? fwall(x) : x;

tolerance = 0.001;
border = 1;

$fa = 6;
$fs = min(layer_height, xspace(1/2));

module test_frame(d=25) {
    difference() {
        cylinder(d=qthin(d), h=layer_height);
        cylinder(d=qthin(d)-2*xwall(2), h=3*layer_height, center=true);
    }
    for (a=[0, 90]) rotate(a)
        translate([-d/2, -xwall(2)/2, 0]) cube([d, xwall(2), layer_height]);
    children();
}

module extrude_symbol(rounded=false, chamfer=false) {
    linear_extrude(xspace(2))
        children();
    if (rounded)
        linear_extrude(xspace(1)) offset(r=xspace(1/2)) children();
    else linear_extrude(xspace(1)) offset(delta=xspace(1/2), chamfer=chamfer)
        children();
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
                children(i % $children);
    }
}

// echo(25 * 24/600);  // crosshairs
// echo(25 * 36/600);  // dot diameter & circle thickness
// echo(25 * 192/600);  // circle radius (to center of stroke)
// echo(25 * 96/600);  // diagonal cutout
// echo(25 * 99/600);  // center to inside crosshair center
// echo(25 * 252/600);  // center to outside crosshair center

module symbol_arrow(d=25) {
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("test arrow", d/2);
}

module symbol_ready(d=25) {
    *translate([d/2, d/4, 0]) text("ready", d/2);
    r = d/2 + border - xspace(1/2);  // radius of token or face
    s = d / 25;  // scale unit
    thin0 = 1.0*s;
    // thin = qthin(thin0);  // quantize
    thin = thin0;
    wide0 = 1.5*s;
    // wide = max(qthin(wide0), thin+xspace(1));  // at least 1 stroke wider
    wide = wide0;
    spot0 = 1.5*s;
    spot = max(qthin(spot0), xwall(3));  // quantize, at least 3 strokes wide
    ring = 8.0*s;  // radius of ring around crosshairs
    oring0 = ring + wide/2;
    oring = r - qthin(r-oring0);
    iring = oring - wide;
    xin0 = 4.125*s;  // inner end of crosshairs
    xin = spot/2 + thin/2 + max(cthin(xin0 - spot/2 - thin/2), xwall(3));
    xout0 = 10.5*s;  // outer end of crosshairs
    // xout = r - thin/2 - qthin(r - thin0/2 - xout0);
    xout = xout0;
    xcut0 = 4.0*s;
    xcut = qthin(xcut0);
    difference() {
        circle(oring);
        circle(iring);
        for (a=[45, 135]) rotate(a) square([xcut, d], center=true);
    }
    for (a=[0:90:270]) {
        rotate(a) {
            hull() {
                translate([xin, -thin/2]) square([xout-xin, thin]);
                if (3*$fs < thin) {
                    translate([xin, 0]) circle(d=thin);
                    translate([xout, 0]) circle(d=thin);
                } else {
                    translate([xin, 0]) square(thin, center=true);
                    translate([xout, 0]) square(thin, center=true);
                }
            }
        }
    }
    circle(d=spot);
}

module symbol_move(d=25) {
    *translate([d/2, d/4, 0]) text("move", d/2);
    s = d / 25;  // scale unit
    y2 = 9.5*s;
    x1 = 9*s;
    y1 = -2*s;
    x0 = 5.125*s;
    y0 = -10*s;
    xr = 5.5*s;
    difference() {
        polygon([[x0, y0], [x0, y1], [x1, y1], [0, y2],
                [-x1, y1], [-x0, y1], [-x0, y0]]);
        translate([0, y0]) circle(r=xr);
    }
}

module symbol_advance(d=25) {
    *translate([d/2, d/4, 0]) text("advance", d/2);
    s = d / 25;  // scale unit
    y2 = 5.5*s;
    x1 = 8*s;
    y1 = -4.5*s;
    x0 = 4.5*s;
    y0 = -10.25*s;
    xr = (116/24)*s;
    difference() {
        polygon([[x0, y0], [x0, y1], [x1, y1], [0, y2],
                [-x1, y1], [-x0, y1], [-x0, y0]]);
        translate([0, y0]) circle(r=xr);
    }
    delta = 5*s;
    difference() {
        polygon([[x1, y1+delta], [0, y2+delta], [-x1, y1+delta]]);
        offset(delta=1.5*s) polygon([[x1, y1], [0, y2], [-x1, y1]]);
    }
}

module symbol_fall_back(d=25) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("fall back", d/2);
}

module symbol_charge(d=25) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("charge", d/2);
}

module symbol_shoot(d=25) {
    // TODO
    polygon(d/3*[[0, 1], [cos(240), sin(240)], [cos(300), sin(300)]]);
    *translate([d/2, d/4, 0]) text("shoot", d/2);
}

size = 12;
// size = 16;

*test_frame();

*token_die(size) {
    extrude_symbol() square(1, center=true);
    extrude_symbol() square(2, center=true);
    extrude_symbol() square(3, center=true);
    extrude_symbol() square(4, center=true);
    extrude_symbol() square(5, center=true);
    extrude_symbol() square(6, center=true);
}

*token_die(size) {
    extrude_symbol() symbol_ready(size-2*border);
    extrude_symbol() symbol_move(size-2*border);
    extrude_symbol() symbol_advance(size-2*border);
    extrude_symbol() symbol_fall_back(size-2*border);
    extrude_symbol() symbol_charge(size-2*border);
    extrude_symbol() symbol_shoot(size-2*border);
}

*token_die(size) linear_extrude(xspace(2)) symbol_ready(size-2*border);
*token_die(size) extrude_symbol() symbol_ready(size-2*border);

token_die(size) {
    *extrude_symbol() symbol_ready(size-2*border);
    extrude_symbol() symbol_move(size-2*border);
    extrude_symbol() symbol_advance(size-2*border);
}

*test_frame() extrude_symbol() symbol_ready(25);
