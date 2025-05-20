//------------------------------------------------------------
//  SHOWER-DOOR HANGER  – five-segment, fully-parametric
//  • door gap and hook depth are guaranteed real-world sizes
//  • corner_radius optional (fillets shrink nothing)
//------------------------------------------------------------
module shower_hanger(
    /* ─── Core dimensions (mm) ─────────────────────────── */
    width            = 15,
    bar_thickness    = 5,
    outside_drop     = 60,
    door_thickness   = 8,   // glass / frame thickness
    clearance        = 2,    // extra wiggle room on the door
    inside_drop      = 40,
    hook_depth       = 8,   // clear space between bar-3 and bar-5
    lip_height       = 20,
    /* ─── Optional nicety ──────────────────────────────── */
    corner_radius    = 0     // 0 = square; >0 = fillet radius
){
    /* ----------  1. REAL GAP OVER THE DOOR  ---------- */
    gap_nominal   = door_thickness + clearance;
    gap           = gap_nominal + (corner_radius>0 ? 2*corner_radius : 0);

    /* ----------  2. REAL HOOK DEPTH  ----------
                   L_total = hook_depth + 2·bar_thickness + 2·r  */
    hook_span_total =
        hook_depth + 2*bar_thickness +
        (corner_radius>0 ? 2*corner_radius : 0);

    /* ----------  3. Derived Y-positions  ---------- */
    top_length  = gap + 2*bar_thickness;      // bar-to-bar span
    y_outside   = 0;
    y_inside    = bar_thickness + gap;        // first exposed face of bar-3
    y_hook_base = y_inside;                   // start of hook bar
    y_hook_end  = y_hook_base + hook_span_total;

    /* ----------  4. Little helper cube  ---------- */
    module bar(size_vec, pos_vec=[0,0,0])
        translate(pos_vec) cube(size_vec, center=false);

    /* ----------  5. Raw geometry (five overlapping bars)  ---------- */
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
                [-width/2,
                 y_inside,
                 -bar_thickness - inside_drop]);

            // 4 → hook  (length includes both overlaps + fillet slack)
            bar([width, hook_span_total, bar_thickness],
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

    /* ----------  6. Square or filleted version  ---------- */
    if (corner_radius > 0)
        minkowski() {
            raw_bracket();
            cylinder(h=1, r=corner_radius, $fn=32);
        }
    else
        raw_bracket();
}

/* Preview with current defaults */
shower_hanger();
