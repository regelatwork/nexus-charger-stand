use <tiles2d.scad>

// Stand for nexus 5 and nexus 7 2013 tablet
// Has a hole for the chrger
// Copyright 2015 Rodrigo Chandia rodrigo.chandia@gmail.com
// License: Creative Commons Attribution-ShareAlike 4.0 International (CC-BY-SA 4.0)
// For more information see: http://creativecommons.org/licenses/by-sa/4.0/

function what_fillet(l,w) = (norm([w,w]) - l) / (norm([1,1]) - 1);
e=0.15;

nexus_charger = false;
holes = false;
hole_size = 4.5;
ears = true;

// round charger
// Chinese
//rcharger_r = 70/2;
//rcharger_h = 10.6;
//rcharger_top_h = -1;
// From stuff/
rcharger_r = 60.05/2;
rcharger_h = 11.4;
rcharger_top_h = 2.9;

// nexus charger
charger_top_w = nexus_charger ? 58 : rcharger_r*2;
charger_top_diagonal = 80.64;
charger_top_fillet_r = what_fillet(charger_top_diagonal, charger_top_w) / 2;
charger_top_h = nexus_charger? 2.9 : rcharger_top_h;
charger_sticker_h = 0;
charger_h = 12.2;
charger_bottom_w = 49.23;
charger_bottom_diagonal = 65.00;
charger_bottom_fillet_r = what_fillet(charger_bottom_diagonal, charger_bottom_w) / 2;
charger_plug_w = 12.0 + e;
charger_plug_h = nexus_charger
  ? charger_h - charger_top_h 
  : rcharger_h - charger_top_h;
bottom_offset = (charger_top_w - charger_bottom_w) / 2;
charger_outset = 1.5;
$fs=1;

n6_lip = 2;

// Change this to add extra space for phones with a shield that makes it thicker.
n5_shield = 3;
//n5_shield = 0;

n5_w = 70;
n5_l = 137.5;
n5_thick = 10 + n6_lip;

n7_w = 200;
n7_l = 114;
n7_thick = 9.5;

stand_w = 120;
stand_r = 12;
stand_r_base = 7;
stand_angle = 30;
stand_side_angle = 33;
device_offset = max(n5_thick, n7_thick);

module nexus_charger() {
  hull() {
    for (x = [0,1],y = [0,1]) {
      translate([
        2*x*(bottom_offset + charger_bottom_fillet_r) + x*(charger_bottom_w-2*charger_bottom_fillet_r),
        2*y*(bottom_offset + charger_bottom_fillet_r) + y*(charger_bottom_w-2*charger_bottom_fillet_r),
        0])
      mirror([x,y,0]) {
        translate([charger_top_fillet_r, charger_top_fillet_r, charger_h - charger_top_h])
        cylinder(r=charger_top_fillet_r, h=charger_top_h);
        translate([bottom_offset + charger_bottom_fillet_r, bottom_offset + charger_bottom_fillet_r, charger_sticker_h])
        cylinder(r=charger_bottom_fillet_r, h=charger_h-charger_sticker_h);
      }
    }
  }
  hull() {
    for (x = [0,1],y = [0,1]) {
      translate([
        2*x*(bottom_offset + charger_bottom_fillet_r) + x*(charger_bottom_w-2*charger_bottom_fillet_r),
        2*y*(bottom_offset + charger_bottom_fillet_r) + y*(charger_bottom_w-2*charger_bottom_fillet_r),
        0])
      mirror([x,y,0]) {
        translate([bottom_offset + charger_bottom_fillet_r, bottom_offset + charger_bottom_fillet_r,0])
        cylinder(r=charger_bottom_fillet_r, h=charger_sticker_h);
      }
    }
  }
}

module round_charger() {
  translate([rcharger_r, rcharger_r, charger_h - rcharger_h])
  cylinder(r=rcharger_r, h = rcharger_h);
}

module charger() {
  if (nexus_charger) {
    nexus_charger();
  } else {
    round_charger();
  }
}

module box_on_charger(x,y,z) {
  offset = charger_top_w / 2;
  translate([-x/2 + offset,-y/2 + offset,charger_h])
  cube([x,y,z]);
}

module devices(dev_thick) {
  n5_tip = (n5_l - n7_l) / 2;
  wedge_w = norm([n5_tip, n5_tip]);
  offset_x = charger_top_w / 2 - n5_w / 2;
  offset_y = charger_top_w / 2 - n5_l / 2;

