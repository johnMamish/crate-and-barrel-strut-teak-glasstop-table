mm_per_inch = 25.4;

/**
 * Creates a
 * plywood_thickness refers to the
 *
 *
 */
module leg(plywood_thickness=(2 * mm_per_inch),
           top_width=(3.5 * mm_per_inch), top_x_offset=(10 * mm_per_inch), top_y_offset=(29.25 * mm_per_inch),
           mid_width=(4 * mm_per_inch), mid_y_offset=(20 * mm_per_inch),
           bot_width=(3 * mm_per_inch), bot_offset=(7 * mm_per_inch),
           nub_length=(3 * mm_per_inch), nub_height=(2 * mm_per_inch),
           plate_thickness=(0.25 * mm_per_inch), plate_length=(2 * mm_per_inch)) union() {
    color([130 / 255, 82 / 255, 1 / 255])
    linear_extrude(height=plywood_thickness)
    difference() {
        polygon(// Bottom
                [[-bot_offset, 0], [-(bot_offset+bot_width), 0],
                [-mid_width, mid_y_offset],

                // Top
                [-(top_x_offset+top_width), top_y_offset], [-top_x_offset, top_y_offset],

                // Nub + middle
                [0, (nub_height / 2) + mid_y_offset],
                [nub_length - plate_length, (nub_height / 2) + mid_y_offset],

                [nub_length - plate_length, (nub_height / 2) + mid_y_offset - plate_thickness],
                [nub_length, (nub_height / 2) + mid_y_offset - plate_thickness],
                [nub_length, -(nub_height / 2) + mid_y_offset + plate_thickness],
                [nub_length - plate_length, -(nub_height / 2) + mid_y_offset + plate_thickness],

                [nub_length - plate_length, mid_y_offset - (nub_height / 2)], [0, mid_y_offset - (nub_height / 2)]], 4);
        
        dowel_radius = (0.5 / 2);
        union() {
            ndowel_1 = 2;
            ndowel_2 = 1;
            for (i = [1:ndowel_1]) {
                angle = atan2(mid_y_offset, bot_offset) + 1;
                echo(angle);
                dist = ((i - 0.5) / (ndowel_1)) * mid_y_offset;
                translate([-(bot_offset + bot_width / 2), 0]) translate([dist*cos(angle), dist*sin(angle)]) circle(dowel_radius * mm_per_inch);
            }
            for (i = [1:ndowel_2]) {
                angle = atan2((mid_y_offset - top_y_offset), top_x_offset + (top_width / 2)) +3;
                echo(angle);
                dist = ((i) / (ndowel_2)) * (mid_y_offset - top_y_offset);
                translate([0, mid_y_offset]) translate([dist*cos(angle), dist*sin(angle)]) circle(dowel_radius * mm_per_inch);
            }
            translate([0, mid_y_offset]) circle(dowel_radius * mm_per_inch);
        }
    }
}

module strut(plywood_thickness = (2*mm_per_inch), strut_len=(40*mm_per_inch),
             strut_height=(2*mm_per_inch), plate_thickness=(0.25*mm_per_inch),
             plate_len=(2*mm_per_inch)) union() {
    epsilon = 0.5;
    dowel_radius = (0.5 / 2)*mm_per_inch;
    color([130 / 255, 82 / 255, 1 / 255])
    difference() {
        cube([strut_len, strut_height, plywood_thickness]);

        union() {
            for (xoffset = [-epsilon, strut_len - plate_len + epsilon]) {
                for (yoffset = [-epsilon, strut_height - plate_thickness + epsilon]) {
                    translate([xoffset, yoffset, -epsilon]) cube([plate_len + 2*epsilon, plate_thickness + 2*epsilon, plywood_thickness + 2*epsilon]);
                }
            }
            
            ndowel = 3;
            for (i = [1:ndowel])
                translate([((i - 0.5) / ndowel) * strut_len, strut_height / 2, -epsilon])cylinder(plywood_thickness + (2 * epsilon), r=(dowel_radius));
        }
    }
}

