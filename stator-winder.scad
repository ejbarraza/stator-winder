// ============================================================================
// 3D-Printed BLDC Stator Needle Winder -- parametric concept model
// Original design by Erick Barraza (MIT license).
// STATUS: conceptual CAD. Not built, not tested. Dimensions are parametric
// starting points, not validated clearances. Print structural parts in PETG;
// critical bores will need reaming/drilling to fit real bearings and shafts.
// ----------------------------------------------------------------------------
// How needle winding works:
//  - The stator sits on an indexing turntable, axis vertical.
//  - The needle rotor spins above it; a hollow needle tube orbits at the
//    slot radius, laying magnet wire around one tooth per orbit.
//  - After N turns the turntable indexes one tooth pitch (manual detent
//    in this concept; a second stepper can drive it).
//  - A NEMA 17 stepper drives the rotor through a GT2 belt.
// ============================================================================

$fn = 48;

// ----------------------------- parameters ---------------------------------
base_l = 280;            // base plate length (X)
base_w = 150;            // base plate width  (Y)
base_t = 10;             // base plate thickness

stator_od   = 62;        // stator outer diameter (tooth tips)
stator_yoke = 44;        // stator yoke outer diameter (tooth roots)
stator_h    = 20;        // stator stack height
teeth       = 12;        // number of stator teeth

orbit_r = stator_od/2 - 4;   // needle orbit radius (inside the slots)

rotor_d = 96;            // needle rotor disk diameter
rotor_t = 10;            // needle rotor disk thickness
rotor_z = 118;           // height of rotor disk center

needle_od = 6;           // needle tube outer diameter
needle_id = 3.2;         // needle tube inner diameter (wire passes through)
needle_len = 96;         // needle tube length

motor_x = -40;           // stepper motor shaft position (X)
pulley_big_d = 40;       // rotor pulley diameter
pulley_small_d = 14;     // motor pulley diameter

bridge_z = 150;          // top bridge height (center)
bridge_t = 12;           // top bridge thickness
post_cx = 71;            // upright post center X offset (pair at +/-)

green = [0.18, 0.65, 0.25];
steel = [0.75, 0.77, 0.80];
dark  = [0.16, 0.16, 0.18];
copper= [0.85, 0.45, 0.15];
brass = [0.80, 0.62, 0.20];

// ------------------------------- helpers ----------------------------------
module rounded_box(l, w, h, r=3) {
    hull()
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2-r), sy*(w/2-r), 0])
                cylinder(r=r, h=h, center=true);
}

// ------------------------------ base plate --------------------------------
module base_plate() {
    color(green)
    difference() {
        translate([0, 0, 0])
            rounded_box(base_l, base_w, base_t, 6);
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(base_l/2-14), sy*(base_w/2-14), 0])
                cylinder(d=6, h=base_t+2, center=true);
    }
    color(dark)
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*(base_l/2-20), sy*(base_w/2-20), -base_t/2-3])
            cylinder(d=18, h=6, center=true);
}

// --------------------------- stator turntable ------------------------------
module stator_model() {
    color(steel)
    difference() {
        cylinder(d=stator_yoke, h=stator_h, center=true);
        cylinder(d=stator_yoke-10, h=stator_h+2, center=true);
    }
    tooth_w = 3.14159*stator_yoke/teeth*0.55;
    tooth_l = (stator_od - stator_yoke)/2;
    for (i=[0:teeth-1])
        rotate([0,0,i*360/teeth])
        translate([(stator_yoke+stator_od)/4, 0, 0]) {
            color(steel)
                cube([tooth_l, tooth_w, stator_h], center=true);
            // demo winding on 3 adjacent teeth
            if (i < 3)
                color(copper)
                    cube([tooth_l*0.92, tooth_w+2.6, stator_h*0.94], center=true);
        }
}

module turntable() {
    color(green)
    difference() {
        cylinder(d=stator_od+26, h=8, center=true);
        for (i=[0:teeth-1])
            rotate([0,0,i*360/teeth])
                translate([(stator_od+26)/2 - 4, 0, 0])
                    cylinder(d=5, h=10, center=true);   // detent notches
    }
    color(steel)
        cylinder(d=12, h=34, center=true);              // center post
    translate([0, 0, 8+stator_h/2+2])
        stator_model();
    // detent plunger (concept)
    color(dark)
        translate([(stator_od+26)/2 + 10, 0, 0])
            rotate([0,90,0])
                cylinder(d=8, h=24, center=true);
}