  difference() {
    union() {
      box_on_charger(n5_w, n5_l, dev_thick);
      box_on_charger(n7_w, n7_l, dev_thick);
      translate([offset_x,offset_y,charger_h])
      for (x = [0,n5_w], y = [0,n5_l - 2*n5_tip]) {
        translate([x,y,0])
        rotate([0,0,45])
        cube([wedge_w, wedge_w, dev_thick]);
      }
    }
#    translate([-wedge_w, charger_top_w - offset_y - n6_lip, stand_r + dev_thick + e])
    rotate([0, 90, 0])
    cube([n6_lip, n6_lip, n5_w+wedge_w]);
    // TODO: add tablet lip
  }
}

module charger_hole() {
  offset_z = nexus_charger ? 0 : charger_h - rcharger_h;
  translate([charger_top_w/2 + charger_plug_w/2,charger_top_w/2,offset_z - e])
  rotate([0,0,90])
  cube([stand_w,charger_plug_w,charger_plug_h]);
}

module cable_hole() {
    translate([charger_top_w/2 - charger_plug_w/2, charger_top_w+5*stand_r-charger_plug_h, 0])
    rotate([-stand_angle, 0, 0])
    rotate([0,-45,0])
    translate([0, -3, -stand_w])
    cube([charger_plug_w/sqrt(2)*1.5, charger_plug_h, stand_w]);
}

module negatives() {
  offset = max(n5_thick + n5_shield, n7_thick);
  translate([0, 0, -offset - charger_h]) {
    devices(offset);
    charger_hole();
    hull() {
      cable_hole();
      translate([0,10,0])
      cable_hole();
    }

    minkowski() {
      charger();
      cylinder(r=charger_outset, h=charger_outset);
    }
  }
}

module pillar(x,y,is_slim) {
  offset = [
    (is_slim? stand_r/2 * cos(stand_angle) : 0),
    (is_slim? stand_r/2 * sin(stand_angle) : 0),
    0];
  translate([x , y , 0]  + offset ) {
    cylinder(r=!is_slim ? stand_r : stand_r/2, h=stand_w);
  }
}

module ear(x,y) {
  translate([x,y,0])
  cylinder(r=10,h=0.22);
}

module wedge(a, l) {
  intersection() {
    rotate([a,0,0])
    cube(2*[l,l,l]);
    translate([0,0,stand_w])
    rotate([-90-a,0,0])
    cube(2*[l,l,l]);
  }
}

module wall_of_tubes(r=3) {
if (holes) {
  2d_tile(times=[12,15], steps=[10*sin(60),10], directions=[[1,0,0],[0,0,1]],offsets=[0,10*cos(60)])
  rotate([90,0,0])
  translate([0,0,-30+e])
  cylinder(r=r, h=30);
}
}

module stand_body() {
  stand_body_l = 4*stand_r + charger_top_w;
  x_slide = 14;
  y_slide = -75;
  translate([stand_w,0,0])
  rotate([0,0,90])
  rotate([-90,0,0])
  translate([0,stand_r,0])
  intersection() {
    union() {
      difference() {
        hull() {
          pillar(0,0,false);
          pillar(0,stand_r/2,false);
          pillar(stand_body_l, 0,false);
          pillar(stand_body_l - stand_r/2*tan(stand_angle), stand_r/2,false);
        }
        wall_of_tubes(r=hole_size);
      }
      difference() {
        hull() {
          pillar(stand_body_l, 0,true);
          translate([stand_body_l,0,0])
          rotate([0,0,stand_angle])
          pillar(0, -1.25*stand_body_l*sin(-stand_angle), true);
        }
        translate([-x_slide*sin(stand_angle)-y_slide*cos(stand_angle),x_slide*cos(stand_angle)-y_slide*sin(stand_angle),0])
        rotate([0,0,stand_angle-90])
        wall_of_tubes(r=hole_size);
      }
    }
    translate([-stand_r,-stand_r,0])
    wedge(stand_side_angle, stand_body_l);
  }
}

rotate([0,-stand_side_angle,0])
translate([0,0,stand_w+(charger_top_w / 2 - stand_w / 2)])
rotate([0,90,0])
difference() {
  translate([charger_top_w / 2 - stand_w / 2, 0, 0])
  stand_body();
  negatives();
}

if (ears) {
ear(-stand_r,-stand_r);
ear(5,n7_l/2+charger_top_w/2);
//ear(-12,43);
//ear(-12,9);
//ear(-35,-15);
//ear(-44,9);
//ear(-44,44);
//ear(-44,78);
//ear(-65,71);
//ear(-90,62);
//ear(-100,87);
ear(-69,102);
ear(-50,110);
//ear(5,115);
}