module rotate_about_pt(a, v, pt) {
    translate(pt)
        rotate(a,v)
            translate(-pt)
                children();
}

function rotate_vectors_2d(angle, vectors) = [ for (v = vectors)
    [v[0] * cos(angle) - v[1] * sin(angle),
     v[0] * sin(angle) + v[1] * cos(angle)]];

function cat(L1, L2) = [for (i=[0:len(L1)+len(L2)-1])
                        i < len(L1)? L1[i] : L2[i-len(L1)]] ;

module plate(plate_thickness=(0.25*mm_per_inch),
             nub_width=(2 * mm_per_inch), nub_len=(2 * mm_per_inch),
             n_holes=2, hole_diameter=(0.324*mm_per_inch)) union() {
    // set up list of polygon points
    one_side_square = [[(nub_width / 2) * tan(30), (nub_width / 2)],
                       [(nub_width / 2) * tan(30) + nub_len, (nub_width / 2)],
                       [(nub_width / 2) * tan(30) + nub_len, -(nub_width / 2)],
                       [(nub_width / 2) * tan(30), -(nub_width / 2)]];
    squares = [ for (angle = [0, 240, 120]) rotate_vectors_2d(angle, one_side_square) ];

    // set up list of hole points
    spac = nub_len / (n_holes + 1);
    one_side_holepoints = [ for(x = [1:n_holes]) [(nub_width / 2) * tan(30) + spac * x, 0]];

    // assemble polygon and holes together
    color([0.6, 0.6, 0.6])
    linear_extrude(height=plate_thickness)
    difference() {
        polygon(cat(cat(squares[0], squares[1]), squares[2]));
        for (angle = [0, 240, 120])
            for (xoffset = one_side_holepoints)
                rotate(angle) translate(xoffset) circle(d=hole_diameter, $fn=100);
    }
}

module table(plywood_thickness=(2 * mm_per_inch),
           top_width=(3.5 * mm_per_inch), top_x_offset=(10 * mm_per_inch), top_y_offset=(29.25 * mm_per_inch),
           mid_width=(4 * mm_per_inch), mid_y_offset=(20 * mm_per_inch),
           bot_width=(3 * mm_per_inch), bot_offset=(7 * mm_per_inch),
           nub_length=(3 * mm_per_inch), nub_height=(2 * mm_per_inch),
           plate_thickness=(0.25 * mm_per_inch), plate_length=(2 * mm_per_inch)) {
    // Leg + bracket assy
    for (at = [[0, [0, 0, 0]], [180, [40*mm_per_inch + (plywood_thickness * tan(30)), 0, 0]]])
        translate(at[1]) rotate(at[0], [0, 1, 0])
        union() {
        for (angle = [-60, 60])
            rotate(a=angle, v=[0,1,0])
            translate([-nub_length - (plywood_thickness / 2) * tan(30), 0, -(plywood_thickness / 2)])
            leg(plywood_thickness,
                top_width, top_x_offset, top_y_offset,
                mid_width, mid_y_offset,
                bot_width, bot_offset,
                nub_length, nub_height,
                plate_thickness, plate_length);

        for (y_translate = [mid_y_offset - (nub_height / 2) + plate_thickness,
            mid_y_offset + (nub_height / 2)])
            translate([0, y_translate, 0])
            rotate(a=90, v=[1,0,0])
            plate(plate_thickness=plate_thickness, nub_width=plywood_thickness);
    }

    // Strut
    translate([(plywood_thickness / 2) * tan(30), mid_y_offset - (plywood_thickness / 2), -plywood_thickness / 2])strut();

    // Glass table top
    tabletop_width = 40 * mm_per_inch;
    tabletop_length = 70 * mm_per_inch;
    tabletop_thick  = 0.75 * mm_per_inch;
    %translate([-15 * mm_per_inch, top_y_offset, -tabletop_width / 2])
    cube([tabletop_length, tabletop_thick, tabletop_width]);
}

//table();
//leg();
//strut();