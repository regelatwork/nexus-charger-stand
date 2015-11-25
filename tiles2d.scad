// 2d tiling of objects

module 1d_tile(times = 5, length = -1, direction = [1,0,0], step = 0) {
  l = step <= 0? norm(direction) : step;
  d = direction / norm(direction);
  times_ = length <= 0 ? times : length / l + 1;
  for (i = [0 : times_ - 1]) {
    translate(i * l * d) children();
  }
}

module 2d_tile(times = [5,5], dim = [-1, -1],  offsets = [0], directions = [[1,0,0],[0,1,0]], steps = [0,0]) {
  l = steps[0] <= 0? norm(directions[0]) : steps[0];
  d = directions[0] / norm(directions[0]);
  d2 = directions[1] / norm(directions[1]);
  times_ = dim[0] <= 0 ? times[0] : dim[0] / l + 1;
  for (i = [0 : times_ - 1]) {
    l2 = offsets[i % len(offsets)];
    if (dim[1] - l2 > 0) {
      translate(i * l * d + l2 * d2)
      1d_tile(times = times[1], length = dim[1] - l2, direction = directions[1], step = steps[1]) children();
    }
  }
}

/*
1d_tile(length = 60, direction = 10*[1 + cos(60),sin(60),0])
translate([0,10*sin(60),0])
1d_tile(length = 100, direction = [0,1,0], step = 20 * sin(60))
union() {
  for (a = [-120 : 120 : 120]) {
    rotate([0,0,a])
    translate([-2, -2, 0])
    cube([12,4,4]);
  }
}
*/
s = 3;
dim = [20.1,5.4];
union() {
  intersection() {
  2d_tile(dim = dim, steps = [s/2 * sin(45), s * cos(45)], directions = [[0,0,1],[0,1,0]], offsets = [0,s/2  * cos(45)])
  rotate([45,0,0])
  cube([s*2/7,s*2/7,s*2/7]);
  cube([s*2/7, dim[1], dim[0]]);
  }
}
