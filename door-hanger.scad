//------------------------------------------------------------
//  SHOWER-DOOR HANGER  –  five-segment parametric bracket
//  gap is preserved when corner_radius > 0
//------------------------------------------------------------
module shower_hanger(
    /* ─── Core dimensions (mm) ──────────────────────────── */
    width            = 15,
    bar_thickness    = 5,
    outside_drop     = 60,
    door_thickness   = 10,   // glass / frame thickness
    clearance        = 2,    // extra wiggle room
    inside_drop      = 40,
    hook_depth       = 25,
    lip_height       = 20,
    /* ─── Optional nicety ───────────────────────────────── */
    corner_radius    = 0     // 0 = square; >0 = fillet radius
){
    //— keep the requested opening after filleting ————————
    gap_nominal = door_thickness + clearance;
    gap         = gap_nominal + (corner_radius > 0 ? 2*corner_radius : 0);

    //— derived Y-positions ——————————————————————————
    top_length  = gap + 2*bar_thickness;  // bar-to-bar span
    y_outside   = 0;
    y_inside    = bar_thickness + gap;    // where inside drop starts
    y_hook_base = y_inside;
    y_hook_end  = y_hook_base + hook_depth + bar_thickness;

    //— tiny helper cube —————————————————————————
    module bar(size_vec, pos_vec=[0,0,0])
        translate(pos_vec) cube(size_vec, center=false);

    //— raw geometry (five overlapping bars) ————————
    module raw_bracket() {
        union() {
            // 1 ↓ outside vertical
            bar([width, bar_thickness, outside_drop],
                [-width/2, y_outside, -outside_drop]);

            // 2 → top over the door
            bar([width, top_length, bar_thickness],
                [-width/2, y_outside, -bar_thickness]);

            // 3 ↓ inside vertical
            bar([width, bar_thickness, inside_drop],
                [-width/2,
                 y_inside,
                 -bar_thickness - inside_drop]);

            // 4 → hook
            bar([width, hook_depth + bar_thickness, bar_thickness],
                [-width/2,
                 y_hook_base,
                 -bar_thickness - inside_drop - bar_thickness]);

            // 5 ↑ lip
            bar([width, bar_thickness, lip_height],
                [-width/2,
                 y_hook_end - bar_thickness,
                 -bar_thickness - inside_drop - bar_thickness]);
        }
    }

    //— square or filleted version ————————————————
    if (corner_radius > 0)
        minkowski() {
            raw_bracket();
            cylinder(h = 1, r = corner_radius, $fn = 32);
        }
    else
        raw_bracket();
}

// preview with defaults
shower_hanger();