// --------------------------------- frame ----------------------------------
module upright(cx) {
    // post from base top up to bridge underside
    z0 = base_t/2; z1 = bridge_z - bridge_t/2;
    color(green)
    difference() {
        translate([cx, 0, (z0+z1)/2])
            cube([18, 44, z1-z0], center=true);
        translate([cx, 0, (z0+z1)/2])
            cube([20, 24, (z1-z0)*0.45], center=true);  // lightening window
    }
}

module top_bridge() {
    color(green)
    difference() {
        translate([-10, 0, bridge_z])
            cube([230, 50, bridge_t], center=true);
        translate([0, 0, bridge_z])                     // rotor bearing bore
            cylinder(d=22, h=bridge_t+4, center=true);
        translate([motor_x, 0, bridge_z])               // motor shaft clearance
            cylinder(d=24, h=bridge_t+4, center=true);
    }
}

// ------------------------------ needle rotor -------------------------------
module needle_rotor() {
    color(green)
    difference() {
        cylinder(d=rotor_d, h=rotor_t, center=true);
        cylinder(d=8.2, h=rotor_t+2, center=true);
    }
    // needle arm
    color(green)
    translate([orbit_r, 0, -rotor_t/2])
        cube([16, 14, 14], center=true);
    // hollow needle tube hanging down toward the stator slots
    color(steel)
    translate([orbit_r, 0, -rotor_t/2 - needle_len/2 + 4])
    difference() {
        cylinder(d=needle_od, h=needle_len, center=true);
        cylinder(d=needle_id, h=needle_len+2, center=true);
    }
    // needle tip
    color(steel)
    translate([orbit_r, 0, -rotor_t/2 - needle_len + 4])
        cylinder(d1=needle_id+0.6, d2=needle_od, h=4, center=true);
    // counterweight
    color(dark)
    translate([-orbit_r, 0, 0])
        cylinder(d=18, h=rotor_t, center=true);
    // drive pulley on top
    color(dark)
    translate([0, 0, rotor_t/2 + 7])
        cylinder(d=pulley_big_d, h=12, center=true);
    color(dark)
    translate([0, 0, rotor_t/2 + 14])
        cylinder(d=pulley_big_d+4, h=2, center=true);
    // main shaft up into the bridge bearing
    color(steel)
    translate([0, 0, rotor_t/2 + 30])
        cylinder(d=8, h=60, center=true);
}

// ------------------------------ stepper motor ------------------------------
module nema17() {
    color(dark)
    translate([motor_x, 0, bridge_z + bridge_t/2 + 24])
        cube([42, 42, 48], center=true);
    color(steel)
    translate([motor_x, 0, bridge_z - 2])
        cylinder(d=5, h=36, center=true);
    color(brass)   // motor pulley at belt height
    translate([motor_x, 0, rotor_z + rotor_t/2 + 7])
        cylinder(d=pulley_small_d, h=12, center=true);
    color(green)   // mount ears on the bridge
    translate([motor_x, 0, bridge_z + bridge_t/2 + 2])
        cube([56, 56, 8], center=true);
}

// ---------------------------------- belt -----------------------------------
module belt() {
    color([0.1, 0.1, 0.12])
    hull() {
        translate([0, 0, rotor_z + rotor_t/2 + 7])
            cylinder(d=pulley_big_d+3, h=8, center=true);
        translate([motor_x, 0, rotor_z + rotor_t/2 + 7])
            cylinder(d=pulley_small_d+3, h=8, center=true);
    }
}

// ------------------------------- spool holder ------------------------------
module spool_holder() {
    sx = base_l/2 - 26; sy = base_w/2 - 26;
    color(green)
    translate([sx, sy, base_t/2])
        cylinder(d=10, h=70);
    color(dark)
    translate([sx, sy, base_t/2+14]) {
        cylinder(d=44, h=3, center=true);
        translate([0,0,26]) cylinder(d=44, h=3, center=true);
    }
    color(copper)
    translate([sx, sy, base_t/2+27])
        cylinder(d=38, h=24, center=true);
}

// -------------------------------- control box ------------------------------
module control_box() {
    color(dark)
    translate([-base_l/2+34, -base_w/2+26, base_t/2])
        cube([56, 40, 26], center=false);
    color([0.2, 0.5, 0.7])
    translate([-base_l/2+40, -base_w/2+26+8, base_t/2+26])
        cube([30, 24, 1.5], center=false);   // little screen
}

// -------------------------------- assembly ---------------------------------
module assembly() {
    base_plate();
    translate([0, 0, base_t/2 + 4])
        turntable();
    upright(post_cx);
    upright(-post_cx);
    top_bridge();
    rotate([0,0,15])                        // needle parked in a slot
    translate([0, 0, rotor_z])
        needle_rotor();
    nema17();
    belt();
    spool_holder();
    control_box();
}

assembly();
