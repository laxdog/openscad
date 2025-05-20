//------------------------------------------------------------
//  SHOWER-DOOR HANGER  –  parametric, gap + hook locked
//  corner_radius rounds edges; set round_all=true for *all* edges
//------------------------------------------------------------
module shower_hanger(
    /* ─── Core dimensions (mm) ─────────────────────────── */
    width            = 15,
    bar_thickness    = 5,
    outside_drop     = 60,
    door_thickness   = 10,   // glass / frame thickness
    clearance        = 2,    // wiggle room on the door
    inside_drop      = 85,
    hook_depth       = 10,   // clear span between bar-3 & bar-5
    lip_height       = 20,
    /* ─── Fillet controls ─────────────────────────────── */
    corner_radius    = 1,    // 0 = square; >0 = fillet radius
    round_all        = true  // false = vertical-edges only (fast);
                              // true  = all edges (uses a sphere)
){
    /* ----------  1. keep real-world clearances intact ---------- */
    gap_nominal   = door_thickness + clearance;
    gap           = gap_nominal +
                    (corner_radius>0 ? 2*corner_radius : 0);        // door gap

    hook_span_total =
        hook_depth + 2*bar_thickness +
        (corner_radius>0 ? 2*corner_radius : 0);                    // hook gap

    /* ----------  2. derived Y-positions ---------- */
    top_length  = gap + 2*bar_thickness;
    y_outside   = 0;
    y_inside    = bar_thickness + gap;
    y_hook_base = y_inside;
    y_hook_end  = y_hook_base + hook_span_total;

    /* ----------  3. helper cube ---------- */
    module bar(size_vec, pos_vec=[0,0,0])
        translate(pos_vec) cube(size_vec, center=false);

    /* ----------  4. raw geometry (five overlapping bars) ---------- */
    module raw_bracket() {
        union() {
            // 1 ↓ outside vertical
            bar([width, bar_thickness, outside_drop],
                [-width/2, y_outside, -outside_drop]);

            // 2 → across the top
            bar([width, top_length, bar_thickness],
                [-width/2, y_outside, -bar_thickness]);

            // 3 ↓ inside vertical
            bar([width, bar_thickness, inside_drop],
                [-width/2, y_inside, -bar_thickness - inside_drop]);

            // 4 → hook
            bar([width, hook_span_total, bar_thickness],
                [-width/2,
                 y_hook_base,
                 -bar_thickness - inside_drop - bar_thickness]);

            // 5 ↑ up-turned lip
            bar([width, bar_thickness, lip_height],
                [-width/2,
                 y_hook_end - bar_thickness,
                 -bar_thickness - inside_drop - bar_thickness]);
        }
    }

    /* ----------  5. choose fillet style ---------- */
    if (corner_radius > 0) {
        if (round_all)
            minkowski() {
                raw_bracket();
                sphere(r = corner_radius, $fn = 32);   // full 3-D fillet
            }
        else
            minkowski() {
                raw_bracket();
                cylinder(h = 1, r = corner_radius, $fn = 32); // XY-only fillet
            }
    } else
        raw_bracket();
}

/* Preview with defaults */
shower_hanger();
