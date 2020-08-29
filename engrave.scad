tolerance = 0.001;

module flare_engrave(depth=1) {
    mirror([0, 0, 1])
    minkowski() {
        linear_extrude(tolerance) children();
        linear_extrude(depth, scale=0) square(depth, center=true);
    }
}

module cut_engrave(depth=1) {
    mirror([0, 0, 1])
    difference() {
        linear_extrude(depth) children();
        minkowski() {
            linear_extrude(tolerance) difference() {
                offset(r=tolerance) children();
                children();
            }
            cylinder(d1=0, d2=2*depth, h=2*depth);
        }
    }
}

module test_shape() {
    text("hello", size=8, font="Myriad Pro", $fn=24);
}

difference() {
    cube([25, 20, 1.5]);
    translate([1, 1, 1.5+tolerance]) flare_engrave() { test_shape(); }
    translate([1, 11, 1.5+tolerance]) cut_engrave() { test_shape(); }
}
