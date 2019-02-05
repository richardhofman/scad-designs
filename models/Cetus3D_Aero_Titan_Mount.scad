// Customisable E3D Titan Motor Spacer Plate

// BEGIN MODULE DEFS

// Creates the geometry of a bolt hole with countersink.
// Always centered at origin; use translate() to position!
// Note: Generated object is 1mm "too long" at each end to ensure reliable "difference()"
module CounterSinkBoltHole(diameter, length, countersink_depth) {
    union() {
        cylinder(h = length+1,
                 r = diameter/2,
                 center = false,
                 $fn = 360);
        translate([0, 0, length+1]) {
            cylinder(h = countersink_depth+1,
                     r = (diameter/2)+1.5,
                     center = false,
                     $fn = 150);
        }
    }
}

// END MODULE DEFS

// Thickness of spacer plate
thickness = 2; // [1,1.5,2,2.5,3,3.5,4,5,6,7]

// Overall width of motor
nema_width = 42.3;

// Spacing between M3 holes
nema_hole_spacing = 31;

// Clearance hole size for M3
nema_hole_size = 3.5;

// Clearance hole for motor boss
nema_boss_size = 27;

difference(){
    cube(size = [nema_width, nema_width, thickness], center = true);

    for (x = [-0.5:1:0.5])
    for (y = [-0.5:1:0.5])
    translate([x * nema_hole_spacing, 
               y * nema_hole_spacing, 
               0])
        cylinder(h = thickness * 2, 
                 r = nema_hole_size / 2, 
                 center = true,
                 $fn=150);
    cylinder(h = thickness * 2,
             r = nema_boss_size / 2, 
             center = true,
             $fn = 250);
        
}


// MGN mount hole size
mgn_hole_size = 3.5;

// 5mm additional bolt length from face of MGN8H carriage
mgn8h_bolt_face_offset = 5;

// Thickness of aluminium plate that covers LHS of MGN carriage.
cetus_carriage_plate_thickness = 2.1;

// Countersink depth
mgn8h_countersink_depth = 2;

// Mounting hole spacing
mgn_hole_distance = [
    20, // 15mm horizontal spacing
    15  // 20mm vertical spacing
];

// Derived mounting plate thickness
carriage_mount_thickness = mgn8h_bolt_face_offset + mgn8h_countersink_depth;

/* Generates a specialised form of CounterSinkBoltHole, which is:
 * - oriented orthogonally to the YZ-plane (bolt tip in the +x direction).
 * - aligned through the MGN mounting plate (defined below)
 * - positioned in the "XY" plane of the mounting plate, where the
 *   bottom right corner is the origin
 */
module CetusMountBoltHole(x, y) {
    translate([carriage_mount_thickness+1, x, y]){ // Need to compensate for +1mm length (difference() on exact dimensions glitches).
        rotate([0, -90, 0]) {
            CounterSinkBoltHole(diameter = mgn_hole_size,
                                length = mgn8h_bolt_face_offset,
                                countersink_depth = mgn8h_countersink_depth);
        }
    }
}

// Generate the MGN8H mounting plate
translate([nema_width/2, -nema_width/2, -thickness/2]) {
    difference() {
        cube([carriage_mount_thickness, nema_width, nema_width]);

        for (x = [-0.5:1:0.5]) {
            for (y = [-0.5:1:0.5]) {
                bx = nema_width/2 + (x * mgn_hole_distance.x);
                by = nema_width/2 + (y * mgn_hole_distance.y);
                CetusMountBoltHole(x=bx, y=by);
            }
        }
    }
}

