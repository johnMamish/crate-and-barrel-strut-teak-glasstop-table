mm_per_inch = 2.54;

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
           nub_width=(3 * mm_per_inch), nub_height=(2 * mm_per_inch),
           plate_depth=(0.25 * mm_per_inch), plate_length=(2 * mm_per_inch)) union() {
    color([130 / 255, 82 / 255, 1 / 255])
    linear_extrude(height=plywood_thickness)
    polygon([[-bot_offset, 0], [-(bot_offset+bot_width), 0],
            [-mid_width, mid_y_offset],
            [-(top_x_offset+top_width), top_y_offset], [-top_x_offset, top_y_offset],
            [0, (nub_height / 2) + mid_y_offset], [nub_width, (nub_height / 2) + mid_y_offset],
            [nub_width, mid_y_offset - (nub_height / 2)], [0, mid_y_offset - (nub_height / 2)]], 4);
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

module plate(metal_thickness=(0.25*mm_per_inch),
             nub_width=(2 * mm_per_inch), nub_len=(2 * mm_per_inch),
             n_holes=2, hole_diameter=(0.5*mm_per_inch), nub_angle_deg=110) union() {
    // set up list of polygon points
    one_side_square = [[(nub_width / 2) * tan(30), (nub_width / 2)],
                       [(nub_width / 2) * tan(30) + nub_len, (nub_width / 2)],
                       [(nub_width / 2) * tan(30) + nub_len, -(nub_width / 2)],
                       [(nub_width / 2) * tan(30), -(nub_width / 2)]];
    squares = [ for (angle = [0, 240, 120]) rotate_vectors_2d(angle, one_side_square) ];
    
    // set up list of hole points
    color([0.6, 0.6, 0.6])
    linear_extrude(height=metal_thickness)
    difference() {
        polygon(cat(cat(squares[0], squares[1]), squares[2]));
        /*polygon([[0, nub_width / 2], [nub_len, nub_width / 2], [nub_len, -nub_width / 2], [0, -nub_width / 2],
                 [-nub_len * cos(60), -(nub_len / 2) - nub_len*sin(60)],
                 [-nub_len * cos(60) - nub_width * cos(30), -(nub_len / 2) - nub_len*sin(60) + nub_width * sin(30)],
                 [-cos(30) * nub_width, 0],
                 [-(nub_len * sin(30)) - nub_width * cos(30), nub_len * cos(30) + nub_width / 2 - nub_width * sin(30)],
                 [-(nub_len * sin(30)), nub_len * cos(30) + nub_width / 2]]);*/
        
    }
}
plate();
leg();